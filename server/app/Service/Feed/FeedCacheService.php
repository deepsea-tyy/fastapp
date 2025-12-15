<?php

declare(strict_types=1);

namespace App\Service\Feed;

use Hyperf\Cache\Annotation\Cacheable;
use Hyperf\Cache\Annotation\CacheEvict;
use Hyperf\Cache\Annotation\CachePut;
use Hyperf\DbConnection\Db;
use Plugin\Ds\SysCms\Model\Article;
use Plugin\Ds\SysCms\Model\FeedCollect;
use Plugin\Ds\SysCms\Model\FeedComment;
use Plugin\Ds\SysCms\Model\FeedLike;
use Plugin\Ds\SysCms\Model\FeedPost;
use Plugin\Ds\SysCms\Model\FeedTag;

/**
 * Feed缓存服务
 *
 * 提供信息流相关数据的缓存管理
 */
class FeedCacheService
{
    // ==================== 帖子缓存 ====================

    /**
     * 获取帖子详情（带缓存）
     */
    #[Cacheable(prefix: 'content:post', value: '_#{id}', ttl: 3600)]
    public function getPost(int $id): ?array
    {
        $post = FeedPost::query()
            ->where('id', $id)
            ->where('status', 1)
            ->where('audit_status', 1)
            ->first();

        if (!$post) {
            return null;
        }

        return [
            'id' => $post->id,
            'user_id' => $post->user_id,
            'content_type' => $post->content_type,
            'title' => $post->title,
            'content' => $post->content,
            'images' => json_decode($post->images ?? '[]', true),
            'videos' => json_decode($post->videos ?? '[]', true),
            'is_top' => $post->is_top,
            'is_hot' => $post->is_hot,
            'view_count' => $post->view_count,
            'like_count' => $post->like_count,
            'comment_count' => $post->comment_count,
            'share_count' => $post->share_count,
            'collect_count' => $post->collect_count,
            'created_at' => $post->created_at?->toDateTimeString(),
        ];
    }

    /**
     * 获取文章详情（带缓存）
     */
    #[Cacheable(prefix: 'content:article', value: '_#{id}', ttl: 3600)]
    public function getArticle(int $id): ?array
    {
        $article = Article::query()
            ->where('id', $id)
            ->where('status', 1)
            ->first();

        if (!$article) {
            return null;
        }

        return [
            'id' => $article->id,
            'title' => $article->title,
            'content' => $article->content,
            'cover' => $article->cover,
            'author' => $article->author,
            'views' => $article->views,
            'comment' => $article->comment,
            'created_at' => $article->created_at?->toDateTimeString(),
        ];
    }

    /**
     * 清除帖子缓存
     */
    #[CacheEvict(prefix: 'content:post', value: '_#{id}')]
    public function clearPost(int $id): void
    {
    }

    /**
     * 清除文章缓存
     */
    #[CacheEvict(prefix: 'content:article', value: '_#{id}')]
    public function clearArticle(int $id): void
    {
    }

    // ==================== 评论缓存 ====================

    /**
     * 获取评论列表（带缓存）
     */
    #[Cacheable(prefix: 'content:comment:list', value: '_#{targetType}#{targetId}_#{page}', ttl: 300)]
    public function getCommentList(int $targetType, int $targetId, int $page = 1, int $pageSize = 20): array
    {
        $offset = ($page - 1) * $pageSize;

        $comments = FeedComment::query()
            ->where('target_type', $targetType)
            ->where('target_id', $targetId)
            ->where('parent_id', 0)
            ->where('status', 1)
            ->orderBy('created_at', 'desc')
            ->offset($offset)
            ->limit($pageSize)
            ->get();

        return $comments->map(function ($comment) {
            return [
                'id' => $comment->id,
                'user_id' => $comment->user_id,
                'content' => $comment->content,
                'images' => json_decode($comment->images ?? '[]', true),
                'like_count' => $comment->like_count,
                'reply_count' => $comment->reply_count,
                'created_at' => $comment->created_at?->toDateTimeString(),
            ];
        })->toArray();
    }

    /**
     * 清除评论列表缓存
     */
    #[CacheEvict(prefix: 'content:comment:list', value: '_#{targetType}#{targetId}_*')]
    public function clearCommentList(int $targetType, int $targetId): void
    {
    }

    // ==================== 统计数据缓存 ====================

    /**
     * 获取内容统计数据（带缓存）
     */
    #[Cacheable(prefix: 'content:stats', value: '_#{targetType}#{targetId}', ttl: 600)]
    public function getStats(int $targetType, int $targetId): array
    {
        if ($targetType === 1) {
            // 帖子统计
            $post = FeedPost::find($targetId);
            if (!$post) {
                return $this->getEmptyStats();
            }

            return [
                'view_count' => $post->view_count,
                'like_count' => $post->like_count,
                'comment_count' => $post->comment_count,
                'share_count' => $post->share_count,
                'collect_count' => $post->collect_count,
            ];
        } elseif ($targetType === 2) {
            // 文章统计
            $article = Article::find($targetId);
            if (!$article) {
                return $this->getEmptyStats();
            }

            return [
                'view_count' => $article->views,
                'like_count' => 0, // article表没有like_count字段
                'comment_count' => $article->comment,
                'share_count' => 0, // article表没有share_count字段
                'collect_count' => 0, // article表没有collect_count字段
            ];
        }

        return $this->getEmptyStats();
    }

    /**
     * 更新统计数据缓存
     */
    #[CachePut(prefix: 'content:stats', value: '_#{targetType}#{targetId}', ttl: 600)]
    public function updateStats(int $targetType, int $targetId, array $stats): array
    {
        return $stats;
    }

    /**
     * 清除统计数据缓存
     */
    #[CacheEvict(prefix: 'content:stats', value: '_#{targetType}#{targetId}')]
    public function clearStats(int $targetType, int $targetId): void
    {
    }

    /**
     * 增加浏览数（异步更新数据库，同步更新缓存）
     */
    public function incrementViewCount(int $targetType, int $targetId): void
    {
        // 异步更新数据库
        if ($targetType === 1) {
            Db::table('feed_post')
                ->where('id', $targetId)
                ->increment('view_count');
        } elseif ($targetType === 2) {
            Db::table('article')
                ->where('id', $targetId)
                ->increment('views');
        }

        // 更新缓存
        $stats = $this->getStats($targetType, $targetId);
        $stats['view_count']++;
        $this->updateStats($targetType, $targetId, $stats);
    }

    private function getEmptyStats(): array
    {
        return [
            'view_count' => 0,
            'like_count' => 0,
            'comment_count' => 0,
            'share_count' => 0,
            'collect_count' => 0,
        ];
    }

    // ==================== 用户动作状态缓存 ====================

    /**
     * 获取用户点赞状态（带缓存）
     */
    #[Cacheable(prefix: 'content:like', value: '_user#{userId}_#{targetType}#{targetId}', ttl: 1800)]
    public function getUserLikeStatus(int $userId, int $targetType, int $targetId): bool
    {
        return FeedLike::query()
            ->where('user_id', $userId)
            ->where('target_type', $targetType)
            ->where('target_id', $targetId)
            ->exists();
    }

    /**
     * 获取用户收藏状态（带缓存）
     */
    #[Cacheable(prefix: 'content:collect', value: '_user#{userId}_#{targetType}#{targetId}', ttl: 1800)]
    public function getUserCollectStatus(int $userId, int $targetType, int $targetId): bool
    {
        return FeedCollect::query()
            ->where('user_id', $userId)
            ->where('target_type', $targetType)
            ->where('target_id', $targetId)
            ->exists();
    }

    /**
     * 清除用户点赞状态缓存
     */
    #[CacheEvict(prefix: 'content:like', value: '_user#{userId}_#{targetType}#{targetId}')]
    public function clearUserLike(int $userId, int $targetType, int $targetId): void
    {
    }

    /**
     * 清除用户收藏状态缓存
     */
    #[CacheEvict(prefix: 'content:collect', value: '_user#{userId}_#{targetType}#{targetId}')]
    public function clearUserCollect(int $userId, int $targetType, int $targetId): void
    {
    }

    // ==================== 标签缓存 ====================

    /**
     * 获取热门标签列表（带缓存）
     */
    #[Cacheable(prefix: 'content:tag:hot', value: '_list', ttl: 1800)]
    public function getHotTags(int $limit = 10): array
    {
        $tags = FeedTag::query()
            ->where('status', 1)
            ->orderByDesc('is_hot')
            ->orderByDesc('follow_count')
            ->limit($limit)
            ->get();

        return $tags->map(function ($tag) {
            return [
                'id' => $tag->id,
                'name' => json_decode($tag->name, true),
                'icon' => $tag->icon,
                'color' => $tag->color,
                'post_count' => $tag->post_count,
                'follow_count' => $tag->follow_count,
                'is_hot' => $tag->is_hot,
            ];
        })->toArray();
    }

    /**
     * 清除热门标签缓存
     */
    #[CacheEvict(prefix: 'content:tag:hot', value: '_list')]
    public function clearHotTags(): void
    {
    }

    // ==================== 信息流列表缓存 ====================

    /**
     * 获取信息流列表（带缓存）
     */
    #[Cacheable(prefix: 'content:feed:list', value: '_#{filter}_#{page}', ttl: 300)]
    public function getFeedList(string $filter, int $page = 1, int $pageSize = 20): array
    {
        $offset = ($page - 1) * $pageSize;

        // 这里简化处理，实际应该根据filter参数查询不同的数据
        $posts = FeedPost::query()
            ->where('status', 1)
            ->where('audit_status', 1)
            ->orderByDesc('is_top')
            ->orderByDesc('created_at')
            ->offset($offset)
            ->limit($pageSize)
            ->get();

        return $posts->map(function ($post) {
            return [
                'type' => 'post',
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

    /**
     * 清除信息流列表缓存
     */
    #[CacheEvict(prefix: 'content:feed:list', all: true)]
    public function clearFeedList(): void
    {
    }

    // ==================== 批量操作 ====================

    /**
     * 批量获取内容详情（带缓存）
     */
    public function batchGetContents(array $items): array
    {
        $result = [];

        foreach ($items as $item) {
            $type = $item['type']; // 1:post, 2:article
            $id = $item['id'];

            if ($type === 1) {
                $result[] = $this->getPost($id);
            } elseif ($type === 2) {
                $result[] = $this->getArticle($id);
            }
        }

        return array_filter($result); // 过滤掉null值
    }

    /**
     * 批量清除内容缓存
     */
    public function batchClearContents(array $items): void
    {
        foreach ($items as $item) {
            $type = $item['type'];
            $id = $item['id'];

            if ($type === 1) {
                $this->clearPost($id);
            } elseif ($type === 2) {
                $this->clearArticle($id);
            }

            // 同时清除统计数据
            $this->clearStats($type, $id);
        }
    }

    /**
     * 清除所有内容缓存（慎用）
     */
    #[CacheEvict(prefix: 'content', all: true)]
    public function clearAll(): void
    {
    }
}
