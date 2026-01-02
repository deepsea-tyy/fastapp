<?php

declare(strict_types=1);
namespace Plugin\Ds\Ex\Repository;

use Plugin\Ds\Ex\Model\ExVip as Model;
use App\Repository\IRepository;
use Hyperf\Database\Model\Builder;

class ExVipRepository extends IRepository
{
    public function __construct(protected readonly Model $model) {}

    public function handleSearch(Builder $query, array $params): Builder
    {
        return parent::handleSearch($query, $params);
    }
}
