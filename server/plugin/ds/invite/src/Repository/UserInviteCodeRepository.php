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
        // 根据用户ID查询
        if (Arr::has($params, 'user_id')) {
            $query->where('user_id', $params['user_id']);
        }

        // 根据类型查询
        if (Arr::has($params, 'type')) {
            if (is_array($params['type'])) {
                $query->whereIn('type', $params['type']);
            } else {
                $query->where('type', $params['type']);
            }
        }

        // 根据邀请码查询
        if (Arr::has($params, 'invite_code')) {
            $query->where('invite_code', $params['invite_code']);
        }

        return $query;
    }
}

