<?php

declare(strict_types=1);
namespace Plugin\Ds\SysCms\Repository;

use Plugin\Ds\SysCms\Model\FeedReport as Model;
use App\Repository\IRepository;
use Hyperf\Database\Model\Builder;

class FeedReportRepository extends IRepository
{
    public function __construct(protected readonly Model $model) {}

    public function handleSearch(Builder $query, array $params): Builder
    {
        return $query;
    }
}
