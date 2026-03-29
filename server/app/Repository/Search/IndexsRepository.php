<?php

declare(strict_types=1);
namespace App\Repository\Search;

use App\Model\Search\SearchIndex as Model;
use App\Repository\IRepository;
use Hyperf\Database\Model\Builder;

class IndexsRepository extends IRepository
{
    public function __construct(protected readonly Model $model) {}

    public function handleSearch(Builder $query, array $params): Builder
    {
        return parent::handleSearch($query, $params);
    }
}
