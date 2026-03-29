<?php

declare(strict_types=1);


namespace Plugin\Ds\SysConfig\Repository;

use App\Repository\IRepository;
use Hyperf\Database\Model\Builder;
use Plugin\Ds\SysConfig\Model\Config as Model;

/**
 * 参数配置表 Repository类.
 */
class ConfigRepository extends IRepository
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
