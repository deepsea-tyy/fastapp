<?php

declare(strict_types=1);


namespace App\Repository\Logstash;

use App\Model\Permission\UserAdminLoginLog;
use App\Repository\IRepository;
use Hyperf\Collection\Arr;
use Hyperf\Database\Model\Builder;

final class UserAdminLoginLogRepository extends IRepository
{
    public function __construct(
        protected readonly UserAdminLoginLog $model
    ) {}

    public function handleSearch(Builder $query, array $params): Builder
    {
        return parent::handleSearch($query, $params);
    }
}
