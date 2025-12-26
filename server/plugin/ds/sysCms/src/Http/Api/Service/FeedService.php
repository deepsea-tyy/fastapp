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
    public const TYPE_POST_ARTICLE = 2;     // 标题贴（FeedPost type=2）
    public const TYPE_NOTICE = 3;      // 公告
    public const TYPE_NEWS = 4;        // 新闻
    public const TYPE_COMMENT = 5;     // 评论（用于点赞）
    public const TYPE_ARTICLE = 6;        // 新闻

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
     * 获取标题贴详情（存储原始数据）
     *
     */
    public function getArticle(int $id, string $lang): array
    {
        $article = Article::query()
            ->where('id', $id)
            ->where('lang', $lang)
            ->where('status', 1)
            ->first();

        if (!$article) {
            return [];
        }


        return [
            'id' => $article->id,
            'profile' => self::getProfile($article->created_by),
            'title' => $article->title ?? '',
            'subtitle' => $article->subtitle ?? '',
            'content' => $article->content ?? '',
            'cover' => $article->cover ?? '',
            'author' => $article->author ?? '',
            'view_count' => $article->view_count ?? 0,
            'like_count' => $article->like_count ?? 0,
            'comment_count' => $article->comment_count ?? 0,
            'share_count' => $article->share_count ?? 0,
            'collect_count' => $article->collect_count ?? 0,
            'created_at' => $article->created_at->toDateTimeString(),
            'created_by' => $article->created_by,
        ];
    }


    /**
     * 获取分类文章ID列表
     *
     * @param string $categoryCode 分类代码（news/notice/helpManual等）
     * @param int $page 页码
     * @param int $pageSize 每页数量
     * @param string $keyword 搜索关键词
     * @return array
     */
    public function getCategoryArticleIds(string $categoryCode, int $page = 1, int $pageSize = 20, string $keyword = '', string $lang = ''): array
    {
        $offset = ($page - 1) * $pageSize;

        // 获取分类ID
        $categoryId = \Plugin\Ds\SysCms\Model\Category::query()
            ->where('code', $categoryCode)
            ->value('id');

        if (!$categoryId) {
            return [];
        }

        // 查询标题贴ID列表
        $query = \Plugin\Ds\SysCms\Model\CategoryCorrelation::query()
            ->join('article', 'category_correlation.data_id', '=', 'article.id')
            ->where('type', self::TYPE_POST)
            ->where('article.lang', $lang)
            ->where('category_id', $categoryId);

        // 如果有关键词，关联Article表进行模糊查询
        if (!empty($keyword)) {
            $query->where('article.status', 1)
                ->where('article.title', 'like', '%' . $keyword . '%')
                ->where('article.content', 'like', '%' . $keyword . '%');
        }

        $ids = $query->offset($offset)
            ->limit($pageSize)
            ->orderByDesc('article.sort')
            ->pluck('data_id')
            ->toArray();

        // 批量查询标题贴（避免N+1问题）
        return Article::query()
            ->whereIn('id', $ids)
            ->where('lang', $lang)
            ->where('status', 1)
            ->orderByDesc('sort')
            ->get()->map(function ($article) {
                return FeedService::formatArticle($article);
            })->toArray();
    }

    public function getArticleSearch($keyword = '', int $page = 1, int $pageSize = 20, string $lang = ''): array
    {
        return Article::query()
            ->where('lang', $lang)
            ->where('status', 1)
            ->where('article.status', 1)
            ->where('article.title', 'like', '%' . $keyword . '%')
            ->where('article.content', 'like', '%' . $keyword . '%')
            ->orderByDesc('sort')
            ->get()->map(function ($article) {
                return FeedService::formatArticle($article);
            })->toArray();
    }

    public static function formatArticle(Article $article): array
    {

        return [
            'id' => $article->id,
            'profile' => self::getProfile($article->created_by),
            'title' => $article->title ?? '',
            'subtitle' => $article->subtitle ?? '',
            'brief' => $article->brief ?? '',
            'content' => $article->content ?? '',
            'cover' => $article->cover ?? '',
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
     * 获取指定分类ID的标题贴ID列表
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
    public function getCommentList(int $targetType, int $targetId, int $page = 1, int $pageSize = 20, string $sortBy = 'hot'): array
    {
        $offset = ($page - 1) * $pageSize;

        $query = FeedComment::query()
            ->with(['children' => function ($query) {
                $query->with(['quotedComment'])->where('status', 1)->orderBy('created_at', 'asc');
            }, 'quotedComment'])
            ->where('target_type', $targetType)
            ->where('target_id', $targetId)
            ->where('parent_id', 0)
            ->where('status', 1);

        // 根据排序方式排序
        if ($sortBy === 'hot') {
            // 热门：按回复数降序，回复数相同按点赞数降序，再按时间降序
            $query->orderByDesc('reply_count')->orderByDesc('like_count')->orderByDesc('id');
        } else {
            // 最新：按创建时间降序
            $query->orderByDesc('id');
        }

        return $query->offset($offset)
            ->limit($pageSize)
            ->get()->map(function ($comment) {
                $data = self::formatComment($comment);
                if ($comment->children) {
                    $data['children'] = [];
                    foreach ($comment->children as $child) {
                        $childData = self::formatComment($child);
                        if ($child->parent_id != $child->root_id) {
                            $replyToUserCache = self::getProfile($child->reply_to_user_id);
                            $childData['reply_to_username'] = $replyToUserCache['nickname'] ?? '';
                        }
                        $data['children'][] = $childData;
                    }
                }
                return $data;
            })->toArray();
    }

    public static function formatComment(FeedComment $comment): array
    {
        $userCache = self::getProfile($comment->user_id);

        $data = [
            'id' => $comment->id,
            'target_type' => $comment->target_type,
            'target_id' => $comment->target_id,
            'user_id' => $comment->user_id,
            'username' => $userCache['nickname'] ?? '',
            'avatar' => $userCache['avatar'] ?? '',
            'parent_id' => $comment->parent_id,
            'root_id' => $comment->root_id,
            'reply_to_user_id' => $comment->reply_to_user_id,
            'quoted_comment_id' => $comment->quoted_comment_id,
            'content' => $comment->content ?? '',
            'images' => $comment->images ?? [],
            'like_count' => $comment->like_count ?? 0,
            'reply_count' => $comment->reply_count ?? 0,
            'is_liked' => 0,
            'created_at' => $comment->created_at->toDateTimeString(),
        ];

        // 处理引用评论
        if ($comment->quoted_comment_id) {
            if ($comment->quotedComment) {
                // 引用评论存在，获取引用评论的用户信息
                $quotedUserCache = self::getProfile($comment->quotedComment->user_id);
                $data['quoted_comment'] = [
                    'id' => $comment->quotedComment->id,
                    'user_id' => $comment->quotedComment->user_id,
                    'username' => $quotedUserCache['nickname'] ?? '',
                    'avatar' => $quotedUserCache['avatar'] ?? '',
                    'content' => $comment->quotedComment->content ?? '',
                    'images' => $comment->quotedComment->images ?? [],
                ];
            } else {
                // 引用评论已被删除，返回占位信息
                $data['quoted_comment'] = [
                    'id' => 0,
                    'user_id' => 0,
                    'username' => '未知用户',
                    'avatar' => '',
                    'content' => '该评论已被删除',
                    'images' => [],
                ];
            }
        }

        return $data;
    }

    /**
     * 增加浏览数（原子操作，避免竞态条件）
     */
    public function incrementViewCount(int $targetType, int $targetId): void
    {
        Coroutine::create(function () use ($targetType, $targetId) {
            // 使用数据库原子操作更新计数
            if ($targetType === self::TYPE_POST || $targetType === self::TYPE_POST_ARTICLE) {
                // 帖子/标题贴
                FeedPost::query()->where('id', $targetId)->increment('view_count');
            } elseif ($targetType === self::TYPE_NOTICE || $targetType === self::TYPE_NEWS || $targetType === self::TYPE_ARTICLE) {
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

    public static function formatPost(FeedPost $post): array
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
     * 合并帖子和标题贴，按时间倒序排列
     */
    public function getFeedList(string $filter, int $page = 1, int $pageSize = 20, string $keyword = ''): array
    {
        $offset = ($page - 1) * $pageSize;
        $query = FeedPost::query()->where(['status' => 1, 'audit_status' => 1]);

        // 如果有关键词，进行模糊查询
        if (!empty($keyword)) {
            $query->where(function ($q) use ($keyword) {
                $q->where('title', 'like', "%{$keyword}%")
                    ->orWhere('content', 'like', "%{$keyword}%");
            });
        }

        if ($filter == 'latest') $query->orderByDesc('id');
        elseif ($filter == 'top') $query->orderByDesc('is_top');
        elseif ($filter == 'hot') $query->orderByDesc('is_hot');
        return $query->offset($offset)->limit($pageSize)->get()
            ->map(function ($post) {
                return static::formatPost($post);
            })->toArray();
    }

    // ==================== 批量操作 ====================

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
