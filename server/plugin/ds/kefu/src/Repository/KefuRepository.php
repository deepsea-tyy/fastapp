<?php

declare(strict_types=1);

namespace Plugin\Ds\Kefu\Repository;

use App\Repository\IRepository;
use Hyperf\Collection\Arr;
use Hyperf\Database\Model\Builder;
use Plugin\Ds\Kefu\Model\Kefu as Model;

/**
 * 客服表 Repository类
 */
class KefuRepository extends IRepository
{
    public function __construct(
        protected readonly Model $model
    )
    {
    }

    /**
     * 搜索处理器
     * @param Builder $query
     * @param array $params
     * @return Builder
     */
    public function handleSearch(Builder $query, array $params): Builder
    {
        if (isset($params['status'])) {
            $query->where('status', $params['status']);
        }
        if (isset($params['created_by'])) {
            $query->where('created_by', $params['created_by']);
        }
        return $query;
    }
}
