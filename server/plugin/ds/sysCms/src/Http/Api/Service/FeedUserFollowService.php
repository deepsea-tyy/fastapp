<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Http\Api\Service;

use App\Common\Tools;
use App\Model\UserProfile;
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
    public function isFollowing(int $userId, int $followUserId): array
    {

        $is_following = FeedUserFollow::query()
            ->where('user_id', $userId)
            ->where('follow_user_id', $followUserId)
            ->exists();
        $profile = UserProfile::query()->where('user_id', $userId)->first(['user_id', 'nickname', 'avatar', 'signed']);
        return [
            'is_following' => $is_following,
            'profile' => $profile,
        ];
    }

    /**
     * 获取关注列表
     */
    public function getFollowingList(int $userId, int $page = 1, int $pageSize = 20): array
    {
        $offset = ($page - 1) * $pageSize;
        return FeedUserFollow::query()
            ->with(['profile:user_id,nickname,avatar,signed', 'posts:user_id,title,content'])
            ->where('user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->offset($offset)
            ->limit($pageSize)
            ->get()->map(function (FeedUserFollow $follow) {
                return [
                    'follow_user_id' => $follow->follow_user_id,
                    'user_id' => $follow->user_id,
                    'nickname' => $follow->profile?->nickname,
                    'avatar' => $follow->profile?->avatar,
                    'signed' => $follow->profile?->signed,
                    'title' => $follow->posts?->title,
                    'content' => $follow->posts?->content
                ];
            })->toArray();
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
     * 获取关注用户的帖子和文章（信息流）
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

        return \Plugin\Ds\SysCms\Model\FeedPost::query()
            ->with(['profile:user_id,nickname,avatar'])
            ->whereIn('user_id', $followUserIds)
            ->where('status', 1)
            ->where('audit_status', 1)
            ->orderBy('created_at', 'desc')
            ->offset($offset)
            ->limit($pageSize)
            ->get()
            ->map(function ($post) {
                return [
                    'type' => $post->type ?? 1,
                    'id' => $post->id,
                    'profile' => $post->profile,
                    'user_id' => $post->user_id,
                    'title' => $post->title ?? '',
                    'content' => $post->content ?? '',
                    'images' => $post->images ?? [],
                    'like_count' => $post->like_count ?? 0,
                    'comment_count' => $post->comment_count ?? 0,
                    'created_at' => $post->created_at->toDateTimeString(),
                ];
            })->toArray();

    }

    public function mayInterestedList(int $page, int $pageSize, int $userId): array
    {
        return UserProfile::query()->with(['posts:user_id,title,content'])
            ->whereNotIn('user_id', [$userId])
            ->offset(($page - 1) * $pageSize)
            ->limit($pageSize)
            ->get()->map(function (UserProfile $item) {
                return [
                    'user_id' => $item->user_id,
                    'nickname' => $item->nickname,
                    'avatar' => $item->avatar,
                    'signed' => $item->signed,
                    'title' => $item->posts?->title,
                    'content' => $item->posts?->content
                ];
            })->toArray();
    }
}
