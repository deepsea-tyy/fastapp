<?php

declare(strict_types=1);


namespace Plugin\Ds\SystemConfig\Repository;

use App\Repository\IRepository;
use Hyperf\Collection\Collection;
use Hyperf\Database\Model\Builder;
use Plugin\Ds\SystemConfig\Model\ConfigGroup as Model;

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

    /**
     * 搜索处理器.
     */
    public function handleSearch(Builder $query, array $params): Builder
    {
        $query->with('info');
        return $query;
    }
}
