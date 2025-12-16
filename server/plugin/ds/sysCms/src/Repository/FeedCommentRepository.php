<?php

declare(strict_types=1);
namespace Plugin\Ds\SysCms\Repository;

use Plugin\Ds\SysCms\Model\FeedComment as Model;
use App\Repository\IRepository;
use Hyperf\Database\Model\Builder;

class FeedCommentRepository extends IRepository
{
    public function __construct(protected readonly Model $model) {}

    public function handleSearch(Builder $query, array $params): Builder
    {
        return $query;
    }
}
