<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Helper;

use Hyperf\Cache\Annotation\Cacheable;
use Hyperf\Cache\Annotation\CacheEvict;
use Hyperf\Cache\Annotation\CachePut;

/**
 * 内容缓存辅助类（全局通用）
 *
 * 支持的内容类型：
 * - feed_post（用户帖子）
 * - article（官方文章）
 * - feed_comment（评论）
 * - feed_tag（标签）
 *
 * 缓存键规范：
 * - content:{type}:{id}              单个内容详情
 * - content:{type}:list:{filter}     内容列表
 * - content:{type}:stats:{id}        统计数据
 * - content:user:{user_id}:action    用户动作状态（点赞/收藏）
 */
class ContentCacheHelper
{
    // ==================== 内容详情缓存 ====================

    /**
     * 获取帖子详情（带缓存）
     */
    #[Cacheable(prefix: 'content:post', value: '_#{id}', ttl: 3600)]
    public static function getPost(int $id): ?array
    {
        // 实际查询逻辑由业务层实现
        return null;
    }

    /**
     * 获取文章详情（带缓存）
     */
    #[Cacheable(prefix: 'content:article', value: '_#{id}', ttl: 3600)]
    public static function getArticle(int $id): ?array
    {
        return null;
    }

    /**
     * 获取评论详情（带缓存）
     */
    #[Cacheable(prefix: 'content:comment', value: '_#{id}', ttl: 1800)]
    public static function getComment(int $id): ?array
    {
        return null;
    }

    /**
     * 获取标签详情（带缓存）
     */
    #[Cacheable(prefix: 'content:tag', value: '_#{id}', ttl: 7200)]
    public static function getTag(int $id): ?array
    {
        return null;
    }

    // ==================== 列表缓存 ====================

    /**
     * 获取信息流列表（带缓存）
     * @param string $filter 筛选条件，如 'latest', 'hot', 'tag:5'
     */
    #[Cacheable(prefix: 'content:feed:list', value: '_#{filter}_#{page}', ttl: 300)]
    public static function getFeedList(string $filter, int $page = 1): array
    {
        return [];
    }

    /**
     * 获取用户帖子列表（带缓存）
     */
    #[Cacheable(prefix: 'content:post:list', value: '_user#{userId}_#{page}', ttl: 600)]
    public static function getUserPosts(int $userId, int $page = 1): array
    {
        return [];
    }

    /**
     * 获取评论列表（带缓存）
     * @param int $targetType 1:帖子 2:文章
     */
    #[Cacheable(prefix: 'content:comment:list', value: '_#{targetType}#{targetId}_#{page}', ttl: 300)]
    public static function getComments(int $targetType, int $targetId, int $page = 1): array
    {
        return [];
    }

    /**
     * 获取热门标签列表（带缓存）
     */
    #[Cacheable(prefix: 'content:tag:hot', value: '_list', ttl: 1800)]
    public static function getHotTags(): array
    {
        return [];
    }

    // ==================== 统计数据缓存 ====================

    /**
     * 获取内容统计数据（带缓存）
     * @param int $targetType 1:帖子 2:文章
     */
    #[Cacheable(prefix: 'content:stats', value: '_#{targetType}#{targetId}', ttl: 600)]
    public static function getStats(int $targetType, int $targetId): array
    {
        return [
            'view_count' => 0,
            'like_count' => 0,
            'comment_count' => 0,
            'share_count' => 0,
            'collect_count' => 0,
        ];
    }

    /**
     * 更新统计数据缓存
     */
    #[CachePut(prefix: 'content:stats', value: '_#{targetType}#{targetId}', ttl: 600)]
    public static function updateStats(int $targetType, int $targetId, array $stats): array
    {
        return $stats;
    }

    // ==================== 用户动作状态缓存 ====================

    /**
     * 获取用户点赞状态（带缓存）
     * @param int $targetType 1:帖子 2:文章 3:评论
     */
    #[Cacheable(prefix: 'content:like', value: '_user#{userId}_#{targetType}#{targetId}', ttl: 1800)]
    public static function getUserLikeStatus(int $userId, int $targetType, int $targetId): bool
    {
        return false;
    }

    /**
     * 获取用户收藏状态（带缓存）
     * @param int $targetType 1:帖子 2:文章
     */
    #[Cacheable(prefix: 'content:collect', value: '_user#{userId}_#{targetType}#{targetId}', ttl: 1800)]
    public static function getUserCollectStatus(int $userId, int $targetType, int $targetId): bool
    {
        return false;
    }

    /**
     * 获取用户关注标签状态（带缓存）
     */
    #[Cacheable(prefix: 'content:follow:tag', value: '_user#{userId}_#{tagId}', ttl: 3600)]
    public static function getUserFollowTagStatus(int $userId, int $tagId): bool
    {
        return false;
    }

    // ==================== 缓存清除 ====================

    /**
     * 清除帖子缓存
     */
    #[CacheEvict(prefix: 'content:post', value: '_#{id}')]
    public static function clearPost(int $id): void
    {
    }

    /**
     * 清除文章缓存
     */
    #[CacheEvict(prefix: 'content:article', value: '_#{id}')]
    public static function clearArticle(int $id): void
    {
    }

    /**
     * 清除评论缓存
     */
    #[CacheEvict(prefix: 'content:comment', value: '_#{id}')]
    public static function clearComment(int $id): void
    {
    }

    /**
     * 清除统计数据缓存
     */
    #[CacheEvict(prefix: 'content:stats', value: '_#{targetType}#{targetId}')]
    public static function clearStats(int $targetType, int $targetId): void
    {
    }

    /**
     * 清除用户点赞状态缓存
     */
    #[CacheEvict(prefix: 'content:like', value: '_user#{userId}_#{targetType}#{targetId}')]
    public static function clearUserLike(int $userId, int $targetType, int $targetId): void
    {
    }

    /**
     * 清除用户收藏状态缓存
     */
    #[CacheEvict(prefix: 'content:collect', value: '_user#{userId}_#{targetType}#{targetId}')]
    public static function clearUserCollect(int $userId, int $targetType, int $targetId): void
    {
    }

    /**
     * 清除信息流列表缓存
     */
    #[CacheEvict(prefix: 'content:feed:list', all: true)]
    public static function clearFeedList(): void
    {
    }

    /**
     * 清除用户帖子列表缓存
     */
    #[CacheEvict(prefix: 'content:post:list', value: '_user#{userId}_*')]
    public static function clearUserPosts(int $userId): void
    {
    }

    /**
     * 清除评论列表缓存
     */
    #[CacheEvict(prefix: 'content:comment:list', value: '_#{targetType}#{targetId}_*')]
    public static function clearCommentList(int $targetType, int $targetId): void
    {
    }

    /**
     * 清除热门标签缓存
     */
    #[CacheEvict(prefix: 'content:tag:hot', value: '_list')]
    public static function clearHotTags(): void
    {
    }

    /**
     * 清除所有内容缓存（慎用）
     */
    #[CacheEvict(prefix: 'content', all: true)]
    public static function clearAll(): void
    {
    }
}
