<?php
/**
 * FastApp - Market Kline Process
 * 市场K线数据模拟推送进程
 *
 * 策略：
 * 1. 支持多个时间周期：1s, 1m, 3m, 5m, 15m, 30m, 1h, 2h, 4h, 6h, 8h, 12h, 1d, 3d, 1w, 1M
 * 2. 统一推送频率：每秒检查并推送更新
 * 3. 只推送有订阅者的房间
 */

namespace Plugin\Ds\Ex\Process;

use Hyperf\Process\Annotation\Process;

#[Process(nums: 1, name: "MarketKlineProcess")]
class MarketKlineProcess extends AbstractMarketProcess
{
    /**
     * 支持的时间周期
     */
    private array $intervals = ['1s', '1m', '3m', '5m', '15m', '30m', '1h', '2h', '4h', '6h', '8h', '12h', '1d', '3d', '1w', '1M'];

    /**
     * 时间周期对应的推送间隔（秒）
     */
    private array $intervalPushSeconds = [
        '1s' => 1,
        '1m' => 1,
        '3m' => 3,
        '5m' => 5,
        '15m' => 15,
        '30m' => 30,
        '1h' => 60,
        '2h' => 120,
        '4h' => 300,
        '6h' => 600,
        '8h' => 900,
        '12h' => 1800,
        '1d' => 3600,
        '3d' => 7200,
        '1w' => 14400,
        '1M' => 86400,
    ];

    /**
     * 时间周期对应的计算间隔（秒）
     */
    private array $intervalSeconds = [
        '1s' => 1,
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
     * K线缓存（用于生成模拟数据）
     * 格式: ['BTCUSDT:1m' => [...kline data...]]
     */
    private array $klineCache = [];

    /**
     * 上次 K线 的收盘价缓存（用于计算成交额）
     * 格式: ['BTCUSDT:1m' => price]
     */
    private array $lastKlineClosePrice = [];

    /**
     * 上次推送时间（按周期记录）
     * 格式: ['1m' => timestamp, '5m' => timestamp, ...]
     */
    private array $lastPushTime = [];

    /**
     * 获取进程名称
     */
    protected function getProcessName(): string
    {
        return 'MarketKline';
    }

    /**
     * 初始化进程数据
     */
    protected function initializeData(): void
    {
        // 初始化每个周期的上次推送时间
        foreach ($this->intervals as $interval) {
            $this->lastPushTime[$interval] = 0;
        }
    }

    /**
     * 推送数据
     */
    protected function pushData(int $currentTime): void
    {
        // 遍历所有交易对和时间周期
        foreach ($this->allSymbols as $symbol) {
            foreach ($this->intervals as $interval) {
                // 检查是否到达该周期的推送时间
                $pushInterval = $this->intervalPushSeconds[$interval] ?? 1;
                if ($currentTime - $this->lastPushTime[$interval] < $pushInterval) {
                    continue;
                }

                $roomId = "kline:{$symbol}:{$interval}";

                // 检查房间是否有订阅者
                $memberCount = $this->getRoomMemberCount($roomId);
                if ($memberCount === 0) {
                    continue;
                }

                // 生成K线数据
                $klineData = $this->generateKlineData($symbol, $interval, $currentTime);

                // 如果是1s周期，保存到Redis（用于API查询）
                if ($interval === '1s') {
                    $this->saveKline1sToRedis($symbol, $klineData);
                }

                // 推送日志
                $this->logPush($roomId, $memberCount, ['price' => $klineData['close']]);

                // 推送到房间
                $this->pushToRoom(
                    roomId: $roomId,
                    data: $klineData,
                    event: 'market.kline'
                );
            }

            // 更新推送时间（按周期）
            foreach ($this->intervals as $interval) {
                $pushInterval = $this->intervalPushSeconds[$interval] ?? 1;
                if ($currentTime - $this->lastPushTime[$interval] >= $pushInterval) {
                    $this->lastPushTime[$interval] = $currentTime;
                }
            }
        }
    }

    /**
     * 生成K线数据
     */
    private function generateKlineData(string $symbol, string $interval, int $currentTime): array
    {
        $intervalSeconds = $this->intervalSeconds[$interval] ?? 60;
        $timestamp = (int)(floor($currentTime / $intervalSeconds) * $intervalSeconds);

        $cacheKey = "{$symbol}:{$interval}";

        // 从Redis获取价格，确保与Ticker进程同步
        $currentPrice = $this->getPriceFromRedis($symbol);
        if ($currentPrice === null) {
            $currentPrice = $this->basePrices[$symbol] ?? 40000.0;
        }

        // 如果是新的K线周期，生成新K线
        if (!isset($this->klineCache[$cacheKey]) || $this->klineCache[$cacheKey]['timestamp'] < $timestamp) {
            // 新K线：开盘价等于当前价格
            $open = $currentPrice;
            $this->klineCache[$cacheKey] = [
                'timestamp' => $timestamp,
                'open' => $open,
                'high' => $open,
                'low' => $open,
                'close' => $open,
                'volume' => 0,
                'amount' => 0,
            ];
        }

        // 更新当前K线
        $kline = &$this->klineCache[$cacheKey];

        // 模拟价格波动（±1%）
        $fluctuation = (mt_rand(-100, 100) / 10000); // -1% ~ +1%
        $newPrice = $currentPrice * (1 + $fluctuation);
        $newPrice = round($newPrice, 2);

        // 更新高低价和收盘价
        $kline['high'] = max($kline['high'], $newPrice);
        $kline['low'] = min($kline['low'], $newPrice);
        $kline['close'] = $newPrice;

        // 生成随机成交量
        $volumeDelta = mt_rand(100, 10000);
        $kline['volume'] += $volumeDelta;

        // 计算成交额：成交量 * 平均价格（开盘价和当前价的平均值）
        $avgPrice = ($kline['open'] + $newPrice) / 2;
        $kline['amount'] += $volumeDelta * $avgPrice;

        // 更新Redis价格
        $this->setPriceToRedis($symbol, $newPrice);

        // 返回K线数据
        return [
            'symbol' => $this->formatSymbolWithSlash($symbol),
            'interval' => $interval,
            'timestamp' => $timestamp * 1000,
            'open' => round($kline['open'], 2),
            'high' => round($kline['high'], 2),
            'low' => round($kline['low'], 2),
            'close' => round($kline['close'], 2),
            'volume' => round($kline['volume'], 2),
            'amount' => round($kline['amount'], 2),
        ];
    }

    /**
     * 保存1s K线数据到Redis（用于API查询）
     *
     * @param string $symbol 交易对符号（不带斜杠）
     * @param array $klineData K线数据
     */
    private function saveKline1sToRedis(string $symbol, array $klineData): void
    {
        try {
            $redis = $this->getRedis();
            $key = "kline:1s:{$symbol}";

            // 使用时间戳作为分数（score），K线数据JSON作为值
            $score = $klineData['timestamp'];
            $value = json_encode($klineData);

            // 添加到有序集合
            $redis->zAdd($key, $score, $value);

            // 只保留最新的500条数据（移除旧数据）
            // zRemRangeByRank 参数：key, start, stop
            // 保留索引 -500 到 -1（即最后500条），移除之前的数据
            $redis->zRemRangeByRank($key, 0, -501);

            // 设置过期时间（7天），避免数据长期占用内存
            $redis->expire($key, 7 * 24 * 3600);
        } catch (\Throwable $e) {
            // Redis 失败时忽略，不影响WebSocket推送
            $this->logError("保存1s K线到Redis失败: {$e->getMessage()}");
        }
    }
}
