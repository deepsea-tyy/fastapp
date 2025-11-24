<?php

declare(strict_types=1);


namespace App\Repository\Logstash;

use App\Model\Permission\UserAdminOperationLog;
use App\Repository\IRepository;
use Hyperf\Collection\Arr;
use Hyperf\Database\Model\Builder;

final class UserAdminOperationLogRepository extends IRepository
{
    public function __construct(
        protected readonly UserAdminOperationLog $model
    ) {}

    public function handleSearch(Builder $query, array $params): Builder
    {
        return parent::handleSearch($query, $params);
    }
}
