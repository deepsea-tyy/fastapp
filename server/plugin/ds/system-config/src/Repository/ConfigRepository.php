<?php

declare(strict_types=1);


namespace Plugin\Ds\SystemConfig\Repository;

use App\Repository\IRepository;
use Hyperf\Database\Model\Builder;
use Plugin\Ds\SystemConfig\Model\Config as Model;

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

    /**
     * 搜索处理器.
     */
    public function handleSearch(Builder $query, array $params): Builder
    {
        if (isset($params['group_code'])) {
            $query->where('group_code', '=', $params['group_code']);
        }

        return $query;
    }
}
