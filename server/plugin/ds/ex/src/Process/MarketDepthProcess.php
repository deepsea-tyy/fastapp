<?php
/**
 * FastApp - Market Depth Process
 * 市场深度数据模拟推送进程
 *
 * 策略：
 * 1. 每秒推送深度数据（订单簿）
 * 2. 动态数据：价格和数量随机波动，每 5 秒刷新一次深度曲线
 * 3. 只推送有订阅者的房间
 */

namespace Plugin\Ds\Ex\Process;

use Hyperf\Process\Annotation\Process;

#[Process(nums: 1, name: "MarketDepthProcess")]
class MarketDepthProcess extends AbstractMarketProcess
{
    /**
     * 深度数据缓存
     * 格式: ['symbol' => ['bids' => [...], 'asks' => [...], 'lastPrice' => price]]
     */
    private array $depthCache = [];

    /**
     * 深度数量（默认20档）
     */
    private const DEFAULT_DEPTH_LIMIT = 20;

    /**
     * 获取进程名称
     */
    protected function getProcessName(): string
    {
        return 'MarketDepth';
    }

    /**
     * 初始化进程数据
     */
    protected function initializeData(): void
    {
        // 初始化深度缓存
        foreach ($this->allSymbols as $symbol) {
            $basePrice = $this->basePrices[$symbol] ?? 100.0;
            $this->depthCache[$symbol] = $this->generateNewDepthData($symbol, $basePrice, self::DEFAULT_DEPTH_LIMIT);
        }
    }

    /**
     * 推送数据
     */
    protected function pushData(int $currentTime): void
    {
        foreach ($this->allSymbols as $symbol) {
            $roomId = "depth:{$symbol}";

            // 检查房间是否有订阅者
            $memberCount = $this->getRoomMemberCount($roomId);
            if ($memberCount === 0) {
                continue;
            }

            // 生成深度数据
            $depthData = $this->generateDepthData($symbol, self::DEFAULT_DEPTH_LIMIT);

            // 推送日志
            $this->logPush($roomId, $memberCount);

            // 推送到房间
            $this->pushToRoom(
                roomId: $roomId,
                data: $depthData,
                event: 'market.depth'
            );
        }
    }

    /**
     * 生成深度数据（使用实时价格）
     */
    private function generateDepthData(string $symbol, int $limit): array
    {
        // 从 Redis 获取当前价格（与 Ticker 和 Kline 进程同步）
        $currentPrice = $this->getPriceFromRedis($symbol);
        if ($currentPrice === null) {
            $currentPrice = $this->basePrices[$symbol] ?? 40000.0;
            $this->setPriceToRedis($symbol, $currentPrice);
        }

        // 如果缓存中没有数据，生成新的深度数据
        if (!isset($this->depthCache[$symbol])) {
            $this->depthCache[$symbol] = $this->generateNewDepthData($symbol, $currentPrice, $limit);
        } else {
            // 根据实时价格更新深度数据
            $this->updateDepthData($symbol, $currentPrice, $limit);
        }

        return $this->depthCache[$symbol];
    }

    /**
     * 生成新的深度数据（更真实的深度曲线）
     */
    private function generateNewDepthData(string $symbol, float $currentPrice, int $limit): array
    {
        // 生成买单深度（价格从高到低，低于当前价）
        $bids = [];
        $bidCumulativeQuantity = 0;

        for ($i = 0; $i < $limit; $i++) {
            // 价格递减：从 currentPrice * 0.9995 开始，每档递减 0.02%
            $price = $currentPrice * (0.9995 - $i * 0.0002);

            // 数量随机变化，离中心价格越远数量越大（模拟真实市场）
            // 基础数量 + 随机增量，越远的订单数量越多
            $baseQuantity = 50 + ($i * 5); // 50, 55, 60, 65...
            $randomQuantity = mt_rand(0, 50); // 0-50 的随机增量
            $quantity = $baseQuantity + $randomQuantity;

            $bidCumulativeQuantity += $quantity;

            $bids[] = [
                'price' => round($price, 2),
                'quantity' => round($quantity, 8),
                'cumulativeQuantity' => round($bidCumulativeQuantity, 8),
            ];
        }

        // 生成卖单深度（价格从低到高，高于当前价）
        $asks = [];
        $askCumulativeQuantity = 0;

        for ($i = 0; $i < $limit; $i++) {
            // 价格递增：从 currentPrice * 1.0005 开始，每档递增 0.02%
            $price = $currentPrice * (1.0005 + $i * 0.0002);

            // 数量随机变化，离中心价格越远数量越大
            $baseQuantity = 50 + ($i * 5);
            $randomQuantity = mt_rand(0, 50);
            $quantity = $baseQuantity + $randomQuantity;

            $askCumulativeQuantity += $quantity;

            $asks[] = [
                'price' => round($price, 2),
                'quantity' => round($quantity, 8),
                'cumulativeQuantity' => round($askCumulativeQuantity, 8),
            ];
        }

        return [
            'symbol' => $this->formatSymbolWithSlash($symbol),
            'bids' => $bids,
            'asks' => $asks,
            'lastPrice' => round($currentPrice, 2),
            'timestamp' => time() * 1000,
        ];
    }

    /**
     * 更新深度数据（实时波动）
     */
    private function updateDepthData(string $symbol, float $currentPrice, int $limit): void
    {
        if (!isset($this->depthCache[$symbol])) {
            $this->depthCache[$symbol] = $this->generateNewDepthData($symbol, $currentPrice, $limit);
            return;
        }

        // 每次都重新生成深度数据（模拟实时市场变化）
        // 这样可以让深度图看起来更动态
        $this->depthCache[$symbol] = $this->generateNewDepthData($symbol, $currentPrice, $limit);
    }
}

