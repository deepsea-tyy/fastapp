<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Utils;

use Carbon\Carbon;
use Hyperf\DbConnection\Db;

/**
 * K线分片表工具类
 * 支持按月分片的K线数据表查询和插入
 */
class KlineShardHelper
{
    /**
     * 基础表名常量
     */
    public const BASE_TABLE_SPOT = 'ex_spot_klines';
    public const BASE_TABLE_FUTURES = 'ex_futures_klines';

    /**
     * 获取分片表名（按月分片）
     * 
     * @param string $baseTable 基础表名（如 ex_spot_klines）
     * @param Carbon|string|int $time 时间（Carbon对象、时间字符串或时间戳）
     * @return string 分片表名（如 ex_spot_klines_202501）
     */
    public static function getShardTableName(string $baseTable, $time): string
    {
        if (is_int($time)) {
            $carbon = Carbon::createFromTimestamp($time);
        } elseif (is_string($time)) {
            $carbon = Carbon::parse($time);
        } elseif ($time instanceof Carbon) {
            $carbon = $time;
        } else {
            throw new \InvalidArgumentException('Invalid time format');
        }

        $shardSuffix = $carbon->format('Ym'); // 格式：202501
        return "{$baseTable}_{$shardSuffix}";
    }

    /**
     * 获取时间范围内的所有分片表名
     * 
     * @param string $baseTable 基础表名
     * @param int|null $startTime 开始时间（时间戳，秒）
     * @param int|null $endTime 结束时间（时间戳，秒）
     * @return array 分片表名数组
     */
    public static function getShardTablesInRange(string $baseTable, ?int $startTime = null, ?int $endTime = null): array
    {
        $shardTables = [];

        if ($startTime === null && $endTime === null) {
            // 如果没有时间范围，返回当前月份的分片表
            $shardTables[] = self::getShardTableName($baseTable, time());
            return $shardTables;
        }

        $start = $startTime ? Carbon::createFromTimestamp($startTime) : Carbon::now()->subMonths(1);
        $end = $endTime ? Carbon::createFromTimestamp($endTime) : Carbon::now();

        // 确保开始时间不晚于结束时间
        if ($start->gt($end)) {
            [$start, $end] = [$end, $start];
        }

        // 遍历时间范围内的所有月份
        $current = $start->copy()->startOfMonth();
        while ($current->lte($end)) {
            $shardTables[] = self::getShardTableName($baseTable, $current);
            $current->addMonth();
        }

        // 去重并排序
        $shardTables = array_unique($shardTables);
        sort($shardTables);

        return $shardTables;
    }

    /**
     * 确保分片表存在
     * 
     * @param string $shardTable 分片表名
     * @return bool 是否成功
     */
    public static function ensureShardTableExists(string $shardTable): bool
    {
        // 检查是否是分片表（包含下划线和6位数字）
        if (!preg_match('/_\d{6}$/', $shardTable)) {
            // 不是分片表，直接返回
            return false;
        }

        // 检查表是否存在
        $exists = Db::select("SHOW TABLES LIKE '{$shardTable}'");
        if (!empty($exists)) {
            return true;
        }

        // 创建分片表
        return self::createShardTable($shardTable);
    }

    /**
     * 创建分片表
     * 
     * @param string $shardTable 分片表名
     * @return bool 是否成功
     */
    public static function createShardTable(string $shardTable): bool
    {
        // 提取基础表名（去掉分片后缀）
        $baseTable = preg_replace('/_\d{6}$/', '', $shardTable);
        
        // 根据基础表名确定表结构
        if ($baseTable === self::BASE_TABLE_SPOT) {
            return self::createSpotKlineShardTable($shardTable);
        } elseif ($baseTable === self::BASE_TABLE_FUTURES) {
            return self::createFuturesKlineShardTable($shardTable);
        }

        return false;
    }

    /**
     * 创建现货K线分片表
     */
    private static function createSpotKlineShardTable(string $tableName): bool
    {
        $sql = "CREATE TABLE IF NOT EXISTS `{$tableName}` (
            `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
            `symbol` VARCHAR(16) NOT NULL COMMENT '交易对符号（如BTCUSDT）',
            `interval` VARCHAR(10) NOT NULL COMMENT '时间间隔 1m/3m/5m/15m/30m/1h/2h/4h/6h/8h/12h/1d/3d/1w/1M',
            `open_time` TIMESTAMP NOT NULL COMMENT '开盘时间',
            `open_price` DECIMAL(36,18) NOT NULL COMMENT '开盘价',
            `high_price` DECIMAL(36,18) NOT NULL COMMENT '最高价',
            `low_price` DECIMAL(36,18) NOT NULL COMMENT '最低价',
            `close_price` DECIMAL(36,18) NOT NULL COMMENT '收盘价',
            `volume` DECIMAL(36,18) NOT NULL COMMENT '成交量（基础币种）',
            `close_time` TIMESTAMP NOT NULL COMMENT '收盘时间',
            `quote_volume` DECIMAL(36,18) NOT NULL COMMENT '成交额（计价币种）',
            `trade_count` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '成交笔数',
            `taker_buy_volume` DECIMAL(36,18) NOT NULL DEFAULT 0 COMMENT '主动买入成交量（基础币种）',
            `taker_buy_quote_volume` DECIMAL(36,18) NOT NULL DEFAULT 0 COMMENT '主动买入成交额（计价币种）',
            `created_at` TIMESTAMP NULL DEFAULT NULL,
            `updated_at` TIMESTAMP NULL DEFAULT NULL,
            PRIMARY KEY (`id`),
            UNIQUE KEY `uk_spot_symbol_interval_time` (`symbol`, `interval`, `open_time`),
            KEY `idx_spot_symbol_interval` (`symbol`, `interval`),
            KEY `idx_spot_open_time` (`open_time`),
            KEY `idx_spot_close_time` (`close_time`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='现货K线数据表（分片）'";

        try {
            Db::unprepared($sql);
            return true;
        } catch (\Exception $e) {
            return false;
        }
    }

    /**
     * 创建合约K线分片表
     */
    private static function createFuturesKlineShardTable(string $tableName): bool
    {
        $sql = "CREATE TABLE IF NOT EXISTS `{$tableName}` (
            `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
            `symbol` BIGINT UNSIGNED NOT NULL COMMENT '交易对ID（关联ex_futures_symbols或market_pair）',
            `interval` VARCHAR(10) NOT NULL COMMENT '时间间隔 1m/3m/5m/15m/30m/1h/2h/4h/6h/8h/12h/1d/3d/1w/1M',
            `open_time` TIMESTAMP NOT NULL COMMENT '开盘时间',
            `open_price` DECIMAL(36,18) NOT NULL COMMENT '开盘价',
            `high_price` DECIMAL(36,18) NOT NULL COMMENT '最高价',
            `low_price` DECIMAL(36,18) NOT NULL COMMENT '最低价',
            `close_price` DECIMAL(36,18) NOT NULL COMMENT '收盘价',
            `volume` DECIMAL(36,18) NOT NULL COMMENT '成交量（合约数量）',
            `close_time` TIMESTAMP NOT NULL COMMENT '收盘时间',
            `quote_volume` DECIMAL(36,18) NOT NULL COMMENT '成交额（计价币种）',
            `trade_count` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '成交笔数',
            `taker_buy_volume` DECIMAL(36,18) NOT NULL DEFAULT 0 COMMENT '主动买入成交量（合约数量）',
            `taker_buy_quote_volume` DECIMAL(36,18) NOT NULL DEFAULT 0 COMMENT '主动买入成交额（计价币种）',
            `created_at` TIMESTAMP NULL DEFAULT NULL,
            `updated_at` TIMESTAMP NULL DEFAULT NULL,
            PRIMARY KEY (`id`),
            UNIQUE KEY `uk_futures_symbol_interval_time` (`symbol`, `interval`, `open_time`),
            KEY `idx_futures_symbol_interval` (`symbol`, `interval`),
            KEY `idx_futures_open_time` (`open_time`),
            KEY `idx_futures_close_time` (`close_time`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='合约K线数据表（分片）'";

        try {
            Db::unprepared($sql);
            return true;
        } catch (\Exception $e) {
            return false;
        }
    }
}

