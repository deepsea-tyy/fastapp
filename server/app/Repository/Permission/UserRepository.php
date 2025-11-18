<?php

declare(strict_types=1);


namespace App\Repository\Permission;

use App\Http\Admin\Service\Permission\DataScopeTool;
use App\Model\User;
use App\Repository\IRepository;
use Hyperf\Collection\Arr;
use Hyperf\Collection\Collection;
use Hyperf\Database\Model\Builder;

/**
 * Class UserRepository.
 * @extends IRepository<User>
 */
final class UserRepository extends IRepository
{
    public function __construct(protected readonly User $model)
    {
    }

    public function handleSearch(Builder $query, array $params): Builder
    {
        DataScopeTool::applyUserDataScope($params['created_by'], $query);

        return $query
            ->when(Arr::get($params, 'unique_username'), static function (Builder $query, $uniqueUsername) {
                $query->where('username', $uniqueUsername);
            })
            ->when(Arr::get($params, 'username'), static function (Builder $query, $username) {
                $query->where('username', 'like', '%' . $username . '%');
            })
            ->when(Arr::get($params, 'phone'), static function (Builder $query, $phone) {
                $query->whereHas('adminSetting', static function (Builder $q) use ($phone) {
                    $q->where('phone', $phone);
                });
            })
            ->when(Arr::get($params, 'email'), static function (Builder $query, $email) {
                $query->where('email', $email);
            })
            ->when(Arr::exists($params, 'status'), static function (Builder $query) use ($params) {
                $query->where('status', Arr::get($params, 'status'));
            })
            ->when(Arr::exists($params, 'user_type'), static function (Builder $query) use ($params) {
                $query->where('user_type', Arr::get($params, 'user_type'));
            })
            ->when(Arr::exists($params, 'nickname'), static function (Builder $query) use ($params) {
                $query->whereHas('profile', static function (Builder $q) use ($params) {
                    $q->where('nickname', 'like', '%' . Arr::get($params, 'nickname') . '%');
                });
            })
            ->when(Arr::exists($params, 'created_at'), static function (Builder $query) use ($params) {
                $query->whereBetween('created_at', [
                    Arr::get($params, 'created_at')[0] . ' 00:00:00',
                    Arr::get($params, 'created_at')[1] . ' 23:59:59',
                ]);
            })
            ->when(Arr::get($params, 'user_ids'), static function (Builder $query, $userIds) {
                $query->whereIn('id', $userIds);
            })
            ->when(Arr::get($params, 'role_id'), static function (Builder $query, $roleId) {
                $query->whereHas('roles', static function (Builder $query) use ($roleId) {
                    $query->where('role_id', $roleId);
                });
            })->with(['profile', 'adminSetting']);
    }

    public function handleItems(Collection $items): Collection
    {
        foreach ($items as $item) {
            $item->setHidden(['profile', 'adminSetting', 'password']);
            $item->phone = $item->adminSetting?->phone;
            $item->dept_id = $item->adminSetting?->dept_id;
            $item->backend_setting = $item->adminSetting?->backend_setting;
            $item->nickname = $item->profile?->nickname;
            $item->avatar = $item->profile?->avatar;
            $item->signed = $item->profile?->signed;
        }
        return $items;
    }
}
