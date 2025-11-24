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

    public function handleSearch(Builder $query, array $params): Builder
    {
        return parent::handleSearch($query, $params);
    }
}
