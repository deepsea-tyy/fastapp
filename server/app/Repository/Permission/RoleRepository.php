<?php

declare(strict_types=1);


namespace App\Repository\Permission;

use App\Model\Permission\Role;
use App\Repository\IRepository;
use Hyperf\Collection\Collection;
use Hyperf\Database\Model\Builder;

final class RoleRepository extends IRepository
{
    public function __construct(
        protected readonly Role $model
    )
    {
    }

    public function handleSearch(Builder $query, array $params): Builder
    {
        $query->with(['dept']);
        return parent::handleSearch($query, $params);
    }

    public function handleItems(Collection $items): Collection
    {
        foreach ($items as $item) {
            $item->dept_id = $item->dept->pluck('dept_id')->toArray();
        }
        return $items;
    }
}
