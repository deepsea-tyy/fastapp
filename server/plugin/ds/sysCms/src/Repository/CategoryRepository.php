<?php

declare(strict_types=1);


namespace Plugin\Ds\SysCms\Repository;

use App\Repository\IRepository;
use Hyperf\Database\Model\Builder;
use Plugin\Ds\SysCms\Model\Category as Model;

class CategoryRepository extends IRepository
{
    public function __construct(protected readonly Model $model)
    {
    }

    public function handleSearch(Builder $query, array $params): Builder
    {
        $query->with(['children'])->where(['parent_id' => 0]);
        return parent::handleSearch($query, $params);
    }
}