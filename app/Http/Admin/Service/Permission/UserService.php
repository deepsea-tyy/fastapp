<?php

declare(strict_types=1);


namespace App\Http\Admin\Service\Permission;

use App\Common\IService;
use App\Model\Permission\Role;
use App\Model\User;
use App\Repository\Permission\RoleRepository;
use App\Repository\Permission\UserRepository;
use Hyperf\Collection\Collection;
use Hyperf\DbConnection\Db;
use Psr\SimpleCache\CacheInterface;

/**
 * @extends IService<User>
 */
final class UserService extends IService
{
    public function __construct(
        protected readonly UserRepository $repository,
        protected readonly RoleRepository $roleRepository,
        protected readonly CacheInterface $cache
    )
    {
    }

    public function getInfo(int $id): ?User
    {
        return DataScopeTool::getCurrentUser($id);
    }

    public function resetPassword(?int $id): bool
    {
        if ($id === null) {
            return false;
        }
        $entity = $this->repository->findById($id);
        $entity->resetPassword();
        $entity->save();
        return true;
    }

    public function getUserRole(int $id): Collection
    {
        return $this->repository->findById($id)->roles()->get();
    }

    public function batchGrantRoleForUser(int $id, array $roleCodes): void
    {
        $this->repository->findById($id)
            ->roles()
            ->sync(
                $this->roleRepository->list([
                    'code' => $roleCodes,
                ])->map(static function (Role $role) {
                    return $role->id;
                })
            );
        DataScopeTool::clearCurrentUserCache($id);
    }

    public function create(array $data): mixed
    {
        $userData = $this->extractUserData($data);
        $adminSettingData = $this->extractAdminSettingData($data);
        $userProfileData = $this->extractUserProfileData($data);

        return Db::transaction(function () use ($userData, $adminSettingData, $userProfileData) {
            $user = $this->repository->create($userData);

            if (!empty($adminSettingData)) {
                $user->adminSetting()->create($adminSettingData);
            }

            if (!empty($userProfileData)) {
                $user->profile()->create($userProfileData);
            }

            return $user;
        });
    }

    public function updateById(mixed $id, array $data): mixed
    {
        $userData = $this->extractUserData($data);
        $adminSettingData = $this->extractAdminSettingData($data);
        $userProfileData = $this->extractUserProfileData($data);

        return Db::transaction(function () use ($id, $userData, $adminSettingData, $userProfileData) {
            $user = $this->repository->findById($id);
            if (!$user) {
                return null;
            }

            if (!empty($userData)) {
                $user->update($userData);
            }

            if (!empty($adminSettingData)) {
                $user->adminSetting()->updateOrCreate(
                    ['user_id' => $id],
                    $adminSettingData
                );
            }

            if (!empty($userProfileData)) {
                $user->profile()->updateOrCreate(
                    ['user_id' => $id],
                    $userProfileData
                );
            }

            DataScopeTool::clearCurrentUserCache($id);

            return $user->fresh(['adminSetting', 'profile']);
        });
    }

    public function deleteById(mixed $id, array $where = []): int
    {
        $ids = is_array($id) ? $id : [$id];

        return Db::transaction(function () use ($ids) {
            $deletedCount = 0;
            foreach ($ids as $userId) {
                $user = $this->repository->findById($userId);
                if ($user) {
                    $user->delete();
                    DataScopeTool::clearCurrentUserCache($userId);
                    $deletedCount++;
                }
            }

            return $deletedCount;
        });
    }

    private function extractUserData(array $data): array
    {
        $userFields = ['username', 'password', 'user_type', 'mobile', 'email', 'status', 'remark', 'created_by', 'updated_by'];
        return array_intersect_key($data, array_flip($userFields));
    }

    private function extractAdminSettingData(array $data): array
    {
        $adminFields = ['phone', 'backend_setting', 'dept_id'];
        return array_intersect_key($data, array_flip($adminFields));
    }

    private function extractUserProfileData(array $data): array
    {
        $profileFields = ['nickname', 'avatar', 'signed'];
        return array_intersect_key($data, array_flip($profileFields));
    }

    public function selectUser(string $keyword)
    {
        $query = $this->repository->getQuery()
            ->select(['id', 'username', 'email', 'mobile'])
            ->limit(10)
            ->orderByDesc('id');
        if ($keyword) {
            $query->orWhere('username', 'like', $keyword . '%')
                ->orWhere('email', 'like', $keyword . '%')
                ->orWhere('mobile', 'like', $keyword . '%');
        }
        return $query->get()->map(function ($item) {
            return ['label' => implode('|', [$item->id, $item->username, $item->email, $item->mobile]), 'value' => $item->id];
        });
    }
}