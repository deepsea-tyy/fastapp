<?php

declare(strict_types=1);

namespace Plugin\Ds\Invite\Repository;

use App\Repository\IRepository;
use Hyperf\Database\Model\Builder;
use Plugin\Ds\Invite\Model\UserInviteCode as Model;

class UserInviteCodeRepository extends IRepository
{
    public function __construct(protected readonly Model $model)
    {
    }

    public function handleSearch(Builder $query, array $params): Builder
    {
        return parent::handleSearch($query, $params);
    }
}

