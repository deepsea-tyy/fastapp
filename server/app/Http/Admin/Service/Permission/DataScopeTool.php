<?php

declare(strict_types=1);


namespace App\Http\Admin\Service\Permission;

use App\Model\Enums\User\Status;
use App\Model\Permission\AdminSetting;
use App\Model\User;
use App\Model\UserProfile;
use App\Repository\Permission\DepartmentRepository;
use Hyperf\Context\ApplicationContext;
use Hyperf\Context\RequestContext;
use Hyperf\Database\Model\Builder;
use Lcobucci\JWT\Token\RegisteredClaims;
use Lcobucci\JWT\UnencryptedToken;
use Psr\SimpleCache\CacheInterface;
use Psr\SimpleCache\InvalidArgumentException;

/**
 * 数据权限服务
 * 根据角色的data_scope过滤数据
 *
 * 数据权限基于数据创建者（created_by）进行过滤：
 * 1. 根据角色的 data_scope 确定数据权限范围
 * 2. 根据权限范围获取可访问的用户ID列表
 * 3. 使用 whereIn('created_by', $userIds) 或 where('created_by', $userId) 过滤数据
 *
 * 多角色权限策略（按优先级顺序，从高到低）：
 * 1. 全部权限（data_scope=1）- 最高优先级
 * 2. 自定义权限（data_scope=2）- 合并所有自定义角色的部门ID（通过 role_belongs_department 表）
 * 3. 本部门及以下（data_scope=4）- 使用用户所属的部门（user_admin_setting.dept_id）
 * 4. 本部门（data_scope=3）- 使用用户所属的部门（user_admin_setting.dept_id）
 * 5. 本人（data_scope=5）- 最低优先级
 */
final class DataScopeTool
{
    public const DATA_SCOPE_ALL = 1; // 全部数据权限
    public const DATA_SCOPE_CUSTOM = 2; // 自定义数据权限
    public const DATA_SCOPE_DEPT = 3; // 本部门数据权限
    public const DATA_SCOPE_DEPT_AND_CHILD = 4; // 本部门及以下数据权限
    public const DATA_SCOPE_SELF = 5; // 本人数据权限

    public const CACHE_TTL = 3600; // 缓存1小时

    /**
     * 获取Cache实例
     */
    public static function getCache(): CacheInterface
    {
        return ApplicationContext::getContainer()->get(CacheInterface::class);
    }

    /**
     * 清除当前用户缓存
     */
    public static function clearCurrentUserCache(int|string $userId): void
    {
        self::getCache()->delete((string)$userId);
    }

    /**
     * 获取当前用户（带缓存）
     *
     * @param int $userId 用户ID，为0时自动获取当前登录用户
     * @return User|null 用户对象，不存在时返回null
     * @throws InvalidArgumentException
     */
    public static function getCurrentUser(int $userId = 0): ?User
    {
        if (!$userId) {
            $token = RequestContext::get()->getAttribute('token');
            if (!$token instanceof UnencryptedToken) {
                return null;
            }
            $userId = (int)$token->claims()->get(RegisteredClaims::ID);
        }
        $cached = self::getCache()->get((string)$userId);
        if ($cached !== null) {
            return $cached;
        }
        $user = User::query()->find($userId);
        if (!$user) {
            return null;
        }
        $user->load(['roles']);
        $adminSetting = AdminSetting::query()->where('user_id', $userId)->first();
        $userProfile = UserProfile::query()->where('user_id', $userId)->first();
        $user->phone = $adminSetting?->phone;
        $user->backend_setting = $adminSetting?->backend_setting;
        $user->dept_id = $adminSetting?->dept_id;
        $user->nickname = $userProfile?->nickname;
        $user->avatar = $userProfile?->avatar;
        $user->signed = $userProfile?->signed;

        self::getCache()->set((string)$userId, $user, self::CACHE_TTL);
        return $user;
    }

    /**
     * 获取用户所属的部门ID数组（从user_admin_setting.dept_id获取）
     *
     * @param User $user 用户对象
     * @return array 用户所属的部门ID数组
     */
    public static function getUserDeptIds(User $user): array
    {
        $adminSetting = $user->adminSetting;
        return $adminSetting?->dept_id ?? [];
    }

    /**
     * 根据部门ID列表过滤查询
     * 先获取属于这些部门的用户ID列表，然后通过 created_by 字段过滤数据
     *
     * @param Builder $query 查询构建器
     * @param array $deptIds 部门ID数组
     * @return Builder
     */
    private static function filterByDeptIds(Builder $query, array $deptIds): Builder
    {
        if (empty($deptIds)) {
            return $query->whereRaw('1 = 0');
        }
        $userIds = self::getUserIdsByDeptIds($deptIds);
        if (empty($userIds)) {
            return $query->whereRaw('1 = 0');
        }
        return $query->whereIn('created_by', $userIds);
    }

    /**
     * 根据部门ID列表获取属于这些部门的用户ID列表
     * 查询 user_admin_setting 表中 dept_id 字段包含这些部门ID的用户
     *
     * @param array $deptIds 部门ID数组
     * @return array 用户ID数组（属于这些部门的用户）
     */
    public static function getUserIdsByDeptIds(array $deptIds): array
    {
        if (empty($deptIds)) {
            return [];
        }

        // 去重并过滤无效值
        $deptIds = array_filter(array_unique($deptIds), fn($id) => is_numeric($id) && $id > 0);
        if (empty($deptIds)) {
            return [];
        }

        // 查询 user_admin_setting 表，dept_id 是 JSON 数组字段（表示用户所属的部门）
        // 使用 orWhereJsonContains 查询 JSON 数组中包含任意一个部门ID的用户
        return AdminSetting::query()
            ->where(function ($query) use ($deptIds) {
                foreach ($deptIds as $deptId) {
                    $query->orWhereJsonContains('dept_id', (int)$deptId);
                }
            })
            ->pluck('user_id')
            ->unique()
            ->values()
            ->toArray();
    }

    /**
     * 应用用户数据权限过滤
     *
     * 确定数据权限范围，按照优先级顺序处理多角色权限（从高到低）：
     * 1. 全部权限（data_scope=1）- 最高优先级
     * 2. 自定义权限（data_scope=2）- 合并所有自定义角色的部门ID（通过 role_belongs_department 表获取角色可访问的部门）
     * 3. 本部门及以下（data_scope=4）- 使用用户所属的部门（user_admin_setting.dept_id）
     * 4. 本部门（data_scope=3）- 使用用户所属的部门（user_admin_setting.dept_id）
     * 5. 本人（data_scope=5）- 最低优先级
     *
     * 数据最终归属为 created_by，先根据权限范围获取用户ID列表，再用 whereIn('created_by', $userIds) 过滤
     *
     * @param int $user_id 用户ID，为0时自动获取当前登录用户
     * @return Builder
     */
    public static function applyUserDataScope(int $user_id, Builder $query): Builder
    {
        $user = self::getCurrentUser($user_id);

        if (!$user) {
            return $query->whereRaw('1 = 0');
        }

        // 超级管理员拥有全部数据权限
        if ($user->isSuperAdmin()) {
            return $query;
        }

        // 获取用户的所有正常状态角色（只有正常状态的角色才会参与权限判断）
        $roles = $user->getRoles()->where('status', Status::Normal);
        if ($roles->isEmpty()) {
            return $query->where('created_by', $user->id); // 默认返回本人权限
        }

        $dataScopes = $roles->pluck('data_scope')->unique()->toArray();

        // 策略1: 如果有全部权限，直接返回全部权限
        if (in_array(self::DATA_SCOPE_ALL, $dataScopes, true)) {
            return $query;
        }

        // 策略2: 如果有自定义权限，需要合并所有自定义权限的部门
        if (in_array(self::DATA_SCOPE_CUSTOM, $dataScopes, true)) {
            $deptIds = [];
            // 获取所有自定义权限角色的ID
            $customRoleIds = $roles->where('data_scope', self::DATA_SCOPE_CUSTOM)->pluck('id')->toArray();
            if (!empty($customRoleIds)) {
                // 从 role_belongs_department 表获取角色可访问的部门数据权限
                // 一次性查询所有自定义角色的部门，避免N+1查询
                $roleDeptIds = \Hyperf\DbConnection\Db::table('role_belongs_department')
                    ->whereIn('role_id', $customRoleIds)
                    ->pluck('dept_id')
                    ->toArray();
                $deptIds = array_merge($deptIds, $roleDeptIds);
            }
            // 根据角色可访问的部门，查询属于这些部门的用户，然后过滤数据
            return self::filterByDeptIds($query, $deptIds);
        }

        // 策略3: 检查本部门及以下权限（data_scope=4）
        if (in_array(self::DATA_SCOPE_DEPT_AND_CHILD, $dataScopes, true)) {
            // 获取用户所属的部门（user_admin_setting.dept_id）
            $userDeptIds = self::getUserDeptIds($user);
            if (empty($userDeptIds)) {
                return $query->whereRaw('1 = 0');
            }
            // 获取用户所属部门及其所有子部门
            $allDeptIds = [];
            foreach ($userDeptIds as $deptId) {
                $allDeptIds = array_merge($allDeptIds, ApplicationContext::getContainer()->get(DepartmentRepository::class)->getAllChildrenIds($deptId));
            }
            // 根据部门列表，查询属于这些部门的用户，然后过滤数据
            return self::filterByDeptIds($query, array_unique($allDeptIds));
        }

        // 策略4: 检查本部门权限（data_scope=3）
        if (in_array(self::DATA_SCOPE_DEPT, $dataScopes, true)) {
            // 获取用户所属的部门（user_admin_setting.dept_id）
            $userDeptIds = self::getUserDeptIds($user);
            // 根据用户所属的部门，查询属于这些部门的用户，然后过滤数据
            return self::filterByDeptIds($query, $userDeptIds);
        }

        // 策略5: 默认返回本人权限（data_scope=5）
        return $query->where('created_by', $user->id);
    }
}
