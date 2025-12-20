<?php
/**
 * FastApp.
 * 12/17/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace Plugin\Ds\SysCms\Http\Api\Service;

use App\Common\Tools;
use App\Http\CurrentUser;
use Hyperf\DbConnection\Db;
use Hyperf\Engine\Coroutine;
use Plugin\Ds\SysCms\Model\Article;
use Plugin\Ds\SysCms\Model\FeedCollect;
use Plugin\Ds\SysCms\Model\FeedComment;
use Plugin\Ds\SysCms\Model\FeedLike;
use Plugin\Ds\SysCms\Model\FeedPost;
use Plugin\Ds\SysCms\Model\FeedTag;
use Plugin\Ds\SysCms\Model\FeedUserReadPosition;

/**
 * Feed数据服务
 *
 * 提供信息流相关数据的查询管理
 */
class FeedService
{
    // ==================== 常量定义 ====================

    // 内容类型
    public const TYPE_POST = 1;        // 帖子
    public const TYPE_ARTICLE = 2;     // 文章（FeedPost type=2）
    public const TYPE_NOTICE = 3;      // 公告
    public const TYPE_NEWS = 4;        // 新闻
    public const TYPE_COMMENT = 5;     // 评论（用于点赞）

    // ==================== 帖子查询 ====================

    /**
     * 获取帖子详情
     */
    public function getPost(int $id): array
    {
        $post = FeedPost::query()
            ->where('id', $id)
            ->where('status', 1)
            ->where('audit_status', 1)
            ->first();

        if (!$post) {
            return [];
        }

        return [
            'id' => $post->id,
            'profile' => self::getProfile($post->user_id),
            'user_id' => $post->user_id,
            'content_type' => $post->content_type,
            'type' => $post->type,
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
     * 获取文章详情（存储原始数据）
     *
     * 注意：此方法返回的是原始的多语言JSON数据
     * 使用 getArticleFormatted() 获取格式化后的数据
     */
    public function getArticle(int $id): array
    {
        $article = Article::query()
            ->where('id', $id)
            ->where('status', 1)
            ->first();

        if (!$article) {
            return [];
        }

        // 存储原始数据（包含多语言JSON）
        return [
            'id' => $article->id,
            'profile' => self::getProfile($article->created_by),
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
            'cover' => Tools::formatLang($article['cover'] ?? [], $userId),
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
                    'profile' => self::getProfile($article->created_by),
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
     * 获取分类文章ID列表
     *
     * @param string $categoryCode 分类代码（news/notice/helpManual等）
     * @param int $page 页码
     * @param int $pageSize 每页数量
     * @return array
     */
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
     * 获取指定分类ID的文章ID列表
     *
     * @param int $categoryId 分类ID
     * @return array
     */
    public function getArticleIdsByCategoryId(int $categoryId): array
    {
        return \Plugin\Ds\SysCms\Model\CategoryCorrelation::query()
            ->where('type', self::TYPE_POST)
            ->where('category_id', $categoryId)
            ->pluck('data_id')
            ->toArray();
    }

    // ==================== 评论查询 ====================

    /**
     * 获取评论列表
     */
    public function getCommentList(int $targetType, int $targetId, int $page = 1, int $pageSize = 20): array
    {
        $offset = ($page - 1) * $pageSize;

        return FeedComment::query()
            ->with(['children' => function ($query) {
                $query->where('status', 1)->orderBy('created_at', 'asc');
            }])
            ->where('target_type', $targetType)
            ->where('target_id', $targetId)
            ->where('parent_id', 0)
            ->where('status', 1)
            ->orderByDesc('id')
            ->offset($offset)
            ->limit($pageSize)
            ->get()->map(function ($comment) {
                $comment['images'] = $comment->images ?? [];
                $userCache = self::getProfile($comment->user_id);
                $comment->username = $userCache['nickname'] ?? '';
                $comment->avatar = $userCache['avatar'] ?? '';
                $comment->is_liked = 0;
                if ($comment->children) {
                    foreach ($comment->children as $child) {
                        $child['images'] = $child->images ?? [];
                        $userCache = self::getProfile($child->user_id);
                        $child->username = $userCache['nickname'] ?? '';
                        $child->avatar = $userCache['avatar'] ?? '';
                        $child->is_liked = 0;
                        if ($child->parent_id != $child->root_id) {
                            $replyToUserCache = self::getProfile($child->reply_to_user_id);
                            $child->reply_to_username = $replyToUserCache['nickname'] ?? '';
                        }
                    }
                }
                return $comment;
            })->toArray();
    }

    /**
     * 增加浏览数（原子操作，避免竞态条件）
     */
    public function incrementViewCount(int $targetType, int $targetId): void
    {
        Coroutine::create(function () use ($targetType, $targetId) {
            // 使用数据库原子操作更新计数
            if ($targetType === self::TYPE_POST || $targetType === self::TYPE_ARTICLE) {
                // 帖子/文章
                FeedPost::query()->where('id', $targetId)->increment('view_count');
            } elseif ($targetType === self::TYPE_NOTICE || $targetType === self::TYPE_NEWS) {
                // 公告/新闻
                Article::query()->where('id', $targetId)->increment('view_count');
            }
        });
    }


    /**
     * 批量获取用户点赞状态
     * @param int $userId 用户ID
     * @param int $targetType 目标类型
     * @param array $targetIds 目标ID数组
     * @return array 返回格式: [target_id => true/false]
     */
    public function batchGetUserLikeStatus(int $userId, int $targetType, array $targetIds): array
    {
        if (empty($targetIds)) {
            return [];
        }

        $liked = FeedLike::query()
            ->where('user_id', $userId)
            ->where('target_type', $targetType)
            ->whereIn('target_id', $targetIds)
            ->pluck('target_id')
            ->toArray();

        $likes = [];
        foreach ($targetIds as $targetId) {
            if (in_array($targetId, $liked)) {
                $likes[] = $targetId;
            }
        }
        return $likes;
    }

    /**
     * 批量获取用户收藏状态
     * @param int $userId 用户ID
     * @param int $targetType 目标类型
     * @param array $targetIds 目标ID数组
     * @return array 返回格式: [target_id => true/false]
     */
    public function batchGetUserCollectStatus(int $userId, int $targetType, array $targetIds): array
    {
        if (empty($targetIds)) {
            return [];
        }

        $collected = FeedCollect::query()
            ->where('user_id', $userId)
            ->where('target_type', $targetType)
            ->whereIn('target_id', $targetIds)
            ->pluck('target_id')
            ->toArray();

        $result = [];
        foreach ($targetIds as $targetId) {
            $result[$targetId] = in_array($targetId, $collected) ? 1 : 0;
        }

        return $result;
    }

    // ==================== 标签查询 ====================

    /**
     * 获取热门标签列表（原始数据）
     */
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

    public static function getProfile(int $userId): array
    {
        return CurrentUser::baseInfo($userId);
    }

    // ==================== 信息流列表查询 ====================
    public static function formatData(FeedPost $post): array
    {
        return [
            'type' => $post->type,
            'id' => $post->id,
            'profile' => self::getProfile($post->user_id),
            'user_id' => $post->user_id,
            'title' => $post->title ?? '',
            'content' => $post->content ?? '',
            'images' => $post->images ?? [],
            'like_count' => $post->like_count ?? 0,
            'share_count' => $post->share_count ?? 0,
            'quote_count' => $post->quote_count ?? 0,
            'view_count' => $post->view_count ?? 0,
            'comment_count' => $post->comment_count ?? 0,
            'created_at' => $post->created_at->toDateTimeString(),
        ];
    }

    /**
     * 获取信息流列表
     * 合并帖子和文章，按时间倒序排列
     */
    public function getFeedList(string $filter, int $page = 1, int $pageSize = 20): array
    {
        $offset = ($page - 1) * $pageSize;
        $query = FeedPost::query()->where(['status' => 1, 'audit_status' => 1]);
        if ($filter == 'latest') $query->orderByDesc('id');
        elseif ($filter == 'top') $query->orderByDesc('is_top');
        elseif ($filter == 'hot') $query->orderByDesc('is_hot');
        return $query->offset($offset)->limit($pageSize)->get()
            ->map(function ($post) {
                return static::formatData($post);
            })->toArray();
    }

    // ==================== 批量操作 ====================

    /**
     * 批量获取内容详情
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

            if ($type === self::TYPE_POST || $type === self::TYPE_ARTICLE) {
                // 帖子/文章
                $post = $this->getPost($id);
                if (!empty($post)) {
                    $result[] = $post;
                }
            } elseif ($type === self::TYPE_NOTICE || $type === self::TYPE_NEWS) {
                // 公告/新闻
                $article = $this->getArticleFormatted($id, $userId);
                if ($article !== null) {
                    $result[] = $article;
                }
            }
        }

        return $result;
    }

    public static function readMessage(int $userId, $feed_type): void
    {
        Coroutine::create(function () use ($userId, $feed_type) {
            if (!$userId) return;
            $t = date('Y-m-d H:i:s');
            $map = ['user_id' => $userId, 'feed_type' => $feed_type];
            // 用户hash表存储
            if (!FeedUserReadPosition::query()->where($map)->update(['last_read_at' => $t])) {
                try {
                    FeedUserReadPosition::query()->create($map);
                } catch (\Exception) {
                }
            }
        });
    }
}
