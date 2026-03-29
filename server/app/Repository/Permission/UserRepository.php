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
            foreach ($item->adminSetting?->toArray() ?? [] as $k => $v) {
                if ($k == 'id') continue;
                $item[$k] = $v;
            }
            foreach ($item->profile?->toArray() ?? [] as $k => $v) {
                if ($k == 'id') continue;
                $item[$k] = $v;
            }
        }
        return $items;
    }
}
