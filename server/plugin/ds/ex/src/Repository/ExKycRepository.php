<?php

declare(strict_types=1);
namespace Plugin\Ds\Ex\Repository;

use Plugin\Ds\Ex\Model\ExKyc as Model;
use App\Repository\IRepository;
use Hyperf\Database\Model\Builder;

class ExKycRepository extends IRepository
{
    public function __construct(protected readonly Model $model) {}

    public function handleSearch(Builder $query, array $params): Builder
    {
        return parent::handleSearch($query, $params);
    }
}
