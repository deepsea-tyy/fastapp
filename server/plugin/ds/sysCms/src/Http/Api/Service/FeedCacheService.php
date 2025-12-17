<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Http\Api\Service;

use App\Common\Tools;
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
    // ==================== 常量定义 ====================

    // 内容类型
    public const TYPE_POST = 1;
    public const TYPE_ARTICLE = 2;
    public const TYPE_COMMENT = 3;

    // 缓存TTL（秒）
    private const TTL_CONTENT = 3600;      // 内容详情：1小时
    private const TTL_STATS = 600;         // 统计数据：10分钟
    private const TTL_LIST = 300;          // 列表数据：5分钟
    private const TTL_USER_ACTION = 1800;  // 用户动作：30分钟

    // ==================== 帖子缓存 ====================

    /**
     * 获取帖子详情（带缓存）
     */
    #[Cacheable(prefix: 'content:post', value: '_#{id}', ttl: self::TTL_CONTENT)]
    public function getPost(int $id): array
    {
        $post = FeedPost::query()
            ->with(['profile:user_id,nickname,avatar'])
            ->where('id', $id)
            ->where('status', 1)
            ->where('audit_status', 1)
            ->first();

        if (!$post) {
            return [];
        }

        return [
            'id' => $post->id,
            'profile' => $post->profile,
            'user_id' => $post->user_id,
            'content_type' => $post->content_type,
            'title' => $post->title ?? '',
            'content' => $post->content ?? '',
            'images' => $post->images ?? [],
            'videos' => $post->videos ?? [],
            'is_top' => $post->is_top,
            'is_hot' => $post->is_hot,
            'view_count' => $post->view_count ?? 0,
            'like_count' => $post->like_count ?? 0,
            'comment_count' => $post->comment_count ?? 0,
            'share_count' => $post->share_count ?? 0,
            'collect_count' => $post->collect_count ?? 0,
            'created_at' => $post->created_at->toDateTimeString(),
        ];
    }

    /**
     * 获取文章详情（带缓存，存储原始数据）
     *
     * 注意：此方法缓存的是原始的多语言JSON数据
     * 使用 getArticleFormatted() 获取格式化后的数据
     */
    #[Cacheable(prefix: 'content:article', value: '_#{id}', ttl: self::TTL_CONTENT)]
    public function getArticle(int $id): array
    {
        $article = Article::query()
            ->with(['profile:user_id,nickname,avatar'])
            ->where('id', $id)
            ->where('status', 1)
            ->first();

        if (!$article) {
            return [];
        }

        // 存储原始数据（包含多语言JSON）
        return [
            'id' => $article->id,
            'profile' => $article->profile,
            'title' => $article->title ?? [],
            'subtitle' => $article->subtitle ?? [],
            'brief' => $article->brief ?? [],
            'content' => $article->content ?? [],
            'cover' => $article->cover ?? [],
            'author' => $article->author ?? '',
            'view_count' => $article->view_count ?? 0,
            'like_count' => $article->like_count ?? 0,
            'comment_count' => $article->comment_count ?? 0,
            'share_count' => $article->share_count ?? 0,
            'collect_count' => $article->collect_count ?? 0,
            'created_at' => $article->created_at->toDateTimeString(),
        ];
    }

    /**
     * 获取格式化后的文章详情（支持多语言）
     *
     * @param int $id 文章ID
     * @param int $userId 用户ID（用于获取用户语言偏好）
     * @return array|null
     */
    public function getArticleFormatted(int $id, int $userId = 0): ?array
    {
        $article = $this->getArticle($id);

        if (empty($article)) {
            return null;
        }

        return [
            'id' => $article['id'],
            'title' => Tools::formatLang($article['title'] ?? [], $userId),
            'subtitle' => Tools::formatLang($article['subtitle'] ?? [], $userId),
            'brief' => Tools::formatLang($article['brief'] ?? [], $userId),
            'content' => Tools::formatLang($article['content'] ?? [], $userId),
            'cover' => $article['cover'] ?? [],
            'author' => $article['author'] ?? '',
            'view_count' => $article['view_count'] ?? 0,
            'like_count' => $article['like_count'] ?? 0,
            'comment_count' => $article['comment_count'] ?? 0,
            'share_count' => $article['share_count'] ?? 0,
            'collect_count' => $article['collect_count'] ?? 0,
            'created_at' => $article['created_at'] ?? '',
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

    /**
     * 批量获取格式化后的文章列表
     *
     * @param array $articleIds 文章ID数组
     * @param int $userId 用户ID（用于多语言格式化）
     * @return array
     */
    public function batchGetArticlesFormatted(array $articleIds, int $userId = 0): array
    {
        if (empty($articleIds)) {
            return [];
        }

        // 批量查询文章（避免N+1问题）
        $articles = Article::query()
            ->with(['profile:user_id,nickname,avatar'])
            ->whereIn('id', $articleIds)
            ->where('status', 1)
            ->get()
            ->keyBy('id');

        $result = [];
        foreach ($articleIds as $id) {
            $article = $articles->get($id);
            if ($article) {
                $result[] = [
                    'id' => $article->id,
                    'profile' => $article->profile,
                    'title' => Tools::formatLang($article->title ?? [], $userId),
                    'subtitle' => Tools::formatLang($article->subtitle ?? [], $userId),
                    'brief' => Tools::formatLang($article->brief ?? [], $userId),
                    'content' => Tools::formatLang($article->content ?? [], $userId),
                    'cover' => $article->cover ?? [],
                    'author' => $article->author ?? '',
                    'view_count' => $article->view_count ?? 0,
                    'like_count' => $article->like_count ?? 0,
                    'comment_count' => $article->comment_count ?? 0,
                    'share_count' => $article->share_count ?? 0,
                    'collect_count' => $article->collect_count ?? 0,
                    'created_at' => $article->created_at->toDateTimeString(),
                ];
            }
        }

        return $result;
    }

    /**
     * 获取分类文章ID列表（带缓存）
     *
     * @param string $categoryCode 分类代码（news/notice/helpManual等）
     * @param int $page 页码
     * @param int $pageSize 每页数量
     * @return array
     */
    #[Cacheable(prefix: 'content:article:category', value: '_#{categoryCode}_#{page}_#{pageSize}', ttl: self::TTL_STATS)]
    public function getCategoryArticleIds(string $categoryCode, int $page = 1, int $pageSize = 20): array
    {
        $offset = ($page - 1) * $pageSize;

        // 获取分类ID
        $categoryId = \Plugin\Ds\SysCms\Model\Category::query()
            ->where('code', $categoryCode)
            ->value('id');

        if (!$categoryId) {
            return [];
        }

        // 查询文章ID列表
        return \Plugin\Ds\SysCms\Model\CategoryCorrelation::query()
            ->where('type', self::TYPE_POST)
            ->where('category_id', $categoryId)
            ->offset($offset)
            ->limit($pageSize)
            ->orderByDesc('data_id')
            ->pluck('data_id')
            ->toArray();
    }

    /**
     * 获取指定分类ID的文章ID列表（带缓存）
     *
     * @param int $categoryId 分类ID
     * @return array
     */
    #[Cacheable(prefix: 'content:article:category:id', value: '_#{categoryId}', ttl: self::TTL_STATS)]
    public function getArticleIdsByCategoryId(int $categoryId): array
    {
        return \Plugin\Ds\SysCms\Model\CategoryCorrelation::query()
            ->where('type', self::TYPE_POST)
            ->where('category_id', $categoryId)
            ->pluck('data_id')
            ->toArray();
    }

    /**
     * 清除分类文章列表缓存
     *
     * @param string $categoryCode 分类代码
     */
    #[CacheEvict(prefix: 'content:article:category', value: '_#{categoryCode}_*')]
    public function clearCategoryArticles(string $categoryCode): void
    {
    }

    /**
     * 清除指定分类ID的文章列表缓存
     *
     * @param int $categoryId 分类ID
     */
    #[CacheEvict(prefix: 'content:article:category:id', value: '_#{categoryId}')]
    public function clearCategoryArticlesById(int $categoryId): void
    {
    }

    // ==================== 评论缓存 ====================

    /**
     * 获取评论列表（带缓存）
     */
    #[Cacheable(prefix: 'content:comment:list', value: '_#{targetType}#{targetId}_#{page}', ttl: self::TTL_LIST)]
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
                'content' => $comment->content ?? '',
                'images' => $comment->images ?? [],
                'like_count' => $comment->like_count ?? 0,
                'reply_count' => $comment->reply_count ?? 0,
                'created_at' => $comment->created_at->toDateTimeString(),
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
    #[Cacheable(prefix: 'content:stats', value: '_#{targetType}#{targetId}', ttl: self::TTL_STATS)]
    public function getStats(int $targetType, int $targetId): array
    {
        if ($targetType === self::TYPE_POST) {
            // 帖子统计
            $post = FeedPost::find($targetId);
            if (!$post) {
                return [];
            }

            return [
                'view_count' => $post->view_count ?? 0,
                'like_count' => $post->like_count ?? 0,
                'comment_count' => $post->comment_count ?? 0,
                'share_count' => $post->share_count ?? 0,
                'collect_count' => $post->collect_count ?? 0,
            ];
        } elseif ($targetType === self::TYPE_ARTICLE) {
            // 文章统计
            $article = Article::find($targetId);
            if (!$article) {
                return [];
            }

            return [
                'view_count' => $article->view_count ?? 0,
                'like_count' => $article->like_count ?? 0,
                'comment_count' => $article->comment_count ?? 0,
                'share_count' => $article->share_count ?? 0,
                'collect_count' => $article->collect_count ?? 0,
            ];
        }

        return [];
    }

    /**
     * 更新统计数据缓存
     */
    #[CachePut(prefix: 'content:stats', value: '_#{targetType}#{targetId}', ttl: self::TTL_STATS)]
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
     * 增加浏览数（原子操作，避免竞态条件）
     */
    public function incrementViewCount(int $targetType, int $targetId): void
    {
        // 使用数据库原子操作更新计数
        if ($targetType === self::TYPE_POST) {
            Db::table('feed_post')
                ->where('id', $targetId)
                ->increment('view_count');
        } elseif ($targetType === self::TYPE_ARTICLE) {
            Db::table('article')
                ->where('id', $targetId)
                ->increment('view_count');
        }

        // 清除缓存，下次查询时重新从数据库获取准确的值
        $this->clearStats($targetType, $targetId);
    }

    // ==================== 用户动作状态缓存 ====================

    /**
     * 获取用户点赞状态（带缓存）
     */
    #[Cacheable(prefix: 'content:like', value: '_user#{userId}_#{targetType}#{targetId}', ttl: self::TTL_USER_ACTION)]
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
    #[Cacheable(prefix: 'content:collect', value: '_user#{userId}_#{targetType}#{targetId}', ttl: self::TTL_USER_ACTION)]
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
     * 获取热门标签列表（原始数据，带缓存）
     */
    #[Cacheable(prefix: 'content:tag:hot', value: '_list', ttl: self::TTL_USER_ACTION)]
    private function getHotTagsRaw(int $limit = 10): array
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
                'name' => $tag->name ?? [],
                'icon' => $tag->icon ?? '',
                'color' => $tag->color ?? '',
                'post_count' => $tag->post_count ?? 0,
                'follow_count' => $tag->follow_count ?? 0,
                'is_hot' => $tag->is_hot,
            ];
        })->toArray();
    }

    /**
     * 获取热门标签列表（格式化多语言）
     */
    public function getHotTags(int $limit = 10, int $userId = 0): array
    {
        $tags = $this->getHotTagsRaw($limit);

        return array_map(function ($tag) use ($userId) {
            $tag['name'] = Tools::formatLang($tag['name'], $userId);
            return $tag;
        }, $tags);
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
    #[Cacheable(prefix: 'content:feed:list', value: '_#{filter}_#{page}', ttl: self::TTL_LIST)]
    public function getFeedList(string $filter, int $page = 1, int $pageSize = 20): array
    {
        $offset = ($page - 1) * $pageSize;

        // 这里简化处理，实际应该根据filter参数查询不同的数据
        $posts = FeedPost::query()
            ->with(['profile:user_id,nickname,avatar'])
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
     *
     * @param array $items 格式: [['type' => TYPE_POST, 'id' => 1], ...]
     * @param int $userId 用户ID（用于文章多语言格式化）
     * @return array
     */
    public function batchGetContents(array $items, int $userId = 0): array
    {
        $result = [];

        foreach ($items as $item) {
            $type = $item['type'];
            $id = $item['id'];

            if ($type === self::TYPE_POST) {
                $post = $this->getPost($id);
                if (!empty($post)) {
                    $result[] = $post;
                }
            } elseif ($type === self::TYPE_ARTICLE) {
                $article = $this->getArticleFormatted($id, $userId);
                if ($article !== null) {
                    $result[] = $article;
                }
            }
        }

        return $result;
    }

    /**
     * 批量清除内容缓存
     */
    public function batchClearContents(array $items): void
    {
        foreach ($items as $item) {
            $type = $item['type'];
            $id = $item['id'];

            if ($type === self::TYPE_POST) {
                $this->clearPost($id);
            } elseif ($type === self::TYPE_ARTICLE) {
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
