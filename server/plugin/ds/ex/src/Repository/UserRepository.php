<?php

declare(strict_types=1);
namespace Plugin\Ds\Ex\Repository;

use Plugin\Ds\Ex\Model\User as Model;
use App\Repository\IRepository;
use Hyperf\Database\Model\Builder;
use App\Http\Admin\Service\Permission\DataScopeTool;

class UserRepository extends IRepository
{
    public function __construct(protected readonly Model $model) {}

    public function handleSearch(Builder $query, array $params): Builder
    {
        // 应用数据权限过滤
        DataScopeTool::applyUserDataScope($params['created_by'], $query);
        unset($params['created_by']);
        return parent::handleSearch($query, $params);
    }
}
