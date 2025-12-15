<?php

declare(strict_types=1);

namespace App\Service\Feed;

use Plugin\Ds\SysCms\Model\FeedUserFollow;

/**
 * 用户关注服务
 */
class FeedUserFollowService
{
    /**
     * 切换关注状态
     */
    public function toggleFollow(int $userId, int $followUserId): bool
    {
        // 不能关注自己
        if ($userId === $followUserId) {
            throw new \InvalidArgumentException('不能关注自己');
        }

        $isFollowing = $this->isFollowing($userId, $followUserId);

        if ($isFollowing) {
            // 取消关注
            FeedUserFollow::query()
                ->where('user_id', $userId)
                ->where('follow_user_id', $followUserId)
                ->delete();

            // TODO: 更新粉丝数和关注数统计

            return false;
        } else {
            // 添加关注
            FeedUserFollow::create([
                'user_id' => $userId,
                'follow_user_id' => $followUserId,
                'created_at' => date('Y-m-d H:i:s'),
            ]);

            // TODO: 更新粉丝数和关注数统计

            return true;
        }
    }

    /**
     * 检查是否已关注
     */
    public function isFollowing(int $userId, int $followUserId): bool
    {
        return FeedUserFollow::query()
            ->where('user_id', $userId)
            ->where('follow_user_id', $followUserId)
            ->exists();
    }

    /**
     * 获取关注列表
     */
    public function getFollowingList(int $userId, int $page = 1, int $pageSize = 20): array
    {
        $offset = ($page - 1) * $pageSize;

        $follows = FeedUserFollow::query()
            ->where('user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->offset($offset)
            ->limit($pageSize)
            ->get();

        return $follows->pluck('follow_user_id')->toArray();
    }

    /**
     * 获取粉丝列表
     */
    public function getFollowersList(int $userId, int $page = 1, int $pageSize = 20): array
    {
        $offset = ($page - 1) * $pageSize;

        $followers = FeedUserFollow::query()
            ->where('follow_user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->offset($offset)
            ->limit($pageSize)
            ->get();

        return $followers->pluck('user_id')->toArray();
    }

    /**
     * 获取关注数
     */
    public function getFollowingCount(int $userId): int
    {
        return FeedUserFollow::query()
            ->where('user_id', $userId)
            ->count();
    }

    /**
     * 获取粉丝数
     */
    public function getFollowersCount(int $userId): int
    {
        return FeedUserFollow::query()
            ->where('follow_user_id', $userId)
            ->count();
    }

    /**
     * 批量检查关注状态
     */
    public function batchCheckFollowing(int $userId, array $followUserIds): array
    {
        $follows = FeedUserFollow::query()
            ->where('user_id', $userId)
            ->whereIn('follow_user_id', $followUserIds)
            ->pluck('follow_user_id')
            ->toArray();

        $result = [];
        foreach ($followUserIds as $followUserId) {
            $result[$followUserId] = in_array($followUserId, $follows);
        }

        return $result;
    }

    /**
     * 获取关注用户的帖子（信息流）
     */
    public function getFollowingUserPosts(int $userId, int $page = 1, int $pageSize = 20): array
    {
        // 获取关注的用户ID列表
        $followUserIds = FeedUserFollow::query()
            ->where('user_id', $userId)
            ->pluck('follow_user_id')
            ->toArray();

        if (empty($followUserIds)) {
            return [];
        }

        // 查询这些用户的帖子
        $offset = ($page - 1) * $pageSize;

        $posts = \Plugin\Ds\SysCms\Model\FeedPost::query()
            ->whereIn('user_id', $followUserIds)
            ->where('status', 1)
            ->where('audit_status', 1)
            ->orderBy('created_at', 'desc')
            ->offset($offset)
            ->limit($pageSize)
            ->get();

        return $posts->map(function ($post) {
            return [
                'id' => $post->id,
                'user_id' => $post->user_id,
                'title' => $post->title,
                'content' => $post->content,
                'images' => json_decode($post->images ?? '[]', true),
                'like_count' => $post->like_count,
                'comment_count' => $post->comment_count,
                'created_at' => $post->created_at?->toDateTimeString(),
            ];
        })->toArray();
    }
}
