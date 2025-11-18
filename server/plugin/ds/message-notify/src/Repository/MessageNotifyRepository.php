<?php

declare(strict_types=1);


namespace Plugin\Ds\MessageNotify\Repository;

use Plugin\Ds\MessageNotify\Model\MessageNotify as Model;
use App\Repository\IRepository;
use Hyperf\Collection\Arr;
use Hyperf\Database\Model\Builder;

class MessageNotifyRepository extends IRepository
{
    public function __construct(protected readonly Model $model) {}

    public function handleSearch(Builder $query, array $params): Builder
    {
        if (Arr::has($params, 'type')) {
            if (\is_array($params['type'])) {
                $query->whereIn('type', $params['type']);
            } else {
                $query->where('type', $params['type']);
            }
        }
        if (Arr::has($params, 'user_id')) {
            if (\is_array($params['user_id'])) {
                $query->whereIn('user_id', $params['user_id']);
            } else {
                $query->where('user_id', $params['user_id']);
            }
        }
        if (Arr::has($params, 'notify_type')) {
            if (\is_array($params['notify_type'])) {
                $query->whereIn('notify_type', $params['notify_type']);
            } else {
                $query->where('notify_type', $params['notify_type']);
            }
        }
        if (Arr::has($params, 'created_by')) {
            if (\is_array($params['created_by'])) {
                $query->whereIn('created_by', $params['created_by']);
            } else {
                $query->where('created_by', $params['created_by']);
            }
        }
        if (Arr::has($params, 'updated_by')) {
            if (\is_array($params['updated_by'])) {
                $query->whereIn('updated_by', $params['updated_by']);
            } else {
                $query->where('updated_by', $params['updated_by']);
            }
        }
        if (Arr::has($params, 'created_at')) {
            if (\is_array($params['created_at'])) {
                $query->whereBetween('created_at', $params['created_at']);
            } else {
                $query->where('created_at', $params['created_at']);
            }
        }
        return $query;
    }
}