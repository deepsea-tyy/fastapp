<?php

declare(strict_types=1);
namespace Plugin\Ds\SysCms\Repository;

use Plugin\Ds\SysCms\Model\PlacementPosition as Model;
use App\Repository\IRepository;
use Hyperf\Database\Model\Builder;
use App\Http\Admin\Service\Permission\DataScopeTool;

class PlacementPositionRepository extends IRepository
{
    public function __construct(protected readonly Model $model) {}

    public function handleSearch(Builder $query, array $params): Builder
    {
        // 应用数据权限过滤
        DataScopeTool::applyUserDataScope($params['created_by'], $query);
        return $query;
    }
}
