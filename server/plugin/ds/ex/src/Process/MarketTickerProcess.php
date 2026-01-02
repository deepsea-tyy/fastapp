<?php
/**
 * FastApp - Market Ticker Process
 * 市场行情数据模拟推送进程
 *
 * 策略：
 * 1. 每秒推送数据到 market:hot 房间和 market:{symbol} 房间
 * 2. 固定数据：价格固定为40000，成交量固定为50000000，不随机波动
 */

namespace Plugin\Ds\Ex\Process;

use Hyperf\Process\Annotation\Process;

#[Process(nums: 1, name: "MarketTickerProcess")]
class MarketTickerProcess extends AbstractMarketProcess
{
    /**
     * 热门币种列表（前20个）
     */
    private array $hotSymbols = [];

    /**
     * 价格缓存（用于模拟涨跌）
     */
    private array $priceCache = [];

    /**
     * 获取进程名称
     */
    protected function getProcessName(): string
    {
        return 'MarketTicker';
    }

    /**
     * 初始化进程数据
     */
    protected function initializeData(): void
    {
        // 初始化热门币种列表
        $this->hotSymbols = $this->allSymbols;

        // 初始化价格缓存
        foreach ($this->allSymbols as $symbol) {
            $basePrice = $this->basePrices[$symbol] ?? 40000;
            $this->priceCache[$symbol] = [
                'last_price' => $basePrice,
                'high_price' => $basePrice,
                'low_price' => $basePrice,
                'open_price' => $basePrice,
            ];
        }
    }

    /**
     * 推送数据
     */
    protected function pushData(int $currentTime): void
    {
        // 1. 推送热门币种
        $this->pushHotTickers();

        // 2. 推送单个订阅的币种
        $this->pushNormalTickers();
    }

    /**
     * 推送热门币种数据（每秒执行）
     */
    private function pushHotTickers(): void
    {
        $roomId = 'market:hot';

        // 检查房间是否有订阅者
        if (!$this->hasSubscribers($roomId)) {
            return;
        }

        // 生成热门币种的 ticker 数据
        $tickers = [];
        foreach ($this->hotSymbols as $symbol) {
            $tickers[] = $this->generateTickerData($symbol);
        }

        // 推送到热门房间
        $this->pushToRoom(
            roomId: $roomId,
            data: [
                'tickers' => $tickers,
                'timestamp' => time(),
            ],
            event: 'market.hot.tickers'
        );
    }

    /**
     * 推送普通币种数据（每秒执行，与K线推送频率同步）
     */
    private function pushNormalTickers(): void
    {
        // 遍历所有交易对，检查是否有订阅者
        foreach ($this->allSymbols as $symbol) {
            $roomId = "market:{$symbol}";
            $memberCount = $this->getRoomMemberCount($roomId);

            if ($memberCount === 0) {
                // 没有订阅者，跳过
                continue;
            }

            // 生成 ticker 数据
            $tickerData = $this->generateTickerData($symbol);

            // 推送日志
            $this->logPush($roomId, $memberCount, ['price' => $tickerData['last_price']]);

            // 推送给订阅了该交易对的用户
            $this->pushToRoom(
                roomId: $roomId,
                data: $tickerData,
                event: 'market.ticker'
            );
        }
    }

    /**
     * 生成模拟的 ticker 数据（前端计算涨跌幅）
     */
    private function generateTickerData(string $symbol): array
    {
        $currentPrice = $this->priceCache[$symbol]['last_price'] ?? 40000.00;
        $highPrice = $this->priceCache[$symbol]['high_price'] ?? $currentPrice * 1.05;
        $lowPrice = $this->priceCache[$symbol]['low_price'] ?? $currentPrice * 0.95;
        $openPrice = $this->priceCache[$symbol]['open_price'] ?? $currentPrice;

        // 模拟价格波动（±2%）
        $fluctuation = (mt_rand(-200, 200) / 10000); // -2% ~ +2%
        $newPrice = $currentPrice * (1 + $fluctuation);
        $newPrice = round($newPrice, 2);

        // 更新高低价
        if ($newPrice > $highPrice) {
            $highPrice = $newPrice;
        }
        if ($newPrice < $lowPrice) {
            $lowPrice = $newPrice;
        }

        // 模拟成交量和成交额
        $volume = mt_rand(1000000, 100000000);
        $amount = $volume * $newPrice;

        // 更新本地缓存
        $this->priceCache[$symbol] = [
            'last_price' => $newPrice,
            'high_price' => $highPrice,
            'low_price' => $lowPrice,
            'open_price' => $openPrice,
        ];

        return [
            'symbol' => $symbol,
            'last_price' => $newPrice,
            'open_price' => $openPrice,
            'high_price' => $highPrice,
            'low_price' => $lowPrice,
            'volume' => $volume,
            'amount' => $amount,
            'timestamp' => time(),
        ];
    }
}
