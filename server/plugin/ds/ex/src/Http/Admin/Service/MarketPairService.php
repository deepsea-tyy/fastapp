<?php

declare(strict_types=1);
namespace Plugin\Ds\Ex\Http\Admin\Service;

use App\Common\IService;
use Plugin\Ds\Ex\Repository\MarketPairRepository as Repository;
use Plugin\Ds\Ex\Model\Currency;

class MarketPairService extends IService
{
    public function __construct(
        protected readonly Repository $repository
    ) {}

    /**
     * 根据 base_currency_symbol 和 quote_currency_symbol 拼接 symbol
     */
    protected function buildSymbol(array $data): ?string
    {
        if (!isset($data['base_currency_symbol']) || !isset($data['quote_currency_symbol'])) {
            return null;
        }

        return $data['base_currency_symbol'] . $data['quote_currency_symbol'];
    }

    /**
     * 创建交易对
     */
    public function create(array $data): mixed
    {
        // 如果提供了 base_currency_symbol 和 quote_currency_symbol，自动拼接 symbol
        if (isset($data['base_currency_symbol']) && isset($data['quote_currency_symbol'])) {
            $symbol = $this->buildSymbol($data);
            if ($symbol) {
                $data['symbol'] = $symbol;
            }
        }

        return parent::create($data);
    }

    /**
     * 更新交易对
     */
    public function updateById(mixed $id, array $data): mixed
    {
        // 如果更新了 base_currency_symbol 或 quote_currency_symbol，需要重新拼接 symbol
        if (isset($data['base_currency_symbol']) || isset($data['quote_currency_symbol'])) {
            // 获取现有数据
            $existing = $this->repository->findById($id);
            if ($existing) {
                // 如果只更新了其中一个，使用现有的另一个
                if (!isset($data['base_currency_symbol'])) {
                    $data['base_currency_symbol'] = $existing->base_currency_symbol;
                }
                if (!isset($data['quote_currency_symbol'])) {
                    $data['quote_currency_symbol'] = $existing->quote_currency_symbol;
                }

                // 重新拼接 symbol
                $symbol = $this->buildSymbol($data);
                if ($symbol) {
                    $data['symbol'] = $symbol;
                }
            }
        }

        return parent::updateById($id, $data);
    }
}
