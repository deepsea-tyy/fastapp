<?php

declare(strict_types=1);


namespace Plugin\Ds\Article\Repository;

use App\Repository\IRepository;
use Hyperf\Collection\Arr;
use Hyperf\Database\Model\Builder;
use Plugin\Ds\Article\Model\Category as Model;

class CategoryRepository extends IRepository
{
    public function __construct(protected readonly Model $model)
    {
    }

    public function handleSearch(Builder $query, array $params): Builder
    {
        if (Arr::has($params, 'parent_id')) {
            if (\is_array($params['parent_id'])) {
                $query->whereIn('parent_id', $params['parent_id']);
            } else {
                $query->where('parent_id', $params['parent_id']);
            }
        }
        if (Arr::has($params, 'status')) {
            if (\is_array($params['status'])) {
                $query->whereIn('status', $params['status']);
            } else {
                $query->where('status', $params['status']);
            }
        }
        if (Arr::has($params, 'code')) {
            $query->where('code', $params['code']);
        }
        return $query->with(['children'])->where(['parent_id' => 0]);
    }
}