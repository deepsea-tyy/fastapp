<?php

declare(strict_types=1);


namespace App\Repository\Permission;

use App\Model\Enums\User\Status;
use App\Model\Permission\Menu;
use App\Repository\IRepository;
use Hyperf\Collection\Arr;
use Hyperf\Database\Model\Builder;
use Hyperf\Database\Model\Collection;

final class MenuRepository extends IRepository
{
    public function __construct(
        protected readonly Menu $model
    ) {}

    public function enablePageOrderBy(): bool
    {
        return false;
    }

    public function list(array $params = []): \Hyperf\Collection\Collection
    {
        return $this->perQuery($this->getQuery(), $params)->orderBy('sort')->get();
    }

    public function handleSearch(Builder $query, array $params): Builder
    {
        if (Arr::has($params, 'code')) {
            $query->whereIn('code', Arr::wrap($params['code']));
            unset($params['code']);
        }
        
        if (Arr::has($params, 'name')) {
            $query->whereIn('name', Arr::wrap($params['name']));
            unset($params['name']);
        }
        
        if (Arr::has($params, 'children')) {
            $query->with(['children']);
            unset($params['children']);
        }
        
        return parent::handleSearch($query, $params);
    }
}
