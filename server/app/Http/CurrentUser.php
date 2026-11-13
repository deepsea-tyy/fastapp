<?php

declare(strict_types=1);

namespace App\Http;

use App\Common\Event\UserAdminLoginEvent;
use App\Common\Event\UserCacheClearEvent;
use App\Common\Event\UserAccountEvent;
use App\Common\Event\UserRegisterEvent;
use App\Common\Jwt\JwtFactory;
use App\Common\Jwt\JwtInterface;
use App\Common\ResultCode;
use App\Common\Tools;
use App\Exception\BusinessException;
use App\Exception\JwtInBlackException;
use App\Model\Enums\User\Status;
use App\Model\Permission\AdminSetting;
use App\Model\Permission\Role;
use App\Model\User;
use App\Model\UserProfile;
use App\Repository\Permission\DepartmentRepository;
use App\Repository\Permission\UserRepository;
use Hyperf\Collection\Arr;
use Hyperf\Collection\Collection;
use Hyperf\Context\ApplicationContext;
use Hyperf\Context\RequestContext;
use Hyperf\Database\Model\Builder;
use Hyperf\DbConnection\Db;
use Lcobucci\JWT\Token\RegisteredClaims;
use Lcobucci\JWT\UnencryptedToken;
use Psr\SimpleCache\CacheInterface;

class CurrentUser
{
    // 数据权限常量
    public const DATA_SCOPE_ALL = 1;         // 全部数据权限
    public const DATA_SCOPE_CUSTOM = 2;     // 自定义数据权限
    public const DATA_SCOPE_DEPT = 3;       // 本部门数据权限
    public const DATA_SCOPE_DEPT_AND_CHILD = 4; // 本部门及以下数据权限
    public const DATA_SCOPE_SELF = 5;       // 本人数据权限

    /**
     * @var string jwt场景
     */
    private string $scene = 'default';

    public function __construct(
        protected readonly JwtFactory   $jwtFactory,
        protected readonly CacheInterface $cache,
        protected readonly UserRepository $userRepository,
    ) {
    }

    /**
     * 格式化 Token
     *
     * @param User $user 用户对象
     * @param string $ip IP地址
     * @param string $browser 浏览器/User-Agent
     * @param string $os 操作系统
     * @param string $deviceId 设备唯一标识（iOS/Android/Web通用，可选）
     * @return array Token数据
     */
    public function formatToken(User $user, string $ip = '', string $browser = '', string $os = '', string $deviceId = ''): array
    {
        $jwt = $this->getJwt();
        if ($user->status == Status::DISABLE) {
            throw new BusinessException(ResultCode::DISABLED);
        }
        if ($ip) {
            if ($this->scene == 'api') {
                $profile = Arr::only($user->profile?->toArray() ?? [], ['user_id', 'nickname', 'avatar', 'signed', 'lang', 'trans_password']);
                Tools::setUserCache($user->id, array_merge([
                    'user_id' => $user->id,
                    'email' => $user->email,
                    'code' => $user->code,
                    'mobile' => $user->mobile,
                    'google2fa' => $user->google2fa ?: '',
                ], $profile, $user->profile?->setting ?? []));
                Tools::eventDispatcher(new UserAccountEvent($user, $ip, $os, $browser, $deviceId, $user->wasRecentlyCreated ? 2 : 1));
            } else {
                Tools::eventDispatcher(new UserAdminLoginEvent($user, $ip, $os, $browser));
            }
        }
        return [
            'access_token' => $jwt->builderAccessToken((string)$user->id)->toString(),
            'refresh_token' => $jwt->builderRefreshToken((string)$user->id)->toString(),
            'expire_at' => (int)$jwt->getConfig('ttl', 0),
        ];
    }

    public function checkJwt(UnencryptedToken $token): void
    {
        $this->getJwt()->hasBlackList($token) && throw new JwtInBlackException();
    }

    public function logout(UnencryptedToken $token): void
    {
        $this->getJwt()->addBlackList($token);
    }

    public function getJwt(): JwtInterface
    {
        return $this->jwtFactory->get($this->scene);
    }

    public function setScene(string $scene): static
    {
        $this->scene = $scene;
        return $this;
    }

    public function refreshToken(UnencryptedToken $token): array
    {
        return value(static function (JwtInterface $jwt) use ($token) {
            $jwt->addBlackList($token);
            return [
                'access_token' => $jwt->builderAccessToken($token->claims()->get(RegisteredClaims::ID))->toString(),
                'refresh_token' => $jwt->builderRefreshToken($token->claims()->get(RegisteredClaims::ID))->toString(),
                'expire_at' => (int)$jwt->getConfig('ttl', 0),
            ];
        }, $this->getJwt());
    }

    public function findUser(array $map): ?User
    {
        return User::query()->where($map)->first();
    }

    public function create(array $data): mixed
    {
        return Db::transaction(function () use ($data) {
            $md = User::create($data);
            if ($md->wasRecentlyCreated) {
                if (empty($md->username)) {
                    $md->username = '@u' . $md->no;
                    $md->save();
                }
                UserProfile::query()->create(['user_id' => $md->id, 'nickname' => 'u' . $md->no]);
            }
            Tools::eventDispatcher(new UserRegisterEvent($md, $data['invite_code'] ?? ''));
            return $md;
        });
    }

    /**
     * 获取当前用户信息（支持按需加载关联）
     *
     * @param int|null $id 用户ID，null 时取当前登录用户
     * @param bool $withRoles 是否加载角色
     * @param bool $withAdminSetting 是否加载管理员设置
     * @param bool $withProfile 是否加载用户档案
     * @return User|null
     */
    public function getInfo(?int $id = null, bool $withRoles = false, bool $withAdminSetting = false, bool $withProfile = true): ?User
    {
        $userId = $id ?? $this->id();
        if (!$userId) {
            return null;
        }

        // 优先使用带缓存的完整加载（admin 场景走缓存）
        if ($withRoles) {
            return $this->getCachedUser($userId, $withAdminSetting, $withProfile);
        }

        $relations = array_filter([
            $withProfile ? 'profile' : null,
            $withAdminSetting ? 'adminSetting' : null,
        ]);

        return User::query()->with($relations)->find($userId);
    }

    /**
     * 获取带缓存的完整用户（包含 roles/adminSetting/profile）
     */
    public function getCachedUser(int $userId, bool $withAdminSetting = true, bool $withProfile = true): ?User
    {
        $cached = $this->cache->get((string)$userId);
        if ($cached !== null) {
            return $cached;
        }

        $user = User::query()->find($userId);
        if (!$user) {
            return null;
        }

        $user->load(['roles']);

        if ($withAdminSetting) {
            $adminSetting = AdminSetting::query()->where('user_id', $userId)->first();
            $user->phone = $adminSetting?->phone;
            $user->dept_id = $adminSetting?->dept_id;
        }

        if ($withProfile) {
            $userProfile = UserProfile::query()->where('user_id', $userId)->first();
            $user->nickname = $userProfile?->nickname;
            $user->avatar = $userProfile?->avatar;
            $user->signed = $userProfile?->signed;
            $user->lang = $userProfile?->lang;
        }

        $this->cache->set((string)$userId, $user, 3600);
        return $user;
    }

    /**
     * 清除用户缓存
     */
    public function clearCache(int $userId): void
    {
        $this->cache->delete((string)$userId);
        Tools::eventDispatcher(new UserCacheClearEvent($userId));
    }

    public function user(int $id = 0): ?User
    {
        return User::query()->find($id ?: $this->id());
    }

    public function profile(int $id = 0): ?UserProfile
    {
        return UserProfile::query()->where(['user_id' => $id ?: $this->id()])->first();
    }

    public function getToken(): ?UnencryptedToken
    {
        return RequestContext::get()->getAttribute('token');
    }

    public function id(): int
    {
        $token = $this->getToken();
        if (!$token) {
            $tokenStr = Tools::getHeader('token');
            if (!$tokenStr) {
                return 0;
            }
            $token = $this->jwtFactory->get($this->scene)->parserAccessToken($tokenStr);
        }
        return (int)$token->claims()->get(RegisteredClaims::ID);
    }

    public static function baseInfo(int $userId): array
    {
        $filed = ['user_id', 'nickname', 'avatar', 'signed', 'lang'];
        $profile = Tools::getUserCache($userId, $filed);
        if (!$profile['user_id']) {
            $profile = UserProfile::query()->where('user_id', $userId)
                ->first($filed)?->toArray() ?? ['user_id' => $userId, 'nickname' => '', 'avatar' => '', 'signed' => ''];
            Tools::setUserCache($userId, $profile);
        }
        return $profile;
    }

    // ========== 以下为通用用户管理方法 ==========

    /**
     * 重置用户密码
     */
    public function resetPassword(int $id): bool
    {
        $user = User::query()->find($id);
        if (!$user) {
            return false;
        }
        $user->resetPassword();
        $user->save();
        return true;
    }

    /**
     * 分页查询用户（委托 UserRepository，数据权限自动由 created_by 参数触发）
     */
    public function page(array $params = [], int $page = 1, int $pageSize = 10): array
    {
        return $this->userRepository->page($params, $page, $pageSize);
    }

    /**
     * 列表查询用户
     */
    public function getList(array $params = []): Collection
    {
        return $this->userRepository->list($params);
    }

    /**
     * 通过 ID 查用户
     */
    public function findById(mixed $id): ?User
    {
        return $this->userRepository->findById($id);
    }

    /**
     * 获取用户角色
     */
    public function getUserRoles(int $id): Collection
    {
        return User::query()->findOrFail($id)->roles()->get();
    }

    /**
     * 批量为用户授权角色
     *
     * @param int $userId
     * @param string[] $roleCodes
     */
    public function grantRoles(int $userId, array $roleCodes): void
    {
        $user = User::query()->findOrFail($userId);
        $roleIds = Role::query()->whereIn('code', $roleCodes)->pluck('id');
        $user->roles()->sync($roleIds);
        $this->clearCache($userId);
    }

    /**
     * 创建用户（同时支持用户端和管理端字段）
     *
     * @param array $data 可包含: username/password/user_type/mobile/email/status/remark + phone/dept_id + nickname/avatar/signed/lang
     * @param bool $withAdminSetting 是否同时创建 AdminSetting
     * @param bool $withProfile 是否同时创建 UserProfile
     * @return User
     */
    public function createUser(array $data, bool $withAdminSetting = true, bool $withProfile = true): User
    {
        $userData = $this->extractUserData($data);
        $adminSettingData = $this->extractAdminSettingData($data);
        $userProfileData = $this->extractUserProfileData($data);

        return Db::transaction(function () use ($userData, $adminSettingData, $userProfileData, $withAdminSetting, $withProfile) {
            $user = User::create($userData);

            if ($withAdminSetting && !empty($adminSettingData)) {
                $user->adminSetting()->create($adminSettingData);
            }

            if ($withProfile && !empty($userProfileData)) {
                $user->profile()->create($userProfileData);
            }

            return $user;
        });
    }

    /**
     * 更新用户（同时支持用户端和管理端字段）
     *
     * @param int $id
     * @param array $data
     * @param bool $withAdminSetting
     * @param bool $withProfile
     * @return User|null
     */
    public function updateUser(int $id, array $data, bool $withAdminSetting = true, bool $withProfile = true): ?User
    {
        $userData = $this->extractUserData($data);
        $adminSettingData = $this->extractAdminSettingData($data);
        $userProfileData = $this->extractUserProfileData($data);

        return Db::transaction(function () use ($id, $userData, $adminSettingData, $userProfileData, $withAdminSetting, $withProfile) {
            $user = User::query()->find($id);
            if (!$user) {
                return null;
            }

            if (!empty($userData)) {
                $user->update($userData);
            }

            if ($withAdminSetting && !empty($adminSettingData)) {
                $user->adminSetting()->updateOrCreate(
                    ['user_id' => $id],
                    $adminSettingData
                );
            }

            if ($withProfile && !empty($userProfileData)) {
                $user->profile()->updateOrCreate(
                    ['user_id' => $id],
                    $userProfileData
                );
                if (Arr::has($userProfileData, 'lang')) {
                    Tools::setUserCache($id, Arr::only($userProfileData, ['lang']));
                }
            }

            $this->clearCache($id);
            return $user->fresh(['adminSetting', 'profile']);
        });
    }

    /**
     * 删除用户
     *
     * @param int|int[] $ids
     * @return int 删除数量
     */
    public function deleteUsers(int|array $ids): int
    {
        $ids = is_array($ids) ? $ids : [$ids];

        return Db::transaction(function () use ($ids) {
            $deletedCount = 0;
            foreach ($ids as $userId) {
                $user = User::query()->find($userId);
                if ($user) {
                    $user->delete();
                    $this->clearCache($userId);
                    $deletedCount++;
                }
            }
            return $deletedCount;
        });
    }

    /**
     * 用户选择器（按关键词搜索）
     */
    public function selectUser(string $keyword): Collection
    {
        $query = User::query()
            ->select(['id', 'username', 'email', 'mobile'])
            ->limit(10)
            ->orderByDesc('id');

        if ($keyword) {
            $query->where(function ($q) use ($keyword) {
                $q->orWhere('username', 'like', $keyword . '%')
                    ->orWhere('email', 'like', $keyword . '%')
                    ->orWhere('mobile', 'like', $keyword . '%');
            });
        }

        return $query->get()->map(function ($item) {
            return [
                'label' => implode('|', array_filter([$item->id, $item->username, $item->email, $item->mobile])),
                'value' => $item->id,
            ];
        });
    }

    /**
     * 判断用户是否超级管理员
     */
    public function isSuperAdmin(int $id = 0): bool
    {
        $userId = $id ?: $this->id();
        if (!$userId) {
            return false;
        }
        $user = $this->getCachedUser($userId, false, false);
        return (bool)($user?->roles->contains('code', 'SuperAdmin'));
    }

    // ========== 私有辅助方法 ==========

    private function extractUserData(array $data): array
    {
        $userFields = ['username', 'password', 'user_type', 'mobile', 'email', 'status', 'remark', 'created_by', 'updated_by'];
        return array_intersect_key($data, array_flip($userFields));
    }

    private function extractAdminSettingData(array $data): array
    {
        $adminFields = ['phone', 'dept_id'];
        return array_intersect_key($data, array_flip($adminFields));
    }

    private function extractUserProfileData(array $data): array
    {
        $profileFields = ['nickname', 'avatar', 'signed', 'lang'];
        return array_intersect_key($data, array_flip($profileFields));
    }

    // ========== 数据权限 ==========

    /**
     * 应用用户数据权限过滤（按角色 data_scope 过滤 created_by）
     *
     * 优先级策略（从高到低）：
     * 1. 全部权限 → 不过滤
     * 2. 自定义权限 → 合并所有自定义角色的部门
     * 3. 本部门及以下 → 查部门子树
     * 4. 本部门 → 直接用用户部门
     * 5. 本人 → created_by = user_id
     */
    public function applyUserDataScope(Builder $query, int $userId = 0): Builder
    {
        $userId = $userId ?: $this->id();
        $user = $this->getCachedUser($userId);

        if (!$user) {
            return $query->whereRaw('1 = 0');
        }

        if ($user->isSuperAdmin()) {
            return $query;
        }

        $roles = $user->getRoles()?->where('status', Status::Normal);
        if (!$roles || $roles->isEmpty()) {
            return $query->where('created_by', $user->id);
        }

        $dataScopes = $roles->pluck('data_scope')->unique()->toArray();

        // 策略1：全部权限
        if (in_array(self::DATA_SCOPE_ALL, $dataScopes, true)) {
            return $query;
        }

        // 策略2：自定义权限
        if (in_array(self::DATA_SCOPE_CUSTOM, $dataScopes, true)) {
            $customRoleIds = $roles->where('data_scope', self::DATA_SCOPE_CUSTOM)->pluck('id')->toArray();
            if (!empty($customRoleIds)) {
                $deptIds = Db::table('role_belongs_department')
                    ->whereIn('role_id', $customRoleIds)
                    ->pluck('dept_id')
                    ->toArray();
                return $this->filterByDeptIds($query, $deptIds);
            }
        }

        // 策略3：本部门及以下
        if (in_array(self::DATA_SCOPE_DEPT_AND_CHILD, $dataScopes, true)) {
            $userDeptIds = $user->adminSetting?->dept_id ?? [];
            if (empty($userDeptIds)) {
                return $query->whereRaw('1 = 0');
            }
            // 通过容器获取 DepartmentRepository（admin 目录外，可用）
            $deptRepo = ApplicationContext::getContainer()->get(DepartmentRepository::class);
            $allDeptIds = [];
            foreach ($userDeptIds as $deptId) {
                $allDeptIds = array_merge($allDeptIds, $deptRepo->getAllChildrenIds($deptId));
            }
            return $this->filterByDeptIds($query, array_unique($allDeptIds));
        }

        // 策略4：本部门
        if (in_array(self::DATA_SCOPE_DEPT, $dataScopes, true)) {
            return $this->filterByDeptIds($query, $user->adminSetting?->dept_id ?? []);
        }

        // 策略5：本人
        return $query->where('created_by', $user->id);
    }

    /**
     * 按部门ID数组过滤（先查属于这些部门的用户ID，再 whereIn created_by）
     */
    private function filterByDeptIds(Builder $query, array $deptIds): Builder
    {
        if (empty($deptIds)) {
            return $query->whereRaw('1 = 0');
        }
        $deptIds = array_filter(array_unique($deptIds), fn($id) => is_numeric($id) && $id > 0);
        if (empty($deptIds)) {
            return $query->whereRaw('1 = 0');
        }

        $userIds = AdminSetting::query()
            ->where(function ($q) use ($deptIds) {
                foreach ($deptIds as $deptId) {
                    $q->orWhereJsonContains('dept_id', (int)$deptId);
                }
            })
            ->pluck('user_id')
            ->unique()
            ->values()
            ->toArray();

        return empty($userIds) ? $query->whereRaw('1 = 0') : $query->whereIn('created_by', $userIds);
    }
}
