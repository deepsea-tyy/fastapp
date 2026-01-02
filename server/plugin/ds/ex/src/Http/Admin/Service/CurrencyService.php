<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Http\Admin\Service;

use App\Common\IService;
use App\Common\Tools;
use App\Exception\BusinessException;
use Nette\Utils\FileSystem;
use Plugin\Ds\Ex\Repository\CurrencyRepository as Repository;
use Plugin\Ds\Ex\Model\Currency;
use Plugin\Ds\Ex\Model\MarketPair;
use Plugin\Ds\SysConfig\Helper\CacheConfigHelper;

class CurrencyService extends IService
{
    public function __construct(
        protected readonly Repository $repository
    )
    {
    }


    public function selectCurrency(array $params): array
    {
        $query = $this->repository->getQuery();
        if ($params) $this->repository->perQuery($query, $params);
        return $query->get(['id', 'symbol'])->map(function ($item) {
            return ['label' => $item->symbol, 'value' => $item->symbol];
        })->toArray();
    }

    /**
     * 生成币种和交易对的 JSON 文件（扁平化结构）
     *
     * @return array 返回生成结果
     */
    public function generateJson(): array
    {
        try {
            // 1. 获取所有启用的币种（扁平化，直接按 symbol 索引）
            $currencies = Currency::query()
                ->select([
                    'id', 'symbol', 'name', 'logo', 'chain', 'contract_address',
                    'type', 'decimals', 'is_base_currency', 'is_quote_currency',
                    'status', 'min_deposit_amount', 'min_withdraw_amount',
                    'withdraw_fee', 'withdraw_fee_type', 'is_hot', 'is_recommended',
                ])
                ->where('status', 1)
                ->whereNotIn('type', [2])
                ->orderByDesc('sort')->get();

            $currenciesData = $chain = [];
            foreach ($currencies as $currency) {
                $currency->name = array_column($currency->name, 'text', 'lang');
                $currency->chain = $currency->chain ?? '';
                if ($currency->is_base_currency) {
                    $currency->chain = $currency->symbol;
                }else if ($currency->chain) {
                    $chain[] = $currency->chain;
                }
                $currenciesData[$currency->symbol] = $currency->toArray();
            }

            // 2. 获取现货交易对（扁平化，直接按 symbol 索引）
            $spotPairs = MarketPair::query()
                ->select([
                    'symbol', 'base_currency_symbol', 'quote_currency_symbol',
                    'price_precision', 'quantity_precision', 'min_quantity',
                    'min_amount', 'maker_fee_rate', 'taker_fee_rate', 'status',
                    'is_hot', 'is_recommended',
                ])
                ->where('market_type', 'spot')
                ->where('status', 1)
                ->orderByDesc('sort')->get();

            $spotPairsData = [];
            foreach ($spotPairs as $pair) {
                $pair->chain = $currenciesData[$pair->base_currency_symbol]['chain'] ?? '';
                $spotPairsData[$pair->symbol] = $pair->toArray();
            }

            // 3. 获取合约交易对（扁平化，直接按 symbol 索引）
            $futuresPairs = MarketPair::query()
                ->select([
                    'symbol', 'base_currency_symbol', 'quote_currency_symbol',
                    'settlement_currency_symbol', 'price_precision',
                    'quantity_precision', 'min_quantity', 'min_amount',
                    'maker_fee_rate', 'taker_fee_rate', 'leverage_enabled',
                    'max_leverage', 'contract_multiplier', 'status',
                    'is_hot', 'is_recommended',
                ])
                ->where('market_type', 'futures')
                ->where('status', 1)
                ->orderByDesc('sort')->get();

            $futuresPairsData = [];
            foreach ($futuresPairs as $pair) {
                $pair->chain = $currenciesData[$pair->base_currency_symbol]['chain'] ?? '';
                $futuresPairsData[$pair->symbol] = $pair->toArray();
            }

            // 4. 获取期权交易对（扁平化，直接按 symbol 索引）
            $optionPairs = MarketPair::query()
                ->select([
                    'symbol', 'base_currency_symbol', 'quote_currency_symbol',
                    'settlement_currency_symbol', 'underlying_asset_symbol',
                    'option_type', 'strike_price', 'expiry_date', 'price_precision',
                    'quantity_precision', 'min_quantity', 'min_amount',
                    'maker_fee_rate', 'taker_fee_rate', 'status',
                    'is_hot', 'is_recommended',
                ])
                ->where('market_type', 'option')
                ->where('status', 1)
                ->orderByDesc('sort')->get();

            $optionPairsData = [];
            foreach ($optionPairs as $pair) {
                $pair->chain = $currenciesData[$pair->base_currency_symbol]['chain'] ?? '';
                $optionPairsData[$pair->symbol] = $pair->toArray();
            }

            $token_standard = CacheConfigHelper::getConfigByKey('token_standard')['config_select_data'];
            // 5. 组装 JSON 数据（扁平化结构）
            $jsonData = [
                'version' => time(), // 添加版本号，用于客户端判断是否需要更新
                'chain' => array_unique($chain),
                'token_standard' => $token_standard,
                'currency' => $currenciesData,  // 扁平化：{'BTC': {...}, 'ETH': {...}}
                'spot' => $spotPairsData,       // 扁平化：{'BTCUSDT': {...}, 'ETHUSDT': {...}}
                'futures' => $futuresPairsData, // 扁平化：{'BTCUSDT': {...}, 'ETHUSDT': {...}}
                'option' => $optionPairsData,   // 扁平化：{'BTCUSDT': {...}, 'ETHUSDT': {...}}
            ];

            // 6. 确保目录存在
            $storagePath = BASE_PATH . '/storage/app/ex';
            if (!is_dir($storagePath)) {
                mkdir($storagePath, 0755, true);
            }
            // 7. 写入 JSON 文件
            $filePath = $storagePath . '/market_data.json';
            $json = json_encode($jsonData, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
            FileSystem::write($filePath, $json);
            Tools::getRedis()->set('market_data', $json);
            return [
                'success' => true,
                'file_path' => $filePath,
                'currencies_count' => count($currenciesData),
                'spot_pairs_count' => count($spotPairsData),
                'futures_pairs_count' => count($futuresPairsData),
                'option_pairs_count' => count($optionPairsData),
                'message' => 'JSON 文件生成成功',
            ];
        } catch (\Exception $e) {
            throw new BusinessException(message: 'JSON 生成失败: ' . $e->getMessage());
        }
    }

    /**
     * 为稳定币或法币创建所有交易对（批量分片插入）
     *
     * @param int $currencyId 稳定币或法币ID（type=1或2）
     * @param string $marketType 市场类型，默认为 'spot'
     * @param int $chunkSize 每批插入的数量，默认100
     * @return array 返回创建结果统计
     */
    public function createPair(int $currencyId, string $marketType = 'spot', int $chunkSize = 100): array
    {
        // 1. 验证币种是否存在且是稳定币或法币
        $quoteCurrency = Currency::find($currencyId);
        if (!$quoteCurrency) {
            throw new BusinessException(message: "币种不存在，ID: {$currencyId}");
        }

        if (!in_array($quoteCurrency->type, [1, 2], true)) {
            throw new BusinessException(message: "币种类型错误，必须是稳定币(type=1)或法币(type=2)，当前类型: {$quoteCurrency->type}");
        }

        // 2. 获取所有可以作为基础货币的币种（启用状态，排除计价币种和自身）
        $baseCurrencies = Currency::query()
            ->where('status', 1)
            ->where('id', '!=', $currencyId) // 排除自己
            ->where('is_quote_currency', '!=', 1) // 排除计价币种
            ->whereNotIn('type', [1, 2])
            ->get(['id', 'symbol']);

        // 3. 查询已存在的交易对，避免重复插入
        $quoteCurrencySymbol = $quoteCurrency->symbol;
        $existingPairs = MarketPair::where('quote_currency_symbol', $quoteCurrencySymbol)
            ->where('market_type', $marketType)
            ->whereIn('base_currency_symbol', $baseCurrencies->pluck('symbol')->toArray())
            ->pluck('base_currency_symbol')
            ->toArray();
        $existingPairsSet = array_flip($existingPairs);
        $skippedCount = count($existingPairs);

        // 4. 准备要插入的数据
        $insertData = [];
        $now = date('Y-m-d H:i:s');
        foreach ($baseCurrencies as $baseCurrency) {
            // 跳过已存在的交易对
            if (isset($existingPairsSet[$baseCurrency->symbol])) {
                continue;
            }

            // 构建交易对符号
            $symbol = $baseCurrency->symbol . $quoteCurrency->symbol;

            // 准备交易对数据，填充默认值
            $insertData[] = [
                'symbol' => $symbol,
                'base_currency_symbol' => $baseCurrency->symbol,
                'quote_currency_symbol' => $quoteCurrency->symbol,
                'market_type' => $marketType,
                'settlement_currency_symbol' => $marketType === 'futures' ? $quoteCurrency->symbol : null,
                'price_precision' => 2,
                'quantity_precision' => 8,
                'min_quantity' => 0,
                'min_amount' => 0,
                'maker_fee_rate' => 0.001,
                'taker_fee_rate' => 0.001,
                'leverage_enabled' => $marketType == 'futures' ? 1 : 0,
                'max_leverage' => $marketType == 'futures' ? 50 : 1,
                'contract_multiplier' => 1,
                'status' => 1,
                'is_hot' => 0,
                'is_recommended' => 0,
                'sort' => 100,
                'created_at' => $now,
                'updated_at' => $now,
            ];
        }

        if (empty($insertData)) {
            return [
                'success' => 0,
                'skipped' => $skippedCount,
                'failed' => 0,
                'total' => $baseCurrencies->count(),
                'message' => "所有交易对已存在，跳过 {$skippedCount} 个",
            ];
        }

        // 5. 批量分片插入
        $successCount = 0;
        $failedCount = 0;
        $chunks = array_chunk($insertData, $chunkSize);

        foreach ($chunks as $chunk) {
            try {
                // 使用批量插入
                MarketPair::insert($chunk);
                $successCount += count($chunk);
            } catch (\Exception $e) {
                // 如果批量插入失败，尝试逐条插入以识别具体失败项
                if (str_contains($e->getMessage(), 'Duplicate entry') || str_contains($e->getMessage(), 'UNIQUE constraint')) {
                    // 唯一索引冲突，逐条插入以跳过已存在的
                    foreach ($chunk as $item) {
                        try {
                            MarketPair::insert([$item]);
                            $successCount++;
                        } catch (\Exception $itemException) {
                            if (str_contains($itemException->getMessage(), 'Duplicate entry') || str_contains($itemException->getMessage(), 'UNIQUE constraint')) {
                                $skippedCount++;
                            } else {
                                $failedCount++;
                                \Hyperf\Support\make(\Hyperf\Logger\LoggerFactory::class)->get()->error(
                                    "创建交易对失败: {$item['symbol']}",
                                    ['error' => $itemException->getMessage()]
                                );
                            }
                        }
                    }
                } else {
                    // 其他错误，记录并计入失败
                    $failedCount += count($chunk);
                    \Hyperf\Support\make(\Hyperf\Logger\LoggerFactory::class)->get()->error(
                        "批量创建交易对失败",
                        ['error' => $e->getMessage(), 'count' => count($chunk)]
                    );
                }
            }
        }

        return [
            'success' => $successCount,
            'skipped' => $skippedCount,
            'failed' => $failedCount,
            'total' => $baseCurrencies->count(),
            'message' => "成功创建 {$successCount} 个交易对，跳过 {$skippedCount} 个，失败 {$failedCount} 个",
        ];
    }
}
