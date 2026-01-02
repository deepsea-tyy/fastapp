<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Http\Api\Service;

use Plugin\Ds\Ex\Model\ExUserInvitation;
use Plugin\Ds\Ex\Model\ExCommissionLog;
use Plugin\Ds\Ex\Model\ExUserInviteCode;
use Plugin\Ds\Ex\Model\ExUserRelation;

class InvitationService
{
    /**
     * 获取用户邀请信息
     */
    public function getInvitationInfo(int $uid): array
    {
        $invitationCode = $this->getOrCreateInvitationCode($uid);

        $totalInvitees = ExUserInvitation::query()
            ->where('inviter_uid', $uid)
            ->where('level', 1)
            ->count();

        $effectiveInvitees = ExUserInvitation::query()
            ->where('inviter_uid', $uid)
            ->where('level', 1)
            ->where('status', '>=', 2)
            ->count();

        $totalCommission = ExCommissionLog::query()
            ->where('inviter_uid', $uid)
            ->sum('commission_amount');

        $availableCommission = ExCommissionLog::query()
            ->where('inviter_uid', $uid)
            ->where('status', 1)
            ->sum('commission_amount');

        return [
            'invitation_code' => $invitationCode,
            'invitation_url' => $this->generateInvitationUrl($invitationCode),
            'total_invitees' => $totalInvitees,
            'effective_invitees' => $effectiveInvitees,
            'total_commission' => (float)$totalCommission,
            'available_commission' => (float)$availableCommission,
        ];
    }

    /**
     * 获取或创建邀请码
     */
    protected function getOrCreateInvitationCode(int $uid): string
    {
        return sprintf('INV%06d', $uid);
    }

    /**
     * 生成邀请链接
     */
    protected function generateInvitationUrl(string $code): string
    {
        $baseUrl = env('APP_URL', 'https://example.com');
        return sprintf('%s/register?code=%s', $baseUrl, $code);
    }

    /**
     * 获取邀请列表
     */
    public function getInvitationList(int $uid, ?int $status = null, int $page = 1, int $limit = 20): array
    {
        $query = ExUserInvitation::query()
            ->where('inviter_uid', $uid)
            ->where('level', 1);

        if ($status !== null) {
            $query->where('status', $status);
        }

        $total = $query->count();

        $list = $query
            ->orderByDesc('created_at')
            ->offset(($page - 1) * $limit)
            ->limit($limit)
            ->get()
            ->toArray();

        return [
            'items' => $list,
            'total' => $total,
            'page' => $page,
            'limit' => $limit,
        ];
    }

    /**
     * 获取返佣记录
     */
    public function getCommissionLogs(
        int $uid,
        ?string $startDate = null,
        ?string $endDate = null,
        int $page = 1,
        int $limit = 20
    ): array {
        $query = ExCommissionLog::query()
            ->where('inviter_uid', $uid);

        if ($startDate) {
            $query->where('created_at', '>=', $startDate);
        }

        if ($endDate) {
            $query->where('created_at', '<=', $endDate);
        }

        $total = $query->count();

        $list = $query
            ->orderByDesc('created_at')
            ->offset(($page - 1) * $limit)
            ->limit($limit)
            ->get()
            ->toArray();

        $totalCommission = ExCommissionLog::query()
            ->where('inviter_uid', $uid)
            ->sum('commission_amount');

        $settledCommission = ExCommissionLog::query()
            ->where('inviter_uid', $uid)
            ->where('status', 1)
            ->sum('commission_amount');

        $pendingCommission = ExCommissionLog::query()
            ->where('inviter_uid', $uid)
            ->where('status', 0)
            ->sum('commission_amount');

        return [
            'items' => $list,
            'total' => $total,
            'page' => $page,
            'limit' => $limit,
            'summary' => [
                'total_commission' => (float)$totalCommission,
                'settled_commission' => (float)$settledCommission,
                'pending_commission' => (float)$pendingCommission,
            ],
        ];
    }

    /**
     * 记录邀请关系
     */
    public function recordInvitation(int $inviterUid, int $inviteeUid, string $invitationCode): bool
    {
        $exists = ExUserInvitation::query()
            ->where('invitee_uid', $inviteeUid)
            ->exists();

        if ($exists) {
            return false;
        }

        ExUserInvitation::query()->create([
            'inviter_uid' => $inviterUid,
            'invitee_uid' => $inviteeUid,
            'invitation_code' => $invitationCode,
            'status' => 1,
            'register_time' => now(),
            'level' => 1,
        ]);

        return true;
    }

    // ========== 邀请码管理功能 ==========

    /**
     * 获取用户的默认邀请码
     */
    public function getDefaultInviteCode(int $uid): ?ExUserInviteCode
    {
        return ExUserInviteCode::query()
            ->where('uid', $uid)
            ->where('type', 1)
            ->first();
    }

    /**
     * 创建或获取默认邀请码
     */
    public function createOrGetDefault(int $uid, ?string $inviteCode = null, ?array $config = null): ExUserInviteCode
    {
        $default = $this->getDefaultInviteCode($uid);

        if ($default) {
            return $default;
        }

        // 如果没有邀请码，自动生成
        if (!$inviteCode) {
            $inviteCode = $this->generateUniqueInviteCode();
        }

        return ExUserInviteCode::query()->create([
            'uid' => $uid,
            'type' => 1,
            'invite_code' => $inviteCode,
            'config' => $config,
        ]);
    }

    /**
     * 生成唯一邀请码
     */
    public function generateUniqueInviteCode(): string
    {
        do {
            $code = strtoupper(substr(md5(uniqid((string)mt_rand(), true)), 0, 8));
        } while (ExUserInviteCode::query()->where('invite_code', $code)->exists());

        return $code;
    }

    /**
     * 邀请码分页列表
     */
    public function getInviteCodePage(int $uid, ?int $type = null, ?string $code = null, int $page = 1, int $perPage = 20): array
    {
        $query = ExUserInviteCode::query()->where('uid', $uid);

        if ($type !== null) {
            $query->where('type', $type);
        }

        if ($code) {
            $query->where('invite_code', 'like', "%{$code}%");
        }

        $total = $query->count();

        $list = $query
            ->orderByDesc('id')
            ->offset(($page - 1) * $perPage)
            ->limit($perPage)
            ->get()
            ->toArray();

        return [
            'items' => $list,
            'total' => $total,
            'page' => $page,
            'per_page' => $perPage,
        ];
    }

    /**
     * 创建邀请码
     */
    public function createInviteCode(array $data): ExUserInviteCode
    {
        return ExUserInviteCode::query()->create($data);
    }

    /**
     * 根据ID查找邀请码
     */
    public function findInviteCodeById(int $id): ?ExUserInviteCode
    {
        return ExUserInviteCode::query()->find($id);
    }

    /**
     * 更新邀请码
     */
    public function updateInviteCodeById(int $id, array $data): bool
    {
        return ExUserInviteCode::query()->where('id', $id)->update($data) > 0;
    }

    /**
     * 删除邀请码
     */
    public function deleteInviteCodes(array $ids, int $uid): int
    {
        return ExUserInviteCode::query()
            ->whereIn('id', $ids)
            ->where('uid', $uid)
            ->delete();
    }

    /**
     * 根据邀请码查找邀请码记录
     */
    public function findByInviteCode(string $code): ?ExUserInviteCode
    {
        return ExUserInviteCode::query()->where('invite_code', $code)->first();
    }

    // ========== 用户关系管理功能 ==========

    /**
     * 创建用户关系
     */
    public function createUserRelation(int $uid, int $parentUid): ?ExUserRelation
    {
        // 检查是否已经存在关系
        $exists = ExUserRelation::query()->where('uid', $uid)->exists();
        if ($exists) {
            return null;
        }

        // 如果邀请人是自己，不建立关系
        if ($parentUid === $uid) {
            return null;
        }

        // 获取父级用户的路径和层级
        $parentRelation = ExUserRelation::query()->where('uid', $parentUid)->first();

        if ($parentRelation) {
            // 检查循环引用：如果新用户ID已经在父级路径中，说明存在循环，不建立关系
            if (str_contains($parentRelation->path, '/' . $uid . '/')) {
                return null;
            }
            // 父级有上级，新用户的层级是父级层级+1，路径是父级路径+新用户ID+/
            $level = $parentRelation->level + 1;
            $path = $parentRelation->path . $uid . '/';
        } else {
            // 父级没有上级关系记录，视为根节点，新用户的层级是1，路径是 /父级ID/新用户ID/
            $level = 1;
            $path = '/' . $parentUid . '/' . $uid . '/';
        }

        return ExUserRelation::query()->create([
            'uid' => $uid,
            'parent_uid' => $parentUid,
            'path' => $path,
            'level' => $level,
        ]);
    }

    /**
     * 获取用户的所有下级（支持指定层级）
     */
    public function getUserChildren(int $uid, ?int $level = null): array
    {
        $relation = ExUserRelation::query()->where('uid', $uid)->first();
        if (!$relation) {
            return [];
        }

        $query = ExUserRelation::query()->where('path', 'like', $relation->path . '%');

        if ($level !== null) {
            $query->where('level', $relation->level + $level);
        }

        return $query->get()->toArray();
    }

    /**
     * 获取用户的直接下级
     */
    public function getDirectChildren(int $uid): array
    {
        return ExUserRelation::query()
            ->where('parent_uid', $uid)
            ->get()
            ->toArray();
    }
}

