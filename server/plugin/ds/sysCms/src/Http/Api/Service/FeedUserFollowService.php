<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Http\Api\Service;

use App\Model\UserProfile;
use Plugin\Ds\SysCms\Model\Article;
use Plugin\Ds\SysCms\Model\FeedPost;
use Plugin\Ds\SysCms\Model\FeedUserFollow;
use Plugin\Ds\SysCms\Model\FeedUserStats;

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

            // 更新统计：减少关注数和粉丝数
            $this->updateStatsCount($userId, 'following_count', -1);
            $this->updateStatsCount($followUserId, 'followers_count', -1);

            return false;
        } else {
            // 添加关注
            FeedUserFollow::create([
                'user_id' => $userId,
                'follow_user_id' => $followUserId,
                'created_at' => date('Y-m-d H:i:s'),
            ]);

            // 更新统计：增加关注数和粉丝数
            $this->updateStatsCount($userId, 'following_count', 1);
            $this->updateStatsCount($followUserId, 'followers_count', 1);

            return true;
        }
    }

    /**
     * 检查是否已关注
     */
    public function isFollowing(int $userId, int $followUserId): int
    {
        return FeedUserFollow::query()
            ->where('user_id', $userId)
            ->where('follow_user_id', $followUserId)
            ->exists() ? 1 : 0;
    }

    /**
     * 获取关注列表
     */
    public function getFollowingList(int $userId, int $page = 1, int $pageSize = 20): array
    {
        return FeedUserFollow::query()
            ->with(['following:user_id,nickname,avatar,signed', 'post:user_id,title,content'])
            ->where('user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->offset(($page - 1) * $pageSize)
            ->limit($pageSize)
            ->get()->map(function (FeedUserFollow $follow) {
                return [
                    'follow_user_id' => $follow->follow_user_id,
                    'user_id' => $follow->user_id,
                    'nickname' => $follow->following?->nickname,
                    'avatar' => $follow->following?->avatar,
                    'signed' => $follow->following?->signed,
                    'title' => $follow->post?->title,
                    'content' => $follow->post?->content
                ];
            })->toArray();
    }

    /**
     * 获取粉丝列表
     */
    public function getFollowersList(int $userId, int $page = 1, int $pageSize = 20): array
    {
        $result = FeedUserFollow::query()
            ->with(['follower:user_id,nickname,avatar,signed'])
            ->where('follow_user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->offset(($page - 1) * $pageSize)
            ->limit($pageSize)
            ->get();

        $followIds = FeedUserFollow::query()
            ->where('user_id', $userId)
            ->whereIn('follow_user_id', $result->pluck('user_id'))
            ->pluck('follow_user_id')->toArray();

        $list = [];
        foreach ($result as $item) {
            $follow = $item->follower;
            $follow->is_mutual = in_array($follow->user_id, $followIds) ? 1 : 0;
            $list[] = $follow;
        }
        return $list;
    }

    /**
     * 获取关注用户的帖子和标题贴（信息流）
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

        return FeedPost::query()
            ->whereIn('user_id', $followUserIds)
            ->where('status', 1)
            ->where('audit_status', 1)
            ->orderBy('created_at', 'desc')
            ->offset($offset)
            ->limit($pageSize)
            ->get()
            ->map(function ($post) {
                return FeedService::formatData($post);
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

    /**
     * 获取用户统计信息
     */
    public function getUserStats(int $userId): array
    {
        $stats = FeedUserStats::getOrCreate($userId);

        return [
            'user_id' => $stats->user_id,
            'following_count' => $stats->following_count,
            'followers_count' => $stats->followers_count,
            'posts_count' => $stats->posts_count,
            'total_likes' => $stats->total_likes,
            'total_shares' => $stats->total_shares,
            'total_comments' => $stats->total_comments,
            'total_views' => $stats->total_views,
        ];
    }

    public function updateStatsCount(int $userId, string $field, int $n): void
    {
        $query = FeedUserStats::query()->where(['user_id' => $userId]);
        if ($n > 0) $query->increment($field); else $query->decrement($field);
    }

    public function updateCommentCount(int $targetType, int $targetId, int $increment): void
    {
        if ($targetType === 1 || $targetType === 2) {
            // 帖子/文章（FeedPost）
            FeedPost::query()->where('id', $targetId)->increment('comment_count', $increment);
        } elseif ($targetType === 3 || $targetType === 4 || $targetType === 6) {
            // 公告/新闻（Article）
            Article::query()->where('id', $targetId)->increment('comment_count', $increment);
        }
    }

    /**
     * 获取目标内容的作者ID
     */
    public function getSourceUserId(int $targetType, int $targetId): ?int
    {
        if ($targetType === 1 || $targetType === 2) {
            // 帖子/文章（FeedPost）
            return FeedPost::query()->where('id', $targetId)->value('user_id');
        } elseif ($targetType === 3 || $targetType === 4 || $targetType === 6) {
            // 公告/新闻（Article）
            return Article::query()->where('id', $targetId)->value('created_by');
        }

        return null;
    }
}
