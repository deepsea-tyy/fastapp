<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Http\Api\Service;

use Carbon\Carbon;
use Hyperf\Collection\Collection;
use Plugin\Ds\SysCms\Model\FeedImpression;
use Plugin\Ds\SysCms\Model\FeedLike;
use Plugin\Ds\SysCms\Model\FeedComment;
use Plugin\Ds\SysCms\Model\FeedPost;
use Plugin\Ds\SysCms\Model\FeedQualityFeedback;

/**
 * 信息流曝光服务
 *
 * 负责记录内容曝光和实现去重策略
 */
class FeedImpressionService
{
    // Feed类型常量
    public const FEED_TYPE_FOLLOWING = 1;    // 关注Feed
    public const FEED_TYPE_RECOMMEND = 2;    // 推荐Feed

    // 内容类型常量
    public const CONTENT_TYPE_POST = 1;      // 帖子
    public const CONTENT_TYPE_ARTICLE = 2;   // 文章
    public const CONTENT_TYPE_NOTICE = 3;    // 公告
    public const CONTENT_TYPE_NEWS = 4;      // 新闻

    /**
     * 记录内容曝光
     *
     * @param int $userId 用户ID
     * @param array $contentIds 内容ID数组
     * @param int $contentType 内容类型
     * @param int $feedType Feed类型
     * @return void
     */
    public function recordImpressions(int $userId, array $contentIds, int $contentType, int $feedType): void
    {
        if (empty($contentIds) || $userId === 0) {
            return;
        }

        $now = date('Y-m-d H:i:s');
        $impressions = [];

        foreach ($contentIds as $contentId) {
            $impressions[] = [
                'user_id' => $userId,
                'content_id' => $contentId,
                'content_type' => $contentType,
                'feed_type' => $feedType,
                'impressed_at' => $now,
            ];
        }

        // 批量插入，忽略重复（使用 insertOrIgnore）
        try {
            FeedImpression::query()->insertOrIgnore($impressions);
        } catch (\Throwable $e) {
        }
    }

    /**
     * 获取推荐Feed（已去重）
     *
     * 直接在SQL层面过滤，不需要候选池策略
     *
     * @param int $userId 用户ID
     * @param string $filter 筛选条件：latest最新 hot热门
     * @param int $page 页码
     * @param int $pageSize 每页数量
     * @return Collection
     */
    public function getDeduplicatedFeed(int $userId, string $filter, int $page, int $pageSize): Collection
    {
        $offset = ($page - 1) * $pageSize;

        // 1. 构建查询
        $query = FeedPost::query()
            ->where('status', 1)
            ->where('audit_status', 1);

        /*// 2. 获取需要排除的内容ID（去重）
        $excludeIds = $this->getExcludeIds($userId, self::CONTENT_TYPE_POST);

        // 排除已曝光/已互动的内容
        if (!empty($excludeIds)) {
            $query->whereNotIn('id', $excludeIds);
        }*/

        // 排序规则
        if ($filter === 'latest') {
            $query->orderByDesc('id');
        } elseif ($filter === 'hot') {
            $query->orderByDesc('is_hot')->orderByDesc('like_count');
        } elseif ($filter === 'top') {
            $query->orderByDesc('is_top');
        }

        // 分页
        return $query->offset($offset)
            ->limit($pageSize)
            ->get();
    }

    /**
     * 获取需要排除的内容ID（私有方法）
     *
     * @param int $userId 用户ID
     * @param int $contentType 内容类型
     * @return array
     */
    private function getExcludeIds(int $userId, int $contentType): array
    {
        $excludeIds = [];

        // 1. 24小时内已曝光的内容（推荐Feed）
        $impressedIds = FeedImpression::query()
            ->where('user_id', $userId)
            ->where('content_type', $contentType)
            ->where('feed_type', self::FEED_TYPE_RECOMMEND)
            ->where('impressed_at', '>=', Carbon::now()->subDay())
            ->pluck('content_id')
            ->toArray();

        $excludeIds = array_merge($excludeIds, $impressedIds);

        // 2. 已点赞的内容
        $likedIds = FeedLike::query()
            ->where('user_id', $userId)
            ->where('target_type', $contentType)
            ->pluck('target_id')
            ->toArray();

        $excludeIds = array_merge($excludeIds, $likedIds);

        // 3. 已评论的内容
        $commentedIds = FeedComment::query()
            ->where('user_id', $userId)
            ->where('target_type', $contentType)
            ->distinct()  // 在查询时去重
            ->pluck('target_id')
            ->toArray();

        $excludeIds = array_merge($excludeIds, $commentedIds);

        // 4. 不感兴趣的内容
        $notInterestedIds = FeedQualityFeedback::query()
            ->where('user_id', $userId)
            ->where('target_type', $contentType)
            ->pluck('target_id')
            ->toArray();

        $excludeIds = array_merge($excludeIds, $notInterestedIds);

        // 去重并返回
        return array_unique($excludeIds);
    }

    /**
     * 获取用户24小时内已曝光的内容ID
     *
     * @param int $userId 用户ID
     * @param int $contentType 内容类型
     * @param int $feedType Feed类型
     * @return array
     */
    public function getRecentImpressions(int $userId, int $contentType, int $feedType): array
    {
        return FeedImpression::query()
            ->where('user_id', $userId)
            ->where('content_type', $contentType)
            ->where('feed_type', $feedType)
            ->where('impressed_at', '>=', Carbon::now()->subDay())
            ->pluck('content_id')
            ->toArray();
    }

    /**
     * 清理过期的曝光记录（7天前）
     *
     * 建议通过定时任务每天执行一次
     *
     * @param int $days 保留天数，默认7天
     * @return int 清理的记录数
     */
    public function cleanOldImpressions(int $days = 7): int
    {
        return FeedImpression::query()
            ->where('impressed_at', '<', Carbon::now()->subDays($days))
            ->delete();
    }

    /**
     * 获取用户的曝光统计
     *
     * @param int $userId 用户ID
     * @param int $days 统计天数，默认7天
     * @return array
     */
    public function getUserImpressionStats(int $userId, int $days = 7): array
    {
        return FeedImpression::query()
            ->where('user_id', $userId)
            ->where('impressed_at', '>=', Carbon::now()->subDays($days))
            ->selectRaw('
                feed_type,
                content_type,
                COUNT(*) as impression_count
            ')
            ->groupBy('feed_type', 'content_type')
            ->get()
            ->toArray();
    }
}
