<?php
/**
 * FastApp.
 * 1/1/26
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace Plugin\Ds\Ex\Http\Api\Controller;

use App\Common\AbstractController;
use App\Common\Result;
use App\Common\Swagger\ResultResponse;
use App\Common\Tools;
use App\Http\CurrentUser;
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\HyperfServer;
use Hyperf\Swagger\Annotation\QueryParameter;
use OpenApi\Attributes\Tag;
use Plugin\Ds\Ex\Repository\SpotKlineRepository;
use Plugin\Ds\Ex\Repository\MarketTickerRepository;
use Plugin\Ds\Ex\Model\MarketPair;

#[Tag(name: "市场数据")]
#[HyperfServer(name: 'http')]
class MarketDataController extends AbstractController
{
    public function __construct(
        protected readonly SpotKlineRepository    $klineRepository,
        protected readonly MarketTickerRepository $tickerRepository,
        protected readonly CurrentUser            $currentUser
    )
    {
    }

    /**
     * 获取现货K线数据（币安格式）
     * 参考币安API: GET /api/v3/klines
     * 支持分片表查询和分页
     *
     * @return Result
     */
    #[Get(path: '/api/market/klineTrade', operationId: 'ExMarketKlineTrade', summary: '现货K线数据', tags: ['市场数据'])]
    #[QueryParameter(name: 'symbol', description: '交易对符号', required: true, example: 'BTCUSDT')]
    #[QueryParameter(name: 'interval', description: '时间周期', required: false, example: '1m')]
    #[QueryParameter(name: 'page', description: '页码（从1开始）', required: false, example: '1')]
    #[QueryParameter(name: 'page_size', description: '每页数量（1-1000，默认100）', required: false, example: '100')]
    #[QueryParameter(name: 'format', description: '返回格式（binance:币安格式数组, object:对象格式，默认binance）', required: false, example: 'binance')]
    #[ResultResponse(instance: new Result())]
    public function klineTrade(): Result
    {
        $params = $this->getRequestData();

        // 获取参数
        $symbol = $params['symbol'] ?? '';
        $interval = $params['interval'] ?? '1m';
        $page = $this->getPage();
        $pageSize = $this->getPageSize();
        $format = $params['format'] ?? 'binance';

        // 验证必填参数
        if (empty($symbol)) {
            return $this->error('Symbol is required');
        }

        // 验证时间周期
        $validIntervals = ['1s', '1m', '3m', '5m', '15m', '30m', '1h', '2h', '4h', '6h', '8h', '12h', '1d', '3d', '1w', '1M'];
        if (!in_array($interval, $validIntervals)) {
            return $this->error("Invalid interval: {$interval}");
        }

        // 验证分页参数
        if ($page < 1) {
            return $this->error('Page must be greater than 0');
        }
        if ($pageSize < 1 || $pageSize > 1000) {
            return $this->error('Page size must be between 1 and 1000');
        }

        try {
            // 验证交易对是否存在
            $pair = MarketPair::query()
                ->where('symbol', $symbol)
                ->where('market_type', 'spot')
                ->where('status', 1)
                ->first();

            if (!$pair) {
                return $this->success([]);
            }

            // 如果是1s周期，从Redis获取数据
            if ($interval === '1s') {
                $klines = $this->getKlines1sFromRedis($symbol, $pageSize);
                return $this->success($this->formatKlines($klines, $format, true));
            }

            // 从分片表中获取K线数据
            $klines = $this->klineRepository->getKlines(
                $symbol,
                $interval,
                $page,
                $pageSize
            );

            return $this->success($this->formatKlines($klines, $format));
        } catch (\Throwable $e) {
            return $this->error('Failed to get kline data: ' . $e->getMessage());
        }
    }

    /**
     * 获取合约K线数据（币安格式）
     * 参考币安API: GET /fapi/v1/klines
     * 支持分片表查询和分页
     *
     * @return Result
     */
    #[Get(path: '/api/market/futuresKlineTrade', operationId: 'ExMarketFuturesKlineTrade', summary: '合约K线数据', tags: ['市场数据'])]
    #[QueryParameter(name: 'symbol', description: '交易对符号', required: true, example: 'BTCUSDT')]
    #[QueryParameter(name: 'interval', description: '时间周期', required: false, example: '1m')]
    #[QueryParameter(name: 'page', description: '页码（从1开始）', required: false, example: '1')]
    #[QueryParameter(name: 'page_size', description: '每页数量（1-1000，默认100）', required: false, example: '100')]
    #[QueryParameter(name: 'format', description: '返回格式（binance:币安格式数组, object:对象格式，默认binance）', required: false, example: 'binance')]
    #[ResultResponse(instance: new Result())]
    public function futuresKlineTrade(): Result
    {
        $params = $this->getRequestData();

        // 获取参数
        $symbol = $params['symbol'] ?? '';
        $interval = $params['interval'] ?? '1m';
        $page = $this->getPage();
        $pageSize = $this->getPageSize();
        $format = $params['format'] ?? 'binance';

        // 验证必填参数
        if (empty($symbol)) {
            return $this->error('Symbol is required');
        }

        // 验证时间周期
        $validIntervals = ['1m', '3m', '5m', '15m', '30m', '1h', '2h', '4h', '6h', '8h', '12h', '1d', '3d', '1w', '1M'];
        if (!in_array($interval, $validIntervals)) {
            return $this->error("Invalid interval: {$interval}");
        }

        // 验证分页参数
        if ($page < 1) {
            return $this->error('Page must be greater than 0');
        }
        if ($pageSize < 1 || $pageSize > 1000) {
            return $this->error('Page size must be between 1 and 1000');
        }

        try {
            // 验证交易对是否存在
            $pair = MarketPair::query()
                ->where('symbol', $symbol)
                ->where('market_type', 'futures')
                ->where('status', 1)
                ->first();

            if (!$pair) {
                return $this->success([]);
            }

            // 从分片表中获取K线数据（合约暂时使用现货Repository，后续可扩展）
            $klines = $this->klineRepository->getKlines(
                $symbol,
                $interval,
                $page,
                $pageSize
            );

            return $this->success($this->formatKlines($klines, $format));
        } catch (\Throwable $e) {
            return $this->error('Failed to get futures kline data: ' . $e->getMessage());
        }
    }

    /**
     * 获取深度图数据（订单簿）
     * 参考币安API: GET /api/v3/depth
     *
     * @return Result
     */
    #[Get(path: '/api/market/depth', operationId: 'ExMarketDepth', summary: '深度图数据', tags: ['市场数据'])]
    #[QueryParameter(name: 'symbol', description: '交易对符号', required: true, example: 'BTCUSDT')]
    #[QueryParameter(name: 'limit', description: '深度数量（5, 10, 20, 50, 100, 500, 1000，默认20）', required: false, example: '20')]
    #[ResultResponse(instance: new Result())]
    public function depthTrade(): Result
    {
        $params = $this->getRequestData();

        // 获取参数
        $symbol = $params['symbol'] ?? '';
        $limit = isset($params['limit']) ? (int)$params['limit'] : 20;

        // 验证必填参数
        if (empty($symbol)) {
            return $this->error('Symbol is required');
        }

        // 验证 limit 参数
        $validLimits = [5, 10, 20, 50, 100, 500, 1000];
        if (!in_array($limit, $validLimits)) {
            $limit = 20; // 默认值
        }

        try {
            // 生成模拟深度数据
            $depthData = $this->generateDepthData($symbol, $limit);

            return $this->success($depthData);
        } catch (\Throwable $e) {
            return $this->error('Failed to get depth data: ' . $e->getMessage());
        }
    }

    /**
     * 生成模拟深度数据
     *
     * @param string $symbol 交易对符号
     * @param int $limit 深度数量
     * @return array
     */
    private function generateDepthData(string $symbol, int $limit): array
    {
        // 从 Ticker 数据获取当前价格
        $ticker = $this->tickerRepository->getBySymbol($symbol);
        if ($ticker && $ticker->last_price) {
            $currentPrice = (float)$ticker->last_price;
        } else {
            // 如果没有 ticker 数据，使用基础价格
            $basePrices = [
                'BTCUSDT' => 50000,
                'ETHUSDT' => 3000,
                'BNBUSDT' => 400,
                'XRPUSDT' => 0.6,
                'ADAUSDT' => 0.5,
                'SOLUSDT' => 120,
                'DOGEUSDT' => 0.08,
                'DOTUSDT' => 8,
                'MATICUSDT' => 1.2,
                'SHIBUSDT' => 0.00001,
            ];
            $currentPrice = $basePrices[$symbol] ?? 100.0;
        }

        // 生成买单深度（价格从高到低，低于当前价）
        $bids = [];
        $bidPrice = $currentPrice * 0.999; // 从略低于当前价开始
        $bidCumulativeQuantity = 0;

        for ($i = 0; $i < $limit; $i++) {
            $price = $bidPrice - ($i * $currentPrice * 0.0001); // 价格递减
            $quantity = mt_rand(100, 10000) / 100; // 随机数量
            $bidCumulativeQuantity += $quantity;

            $bids[] = [
                'price' => round($price, 2),
                'quantity' => round($quantity, 8),
                'cumulativeQuantity' => round($bidCumulativeQuantity, 8),
            ];
        }

        // 生成卖单深度（价格从低到高，高于当前价）
        $asks = [];
        $askPrice = $currentPrice * 1.001; // 从略高于当前价开始
        $askCumulativeQuantity = 0;

        for ($i = 0; $i < $limit; $i++) {
            $price = $askPrice + ($i * $currentPrice * 0.0001); // 价格递增
            $quantity = mt_rand(100, 10000) / 100; // 随机数量
            $askCumulativeQuantity += $quantity;

            $asks[] = [
                'price' => round($price, 2),
                'quantity' => round($quantity, 8),
                'cumulativeQuantity' => round($askCumulativeQuantity, 8),
            ];
        }

        return [
            'symbol' => $symbol,
            'bids' => $bids,
            'asks' => $asks,
            'lastPrice' => round($currentPrice, 2),
            'timestamp' => time() * 1000,
        ];
    }

    /**
     * 将数据库格式转换为币安格式
     * 币安格式：[openTime, open, high, low, close, volume, closeTime, quoteVolume, trades, takerBuyBaseVolume, takerBuyQuoteVolume, ignore]
     *
     * @param array $klines 数据库K线数据
     * @return array
     */
    private function formatKlinesToBinanceFormat(array $klines): array
    {
        $result = [];

        foreach ($klines as $kline) {
            $result[] = [
                (int)(strtotime($kline['open_time']) * 1000), // openTime (毫秒时间戳)
                (string)$kline['open_price'],                   // open
                (string)$kline['high_price'],                  // high
                (string)$kline['low_price'],                   // low
                (string)$kline['close_price'],                 // close
                (string)$kline['volume'],                      // volume
                (int)(strtotime($kline['close_time']) * 1000), // closeTime (毫秒时间戳)
                (string)$kline['quote_volume'],               // quoteVolume
                (int)$kline['trade_count'],                    // trades
                (string)$kline['taker_buy_volume'],            // takerBuyBaseVolume
                (string)$kline['taker_buy_quote_volume'],      // takerBuyQuoteVolume
                '0',                                           // ignore (忽略字段)
            ];
        }

        return $result;
    }

    /**
     * 将数据库格式转换为对象格式
     *
     * @param array $klines 数据库K线数据
     * @return array
     */
    private function formatKlinesAsObjects(array $klines): array
    {
        $result = [];
        foreach ($klines as $kline) {
            $result[] = [
                'timestamp' => (int)(strtotime($kline['open_time']) * 1000),
                'open' => (float)$kline['open_price'],
                'high' => (float)$kline['high_price'],
                'low' => (float)$kline['low_price'],
                'close' => (float)$kline['close_price'],
                'volume' => (float)$kline['volume'],
                'amount' => (float)$kline['quote_volume'],
                'trades' => (int)$kline['trade_count'],
                'takerBuyBaseVolume' => (float)$kline['taker_buy_volume'],
                'takerBuyQuoteVolume' => (float)$kline['taker_buy_quote_volume'],
            ];
        }

        return $result;
    }

    /**
     * 统一格式化K线数据
     *
     * @param array $klines K线数据
     * @param string $format 格式（binance 或 object）
     * @param bool $isObject 数据是否已经是对象格式（从Redis读取的1s数据）
     * @return array
     */
    private function formatKlines(array $klines, string $format, bool $isObject = false): array
    {
        // 如果数据已经是对象格式（从Redis读取）
        if ($isObject) {
            if ($format === 'binance') {
                return $this->formatObjectsToBinanceFormat($klines);
            }
            // 对象格式直接返回
            return $klines;
        }

        // 从数据库读取的数据，按照原有逻辑处理
        if ($format === 'object') {
            return $this->formatKlinesAsObjects($klines);
        }

        // 默认返回币安格式
        return $this->formatKlinesToBinanceFormat($klines);
    }

    /**
     * 将对象格式转换为币安格式
     * 用于从Redis读取的1s数据
     *
     * @param array $klines 对象格式的K线数据
     * @return array
     */
    private function formatObjectsToBinanceFormat(array $klines): array
    {
        $result = [];

        foreach ($klines as $kline) {
            $result[] = [
                (int)$kline['timestamp'],              // openTime (毫秒时间戳)
                (string)$kline['open'],                // open
                (string)$kline['high'],                // high
                (string)$kline['low'],                 // low
                (string)$kline['close'],               // close
                (string)$kline['volume'],              // volume
                (int)$kline['timestamp'],              // closeTime (与openTime相同)
                (string)($kline['amount'] ?? 0),       // quoteVolume
                0,                                     // trades (1s数据暂不统计)
                '0',                                   // takerBuyBaseVolume
                '0',                                   // takerBuyQuoteVolume
                '0',                                   // ignore (忽略字段)
            ];
        }

        return $result;
    }

    /**
     * 从Redis获取1s周期K线数据（支持分页）
     *
     * @param string $symbol 交易对符号
     * @param int $pageSize 每页数量
     * @return array
     * @throws \RedisException
     */
    private function getKlines1sFromRedis(string $symbol, int $pageSize): array
    {
        $key = "kline:1s:{$symbol}";
        $data = Tools::getRedis()->zRevRange($key, 0, $pageSize - 1);

        $klines = [];
        foreach ($data as $item) {
            $kline = json_decode($item, true);
            if ($kline) {
                $klines[] = $kline;
            }
        }

        // 按时间戳正序排序（最早的在前）
        usort($klines, function ($a, $b) {
            return ($a['timestamp'] ?? 0) <=> ($b['timestamp'] ?? 0);
        });

        return $klines;
    }
}