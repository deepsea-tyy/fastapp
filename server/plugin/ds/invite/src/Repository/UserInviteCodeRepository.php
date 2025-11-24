<?php

declare(strict_types=1);

namespace Plugin\Ds\Invite\Repository;

use App\Repository\IRepository;
use Hyperf\Collection\Arr;
use Hyperf\Database\Model\Builder;
use Plugin\Ds\Invite\Model\UserInviteCode as Model;

class UserInviteCodeRepository extends IRepository
{
    public function __construct(protected readonly Model $model)
    {
    }

    public function handleSearch(Builder $query, array $params): Builder
    {
        if (Arr::has($params, 'type')) {
            if (is_array($params['type'])) {
                $query->whereIn('type', $params['type']);
            } else {
                $query->where('type', $params['type']);
            }
            unset($params['type']);
        }
        
        return parent::handleSearch($query, $params);
    }
}

