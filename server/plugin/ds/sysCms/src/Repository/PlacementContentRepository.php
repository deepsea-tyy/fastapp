<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Repository;

use Hyperf\Collection\Collection;
use Plugin\Ds\SysCms\Model\PlacementContent as Model;
use App\Repository\IRepository;
use Hyperf\Database\Model\Builder;
use App\Http\Admin\Service\Permission\DataScopeTool;
use Plugin\Ds\SysCms\Model\PlacementPositionContent;

class PlacementContentRepository extends IRepository
{
    public function __construct(protected readonly Model $model)
    {
    }

    public function handleSearch(Builder $query, array $params): Builder
    {
        // 应用数据权限过滤
        DataScopeTool::applyUserDataScope($params['created_by'], $query);
        if (!empty($params['position_id'])) {
            $query->whereIn('id', PlacementPositionContent::query()
                ->where(['position_id' => $params['position_id']])
                ->pluck('content_id')->toArray());
        }
        return $query->with(['positions']);
    }

    public function handleItems(Collection $items): Collection
    {
        foreach ($items as $item) {
            if ($item->positions->isEmpty()) continue;
            $item->position_id = $item->positions->pluck('id');
        }
        return $items;
    }
}
