<?php

declare(strict_types=1);


namespace App\Repository\Permission;

use App\Model\Permission\Menu;
use App\Repository\IRepository;
use Hyperf\Collection\Arr;
use Hyperf\Database\Model\Builder;

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
        if (Arr::has($params, 'children')) {
            $query->with(['children']);
            unset($params['children']);
        }
        
        return parent::handleSearch($query, $params);
    }
}
