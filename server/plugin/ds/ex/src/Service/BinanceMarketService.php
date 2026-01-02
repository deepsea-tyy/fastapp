<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Service;

use Hyperf\Guzzle\ClientFactory;
use Plugin\Ds\Ex\Repository\MarketTickerRepository;
use Psr\Log\LoggerInterface;

/**
 * Binance数据源服务
 */
class BinanceMarketService
{
    private const API_BASE_URL = 'https://api.binance.com';

    public function __construct(
        private readonly ClientFactory $clientFactory,
        private readonly MarketTickerRepository $tickerRepository,
        private readonly LoggerInterface $logger
    ) {
    }

    /**
     * 获取并更新所有Ticker数据
     */
    public function fetchAndUpdateTickers(): void
    {
        try {
            $client = $this->clientFactory->create();

            // 调用Binance API获取24小时ticker数据
            $response = $client->get(self::API_BASE_URL . '/api/v3/ticker/24hr');
            $data = json_decode((string) $response->getBody(), true);

            if (!is_array($data)) {
                $this->logger->error('Binance API返回数据格式错误');
                return;
            }

            // 转换数据格式
            $tickers = [];
            foreach ($data as $item) {
                // 只处理USDT交易对
                if (!str_ends_with($item['symbol'], 'USDT')) {
                    continue;
                }

                $tickers[] = $this->transformBinanceData($item);
            }

            // 批量更新到数据库
            if (!empty($tickers)) {
                $this->tickerRepository->upsertBatch($tickers);
                $this->logger->info('更新Ticker数据成功', ['count' => count($tickers)]);
            }
        } catch (\Throwable $e) {
            $this->logger->error('获取Binance数据失败: ' . $e->getMessage());
        }
    }

    /**
     * 获取单个交易对的Ticker数据
     */
    public function fetchTickerBySymbol(string $symbol): ?array
    {
        try {
            $client = $this->clientFactory->create();

            $response = $client->get(self::API_BASE_URL . '/api/v3/ticker/24hr', [
                'query' => ['symbol' => strtoupper($symbol)]
            ]);

            $data = json_decode((string) $response->getBody(), true);

            if (!is_array($data)) {
                return null;
            }

            return $this->transformBinanceData($data);
        } catch (\Throwable $e) {
            $this->logger->error('获取Binance Ticker失败: ' . $e->getMessage());
            return null;
        }
    }

    /**
     * 转换Binance数据格式为内部格式
     */
    private function transformBinanceData(array $data): array
    {
        $lastPrice = (float) ($data['lastPrice'] ?? 0);
        $openPrice = (float) ($data['openPrice'] ?? 0);

        // 计算涨跌额和涨跌幅
        $changeAmount = $lastPrice - $openPrice;
        $changePercent = $openPrice > 0 ? ($changeAmount / $openPrice) * 100 : 0;

        return [
            'symbol' => $data['symbol'] ?? '',
            'last_price' => $lastPrice,
            'open_price' => $openPrice,
            'high_price' => (float) ($data['highPrice'] ?? 0),
            'low_price' => (float) ($data['lowPrice'] ?? 0),
            'volume' => (float) ($data['volume'] ?? 0),
            'amount' => (float) ($data['quoteVolume'] ?? 0),
            'quote_volume' => (float) ($data['quoteVolume'] ?? 0),
            'change_percent' => round($changePercent, 4),
            'change_amount' => $changeAmount,
            'bid_price' => (float) ($data['bidPrice'] ?? 0),
            'bid_quantity' => (float) ($data['bidQty'] ?? 0),
            'ask_price' => (float) ($data['askPrice'] ?? 0),
            'ask_quantity' => (float) ($data['askQty'] ?? 0),
            'count' => (int) ($data['count'] ?? 0),
            'timestamp' => (int) ($data['closeTime'] ?? time() * 1000),
        ];
    }

    /**
     * 获取交易对列表（从Binance）
     */
    public function fetchExchangeInfo(): array
    {
        try {
            $client = $this->clientFactory->create();

            $response = $client->get(self::API_BASE_URL . '/api/v3/exchangeInfo');
            $data = json_decode((string) $response->getBody(), true);

            if (!isset($data['symbols']) || !is_array($data['symbols'])) {
                return [];
            }

            $pairs = [];
            foreach ($data['symbols'] as $symbol) {
                // 只处理USDT交易对且状态为TRADING的
                if ($symbol['quoteAsset'] !== 'USDT' || $symbol['status'] !== 'TRADING') {
                    continue;
                }

                $pairs[] = [
                    'symbol' => $symbol['symbol'],
                    'base_currency_symbol' => $symbol['baseAsset'],
                    'quote_currency_symbol' => $symbol['quoteAsset'],
                    'market_type' => 'spot',
                    'price_precision' => $symbol['quotePrecision'] ?? 2,
                    'quantity_precision' => $symbol['baseAssetPrecision'] ?? 8,
                    'status' => $symbol['status'] === 'TRADING' ? 1 : 0,
                ];
            }

            return $pairs;
        } catch (\Throwable $e) {
            $this->logger->error('获取Binance交易对列表失败: ' . $e->getMessage());
            return [];
        }
    }
}
