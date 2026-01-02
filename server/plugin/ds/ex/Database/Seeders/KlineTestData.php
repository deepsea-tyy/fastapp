<?php
/**
 * FastApp.
 * K线测试数据生成器
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

declare(strict_types=1);

use Hyperf\Database\Seeders\Seeder;
use Hyperf\DbConnection\Db;
use Carbon\Carbon;

/**
 * 执行命令（推荐）: php bin/hyperf.php kline:generate-test-data
 * 
*/
class KlineTestData extends Seeder
{
    private const BATCH_SIZE = 1000;
    private const CHUNK_SIZE = 500;
    private const BASE_PRICE = 50000.0;
    private const PRICE_CHANGE_RANGE = 0.02; // ±2%

    /**
     * 支持的时间周期
     */
    private array $intervals = ['1m', '3m', '5m', '15m', '30m', '1h', '2h', '4h', '6h', '8h', '12h', '1d', '3d', '1w', '1M'];

    /**
     * 时间周期对应的秒数
     */
    private array $intervalSeconds = [
        '1m' => 60,
        '3m' => 180,
        '5m' => 300,
        '15m' => 900,
        '30m' => 1800,
        '1h' => 3600,
        '2h' => 7200,
        '4h' => 14400,
        '6h' => 21600,
        '8h' => 28800,
        '12h' => 43200,
        '1d' => 86400,
        '3d' => 259200,
        '1w' => 604800,
        '1M' => 2592000,
    ];

    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        echo '开始生成K线测试数据...' . PHP_EOL;

        // 获取现货交易对符号
        $spotSymbols = $this->getSpotSymbols();
        if (empty($spotSymbols)) {
            echo '未找到现货交易对，跳过现货K线数据生成' . PHP_EOL;
        } else {
            echo '找到 ' . count($spotSymbols) . ' 个现货交易对' . PHP_EOL;
            $this->generateSpotKlines($spotSymbols);
        }

        // 获取合约交易对符号
       /* $futuresSymbols = $this->getFuturesSymbols();
        if (empty($futuresSymbols)) {
            echo '未找到合约交易对，跳过合约K线数据生成' . PHP_EOL;
        } else {
            echo '找到 ' . count($futuresSymbols) . ' 个合约交易对' . PHP_EOL;
            $this->generateFuturesKlines($futuresSymbols);
        }*/

        echo 'K线测试数据生成完成' . PHP_EOL;
    }

    /**
     * 获取现货交易对符号列表
     */
    private function getSpotSymbols(): array
    {
        $testSymbols = ['BTCUSDT'];
        return $this->ensureSymbolsExist($testSymbols, 'spot');
    }

    /**
     * 获取合约交易对符号列表
     */
    private function getFuturesSymbols(): array
    {
        $testSymbols = ['BTCUSDT', 'ETHUSDT', 'BNBUSDT'];
        $symbols = [];
        foreach ($testSymbols as $symbol) {
            $symbols[] = $symbol . '_PERP';
        }
        return $this->ensureSymbolsExist($symbols, 'futures');
    }

    /**
     * 确保交易对存在，不存在则创建
     */
    private function ensureSymbolsExist(array $testSymbols, string $marketType): array
    {
        $symbols = [];
        $typeName = $marketType === 'spot' ? '现货' : '合约';
        
        echo "创建测试{$typeName}交易对..." . PHP_EOL;
        
        foreach ($testSymbols as $symbol) {
            if (!Db::table('market_pair')->where('symbol', $symbol)->exists()) {
                $baseData = [
                    'symbol' => $symbol,
                    'base_currency_symbol' => substr($symbol, 0, -4),
                    'quote_currency_symbol' => 'USDT',
                    'market_type' => $marketType,
                    'price_precision' => 2,
                    'quantity_precision' => 8,
                    'min_quantity' => 0.0001,
                    'max_quantity' => 1000000,
                    'min_amount' => 5,
                    'max_amount' => 10000000,
                    'tick_size' => 0.01,
                    'step_size' => 0.00000001,
                    'status' => 1,
                    'created_at' => Carbon::now(),
                    'updated_at' => Carbon::now(),
                ];
                
                if ($marketType === 'futures') {
                    $baseData['settlement_currency_symbol'] = 'USDT';
                    $baseData['maker_fee_rate'] = 0.0002;
                    $baseData['taker_fee_rate'] = 0.0005;
                    $baseData['leverage_enabled'] = 1;
                    $baseData['max_leverage'] = 125;
                } else {
                    $baseData['maker_fee_rate'] = 0.0005;
                    $baseData['taker_fee_rate'] = 0.001;
                }
                
                Db::table('market_pair')->insert($baseData);
            }
            $symbols[] = $symbol;
        }
        
        return $symbols;
    }

    /**
     * 生成现货K线数据
     */
    private function generateSpotKlines(array $symbols): void
    {
        $this->generateKlines('ex_spot_klines', $symbols, '现货');
    }

    /**
     * 生成合约K线数据
     */
    private function generateFuturesKlines(array $symbols): void
    {
        $this->generateKlines('ex_futures_klines', $symbols, '合约');
    }

    /**
     * 生成K线数据（通用方法）
     */
    private function generateKlines(string $table, array $symbols, string $type): void
    {
        foreach ($symbols as $symbol) {
            echo "生成{$type}交易对: {$symbol} 的K线数据..." . PHP_EOL;
            foreach ($this->intervals as $interval) {
                $this->generateKlineData($table, $symbol, $interval);
            }
        }
    }

    /**
     * 生成K线数据（支持分片插入）
     * 生成今天的数据（从今天00:00:00到当前时间）
     */
    private function generateKlineData(string $table, string $symbol, string $interval): void
    {
        if (!isset($this->intervalSeconds[$interval])) {
            return;
        }

        $intervalSeconds = $this->intervalSeconds[$interval];
        $now = Carbon::now();
        $startTime = $now->copy()->startOfDay(); // 今天00:00:00
        $endTime = $now; // 当前时间

        // 计算需要生成多少个K线（从今天开始到当前时间）
        $totalSeconds = $endTime->diffInSeconds($startTime);
        $klineCount = (int)($totalSeconds / $intervalSeconds);
        
        // 如果当前时间还没到第一个K线周期，至少生成1个K线
        if ($klineCount < 1) {
            $klineCount = 1;
        }

        $price = self::BASE_PRICE;
        $currentShard = null;
        $currentShardData = [];

        for ($i = 0; $i < $klineCount; $i++) {
            $openTime = $startTime->copy()->addSeconds($i * $intervalSeconds);
            $closeTime = $openTime->copy()->addSeconds($intervalSeconds - 1);
            
            // 确保收盘时间不超过当前时间
            if ($closeTime->gt($endTime)) {
                $closeTime = $endTime->copy();
            }
            
            // 如果开盘时间已经超过当前时间，停止生成
            if ($openTime->gt($endTime)) {
                break;
            }

            // 确定当前K线所属的分片表
            $shardTable = $this->getShardTableName($table, $openTime);

            // 如果分片表发生变化，先插入之前分片的数据
            if ($currentShard !== null && $currentShard !== $shardTable) {
                if (!empty($currentShardData)) {
                    $this->batchInsertKlines($currentShard, $currentShardData);
                    $currentShardData = [];
                }
            }
            $currentShard = $shardTable;

            // 生成合理的价格波动
            $changePercent = (mt_rand(-200, 200) / 10000);
            $openPrice = $price;
            $closePrice = $openPrice * (1 + $changePercent);
            $highPrice = max($openPrice, $closePrice) * (1 + mt_rand(0, 100) / 10000);
            $lowPrice = min($openPrice, $closePrice) * (1 - mt_rand(0, 100) / 10000);

            // 生成成交量（随机）
            $volume = mt_rand(100, 10000) / 100;
            $quoteVolume = $volume * $closePrice;
            $tradeCount = mt_rand(50, 500);
            $takerBuyVolume = $volume * (mt_rand(40, 60) / 100);
            $takerBuyQuoteVolume = $takerBuyVolume * $closePrice;

            $currentShardData[] = [
                'symbol' => $symbol,
                'interval' => $interval,
                'open_time' => $openTime,
                'open_price' => number_format($openPrice, 18, '.', ''),
                'high_price' => number_format($highPrice, 18, '.', ''),
                'low_price' => number_format($lowPrice, 18, '.', ''),
                'close_price' => number_format($closePrice, 18, '.', ''),
                'volume' => number_format($volume, 18, '.', ''),
                'close_time' => $closeTime,
                'quote_volume' => number_format($quoteVolume, 18, '.', ''),
                'trade_count' => $tradeCount,
                'taker_buy_volume' => number_format($takerBuyVolume, 18, '.', ''),
                'taker_buy_quote_volume' => number_format($takerBuyQuoteVolume, 18, '.', ''),
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ];

            // 更新价格用于下一个K线
            $price = $closePrice;

            // 批量插入
            if (count($currentShardData) >= self::BATCH_SIZE) {
                $this->batchInsertKlines($currentShard, $currentShardData);
                $currentShardData = [];
            }
        }

        // 插入最后一个分片的剩余数据
        if (!empty($currentShardData) && $currentShard !== null) {
            $this->batchInsertKlines($currentShard, $currentShardData);
        }

        echo "  - {$interval}: 生成了 {$klineCount} 条K线数据" . PHP_EOL;
    }

    /**
     * 获取分片表名（按月分片）
     * 
     * @param string $baseTable 基础表名（如 ex_spot_klines）
     * @param Carbon $time 时间
     * @return string 分片表名（如 ex_spot_klines_202501）
     */
    private function getShardTableName(string $baseTable, Carbon $time): string
    {
        return \Plugin\Ds\Ex\Utils\KlineShardHelper::getShardTableName($baseTable, $time);
    }

    /**
     * 批量插入K线数据（使用 INSERT IGNORE 避免重复，支持分片表）
     */
    private function batchInsertKlines(string $table, array $data): void
    {
        if (empty($data)) {
            return;
        }

        // 确保分片表存在
        $this->ensureShardTableExists($table);

        // 转换 Carbon 对象为字符串
        foreach ($data as &$row) {
            foreach ($row as $key => $value) {
                if ($value instanceof Carbon) {
                    $row[$key] = $value->format('Y-m-d H:i:s');
                }
            }
        }
        unset($row);

        // 分批插入
        $chunks = array_chunk($data, self::CHUNK_SIZE);
        foreach ($chunks as $chunk) {
            $this->insertChunk($table, $chunk);
        }
    }

    /**
     * 确保分片表存在
     */
    private function ensureShardTableExists(string $table): void
    {
        \Plugin\Ds\Ex\Utils\KlineShardHelper::ensureShardTableExists($table);
    }

    /**
     * 插入数据块（带错误处理）
     */
    private function insertChunk(string $table, array $chunk): void
    {
        try {
            Db::table($table)->insert($chunk);
        } catch (\Exception $e) {
            $message = $e->getMessage();
            
            // 表不存在，尝试创建
            if (str_contains($message, "doesn't exist")) {
                $this->createShardTable($table);
                try {
                    Db::table($table)->insert($chunk);
                } catch (\Exception $retryEx) {
                    if ($this->isDuplicateError($retryEx)) {
                        $this->insertIgnore($table, $chunk);
                    } else {
                        $this->insertOneByOne($table, $chunk);
                    }
                }
            } elseif ($this->isDuplicateError($e)) {
                // 唯一索引冲突，使用 INSERT IGNORE
                $this->insertIgnore($table, $chunk);
            } else {
                // 其他错误，逐条插入
                $this->insertOneByOne($table, $chunk);
            }
        }
    }

    /**
     * 判断是否为重复数据错误
     */
    private function isDuplicateError(\Exception $e): bool
    {
        $message = $e->getMessage();
        return str_contains($message, 'Duplicate entry') || str_contains($message, 'UNIQUE constraint');
    }

    /**
     * 逐条插入数据（跳过重复项）
     */
    private function insertOneByOne(string $table, array $chunk): void
    {
        foreach ($chunk as $row) {
            try {
                Db::table($table)->insert($row);
            } catch (\Exception $ex) {
                // 忽略重复数据
                continue;
            }
        }
    }

    /**
     * 创建分片表
     */
    private function createShardTable(string $shardTable): void
    {
        \Plugin\Ds\Ex\Utils\KlineShardHelper::createShardTable($shardTable);
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
                $value = $row[$column] ?? null;
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

