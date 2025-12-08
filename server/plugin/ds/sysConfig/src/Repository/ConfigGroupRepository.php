<?php

declare(strict_types=1);


namespace Plugin\Ds\SysConfig\Repository;

use App\Repository\IRepository;
use Hyperf\Collection\Collection;
use Hyperf\Database\Model\Builder;
use Plugin\Ds\SysConfig\Model\ConfigGroup as Model;

/**
 * 参数配置分组表 Repository类.
 */
class ConfigGroupRepository extends IRepository
{
    public function __construct(
        protected readonly Model $model
    )
    {
    }

    public function handleSearch(Builder $query, array $params): Builder
    {
        $query->with('info');
        return parent::handleSearch($query, $params);
    }
}
