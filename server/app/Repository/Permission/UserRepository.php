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
        if (Arr::has($params, 'created_by')) {
            DataScopeTool::applyUserDataScope($params['created_by'], $query);
            unset($params['created_by']);
        }
        
        if (Arr::has($params, 'phone')) {
            $query->whereHas('adminSetting', static function (Builder $q) use ($params) {
                $q->where('phone', 'like', Arr::get($params, 'phone') . '%');
            });
            unset($params['phone']);
        }
        
        if (Arr::has($params, 'nickname')) {
            $query->whereHas('profile', static function (Builder $q) use ($params) {
                $q->where('nickname', 'like', '%' . Arr::get($params, 'nickname') . '%');
            });
            unset($params['nickname']);
        }
        
        $query->with(['profile', 'adminSetting']);
        return parent::handleSearch($query, $params);
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
