<?php

declare(strict_types=1);


namespace Plugin\Ds\MessageNotify\Repository;

use Plugin\Ds\MessageNotify\Model\MessageNotify as Model;
use App\Repository\IRepository;
use Hyperf\Database\Model\Builder;

class MessageNotifyRepository extends IRepository
{
    public function __construct(protected readonly Model $model) {}

    public function handleSearch(Builder $query, array $params): Builder
    {
        return parent::handleSearch($query, $params);
    }
}