<?php

declare(strict_types=1);

namespace Plugin\Ds\Invite\Service;

use App\Common\IService;
use Plugin\Ds\Invite\Model\UserInviteCode;
use Plugin\Ds\Invite\Repository\UserInviteCodeRepository as Repository;

class UserInviteCodeService extends IService
{
    public function __construct(
        protected readonly Repository $repository
    ) {}

    /**
     * 获取用户的默认邀请码
     * 
     * @param int $userId 用户ID
     * @return UserInviteCode|null
     */
    public function getDefaultInviteCode(int $userId): ?UserInviteCode
    {
        return $this->repository->getQuery()
            ->where('user_id', $userId)
            ->where('type', 1)
            ->first();
    }

    /**
     * 创建或获取默认邀请码
     * 
     * @param int $userId 用户ID
     * @param string|null $inviteCode 邀请码（可选，不传则自动生成）
     * @param array|null $config 自定义配置（可选）
     * @return UserInviteCode
     */
    public function createOrGetDefault(int $userId, ?string $inviteCode = null, ?array $config = null): UserInviteCode
    {
        $default = $this->getDefaultInviteCode($userId);
        
        if ($default) {
            return $default;
        }

        // 如果没有邀请码，自动生成
        if (!$inviteCode) {
            $inviteCode = $this->generateInviteCode();
        }

        return $this->repository->create([
            'user_id' => $userId,
            'type' => 1,
            'invite_code' => $inviteCode,
            'config' => $config,
        ]);
    }

    /**
     * 生成唯一邀请码
     * 
     * @return string
     */
    public function generateInviteCode(): string
    {
        do {
            $code = strtoupper(substr(md5(uniqid((string)mt_rand(), true)), 0, 8));
        } while ($this->repository->getQuery()->where('invite_code', $code)->exists());

        return $code;
    }
}

