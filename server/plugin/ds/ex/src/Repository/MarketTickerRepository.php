<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Repository;

use Plugin\Ds\Ex\Model\MarketTicker as Model;
use App\Repository\IRepository;

class MarketTickerRepository extends IRepository
{
    public function __construct(protected readonly Model $model)
    {
    }

    /**
     * 根据symbol获取Ticker
     */
    public function getBySymbol(string $symbol): ?Model
    {
        return $this->model->where('symbol', $symbol)->first();
    }

    /**
     * 批量更新或创建Ticker数据
     */
    public function upsertBatch(array $data): void
    {
        foreach ($data as $item) {
            $this->model->updateOrCreate(
                ['symbol' => $item['symbol']],
                $item
            );
        }
    }

    /**
     * 获取所有启用的Ticker数据
     */
    public function getAllActive(): array
    {
        return $this->model->orderBy('volume', 'desc')->get()->toArray();
    }
}
