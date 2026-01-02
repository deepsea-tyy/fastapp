<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Repository;

use Plugin\Ds\Ex\Model\SpotKline as Model;
use Plugin\Ds\Ex\Utils\KlineShardHelper;
use App\Repository\IRepository;
use Hyperf\DbConnection\Db;
use Carbon\Carbon;

class SpotKlineRepository extends IRepository
{
    public function __construct(protected readonly Model $model)
    {
    }

    /**
     * 获取K线数据（支持分片表查询和分页）
     *
     * @param string $symbolId 交易对符号（如BTCUSDT）
     * @param string $interval 时间周期
     * @param int $page 页码（从1开始）
     * @param int $pageSize 每页数量
     * @return array
     */
    public function getKlines(
        string $symbolId,
        string $interval,
        int    $page = 1,
        int    $pageSize = 100
    ): array
    {
        // 获取最近6个月的分片表（用于查询最新数据）
        $endTime = time();
        $startTime = $endTime - (180 * 86400); // 180天前

        $shardTables = KlineShardHelper::getShardTablesInRange(
            KlineShardHelper::BASE_TABLE_SPOT,
            $startTime,
            $endTime
        );

        // 如果没有分片表，尝试使用基础表（向后兼容）
        if (empty($shardTables)) {
            return $this->queryFromBaseTableWithPagination(
                $symbolId,
                $interval,
                $page,
                $pageSize
            );
        }

        // 从所有分片表中查询数据
        $allResults = [];
        foreach ($shardTables as $shardTable) {
            // 确保分片表存在
            KlineShardHelper::ensureShardTableExists($shardTable);

            $results = Db::table($shardTable)
                ->where('symbol', $symbolId)
                ->where('interval', $interval)
                ->orderBy('open_time', 'asc')
                ->get()
                ->toArray();

            $allResults = array_merge($allResults, $results);
        }

        // 按时间排序
        usort($allResults, function ($a, $b) {
            return strtotime($a->open_time) <=> strtotime($b->open_time);
        });

        // 分页处理
        $offset = ($page - 1) * $pageSize;
        $allResults = array_slice($allResults, $offset, $pageSize);

        // 转换为数组格式
        return array_map(function ($item) {
            return (array)$item;
        }, $allResults);
    }

    /**
     * 获取最新的K线数据（支持分片表查询）
     *
     * @param string $symbolId 交易对符号（如BTCUSDT）
     * @param string $interval 时间周期
     * @param int $limit 返回数量限制
     * @return array
     */
    public function getLatestKlines(string $symbolId, string $interval, int $limit = 500): array
    {
        // 获取最近几个月的分片表（最多查询最近3个月）
        $endTime = time();
        $startTime = $endTime - (90 * 86400); // 90天前

        $shardTables = KlineShardHelper::getShardTablesInRange(
            KlineShardHelper::BASE_TABLE_SPOT,
            $startTime,
            $endTime
        );

        // 如果没有分片表，尝试使用基础表（向后兼容）
        if (empty($shardTables)) {
            return $this->model->where('symbol', $symbolId)
                ->where('interval', $interval)
                ->orderBy('open_time', 'desc')
                ->limit($limit)
                ->get()
                ->toArray();
        }

        // 从所有分片表中查询数据（倒序查询最近的分片表）
        $allResults = [];
        $shardTables = array_reverse($shardTables); // 从最新的分片表开始查询

        foreach ($shardTables as $shardTable) {
            // 确保分片表存在
            KlineShardHelper::ensureShardTableExists($shardTable);

            $results = Db::table($shardTable)
                ->where('symbol', $symbolId)
                ->where('interval', $interval)
                ->orderBy('open_time', 'desc')
                ->limit($limit)
                ->get()
                ->toArray();

            $allResults = array_merge($allResults, $results);

            // 如果已经获取足够的数据，可以提前退出
            if (count($allResults) >= $limit) {
                break;
            }
        }

        // 按时间倒序排序
        usort($allResults, function ($a, $b) {
            return strtotime($b->open_time) <=> strtotime($a->open_time);
        });

        // 限制返回数量
        $allResults = array_slice($allResults, 0, $limit);

        // 转换为数组格式
        return array_map(function ($item) {
            return (array)$item;
        }, $allResults);
    }

    /**
     * 更新或创建K线数据（支持分片表）
     *
     * @param array $data K线数据
     * @return Model
     */
    public function updateOrCreate(array $data): Model
    {
        // 根据 open_time 确定分片表
        $openTime = $data['open_time'];
        if (is_string($openTime)) {
            $openTime = Carbon::parse($openTime);
        } elseif (is_int($openTime)) {
            $openTime = Carbon::createFromTimestamp($openTime);
        }

        $shardTable = KlineShardHelper::getShardTableName(
            KlineShardHelper::BASE_TABLE_SPOT,
            $openTime
        );

        // 确保分片表存在
        KlineShardHelper::ensureShardTableExists($shardTable);

        // 使用分片表进行更新或创建
        $model = clone $this->model;
        $model->setTable($shardTable);

        return $model->updateOrCreate(
            [
                'symbol' => $data['symbol'],
                'interval' => $data['interval'],
                'open_time' => $data['open_time'],
            ],
            $data
        );
    }

    /**
     * 批量更新或创建K线数据（支持分片表）
     *
     * @param array $klines K线数据数组
     * @return void
     */
    public function upsertBatch(array $klines): void
    {
        // 按分片表分组
        $shardGroups = [];
        foreach ($klines as $kline) {
            $openTime = $kline['open_time'];
            if (is_string($openTime)) {
                $openTime = Carbon::parse($openTime);
            } elseif (is_int($openTime)) {
                $openTime = Carbon::createFromTimestamp($openTime);
            }

            $shardTable = KlineShardHelper::getShardTableName(
                KlineShardHelper::BASE_TABLE_SPOT,
                $openTime
            );

            if (!isset($shardGroups[$shardTable])) {
                $shardGroups[$shardTable] = [];
            }

            $shardGroups[$shardTable][] = $kline;
        }

        // 按分片表批量插入
        foreach ($shardGroups as $shardTable => $groupKlines) {
            // 确保分片表存在
            KlineShardHelper::ensureShardTableExists($shardTable);

            // 批量插入（使用 INSERT IGNORE 避免重复）
            $this->batchInsertIgnore($shardTable, $groupKlines);
        }
    }

    /**
     * 从基础表查询（向后兼容，支持分页）
     */
    private function queryFromBaseTableWithPagination(
        string $symbolId,
        string $interval,
        int    $page,
        int    $pageSize
    ): array
    {
        $offset = ($page - 1) * $pageSize;
        return $this->model->where('symbol', $symbolId)
            ->where('interval', $interval)
            ->orderBy('open_time', 'asc')
            ->offset($offset)
            ->limit($pageSize)
            ->get()
            ->toArray();
    }

    /**
     * 批量插入（使用 INSERT IGNORE）
     */
    private function batchInsertIgnore(string $table, array $data): void
    {
        if (empty($data)) {
            return;
        }

        // 转换 Carbon 对象为字符串
        foreach ($data as &$row) {
            foreach ($row as $key => $value) {
                if ($value instanceof Carbon) {
                    $row[$key] = $value->format('Y-m-d H:i:s');
                }
            }
        }
        unset($row);

        // 分批插入，每批500条
        $chunks = array_chunk($data, 500);
        foreach ($chunks as $chunk) {
            try {
                Db::table($table)->insert($chunk);
            } catch (\Exception $e) {
                // 如果出现唯一索引冲突，使用 INSERT IGNORE
                if (str_contains($e->getMessage(), 'Duplicate entry') ||
                    str_contains($e->getMessage(), 'UNIQUE constraint')) {
                    $this->insertIgnore($table, $chunk);
                } else {
                    // 其他错误，逐条插入以跳过重复项
                    foreach ($chunk as $row) {
                        try {
                            Db::table($table)->insert($row);
                        } catch (\Exception $ex) {
                            // 忽略重复数据
                            continue;
                        }
                    }
                }
            }
        }
    }

    /**
     * 使用 INSERT IGNORE 插入数据
     */
    private function insertIgnore(string $table, array $data): void
    {
        if (empty($data)) {
            return;
        }

        $columns = array_keys($data[0]);
        $values = [];

        foreach ($data as $row) {
            $rowValues = [];
            foreach ($columns as $column) {
                $value = $row[$column];
                if (is_string($value)) {
                    $value = "'" . addslashes($value) . "'";
                } elseif (is_null($value)) {
                    $value = 'NULL';
                } else {
                    $value = (string)$value;
                }
                $rowValues[] = $value;
            }
            $values[] = '(' . implode(',', $rowValues) . ')';
        }

        $sql = "INSERT IGNORE INTO `{$table}` (`" . implode('`,`', $columns) . "`) VALUES " . implode(',', $values);
        Db::unprepared($sql);
    }
}

