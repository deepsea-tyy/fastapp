<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Http\Api\Controller;

use App\Common\AbstractController;
use App\Common\Middleware\TokenMiddleware;
use App\Common\Result;
use App\Common\Swagger\ResultResponse;
use App\Common\Tools;
use App\Http\CurrentUser;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\Swagger\Annotation\Delete;
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\HyperfServer;
use Hyperf\Swagger\Annotation\JsonContent;
use Hyperf\Swagger\Annotation\Post;
use Hyperf\Swagger\Annotation\QueryParameter;
use Hyperf\Swagger\Annotation\RequestBody;
use Plugin\Ds\SysCms\Http\Api\Service\FeedService;
use Plugin\Ds\SysCms\Http\Api\Service\FeedUserFollowService;
use Plugin\Ds\SysCms\Model\Article;
use Plugin\Ds\SysCms\Model\FeedComment;
use Plugin\Ds\SysCms\Model\FeedPost;

/**
 * 信息流评论API控制器
 */
#[HyperfServer(name: 'http')]
class FeedCommentController extends AbstractController
{
    public function __construct(
        private readonly FeedService           $feedService,
        private readonly FeedUserFollowService $followService,
        private readonly CurrentUser           $currentUser
    )
    {
    }

    #[Get(
        path: '/api/feed/comment/list',
        operationId: 'feedCommentList',
        summary: '获取评论列表',
        tags: ['信息流-评论']
    )]
    #[QueryParameter(name: 'target_type', description: '目标类型：1帖子 2文章 3公告 4新闻', required: true, example: '1')]
    #[QueryParameter(name: 'target_id', description: '目标ID', required: true, example: '1')]
    #[QueryParameter(name: 'page', description: '页码', example: '1')]
    #[QueryParameter(name: 'page_size', description: '每页数量', example: '20')]
    #[QueryParameter(name: 'sort_by', description: '排序方式：hot热门 latest最新', example: 'hot')]
    #[ResultResponse(instance: new Result())]
    public function list(): Result
    {
        $params = $this->getRequestData();
        $targetType = (int)$params['target_type'];
        $targetId = (int)$params['target_id'];
        $page = (int)($params['page'] ?? 1);
        $pageSize = (int)($params['page_size'] ?? 20);
        $sortBy = $params['sort_by'] ?? 'hot';

        // 获取评论列表（自动使用缓存）
        $list = $this->feedService->getCommentList($targetType, $targetId, $page, $pageSize, $sortBy);

        // 获取当前用户ID（如果已登录）
        $userId = $this->currentUser->id();
        if ($userId) {
            // 收集所有评论ID（包括子评论）
            $commentIds = [];
            foreach ($list as $comment) {
                $commentIds[] = $comment['id'];
                if (!empty($comment['children'])) {
                    $commentIds = array_merge($commentIds, array_column($comment['children'], 'id'));
                }
            }

            // 批量获取用户点赞状态（评论类型为 TYPE_COMMENT = 5）
            if (!empty($commentIds)) {
                $likeStatusMap = $this->feedService->batchGetUserLikeStatus(
                    $userId,
                    FeedService::TYPE_COMMENT,
                    $commentIds
                );

                // 将点赞状态添加到评论数据中
                foreach ($list as &$comment) {
                    $comment['is_liked'] = in_array($comment['id'], $likeStatusMap) ? 1 : 0;
                    if (!empty($comment['children'])) {
                        foreach ($comment['children'] as &$child) {
                            $child['is_liked'] = in_array($child['id'], $likeStatusMap) ? 1 : 0;
                        }
                    }
                }
            }
        }

        return $this->success(['list' => $list]);
    }

    #[Get(
        path: '/api/feed/comment/replies',
        operationId: 'feedCommentReplies',
        summary: '获取评论的回复列表',
        tags: ['信息流-评论']
    )]
    #[QueryParameter(name: 'id', description: '评论ID', example: '1')]
    #[QueryParameter(name: 'page', description: '页码', example: '1')]
    #[QueryParameter(name: 'page_size', description: '每页数量', example: '20')]
    #[ResultResponse(instance: new Result())]
    public function replies(): Result
    {
        $page = $this->getPage();
        $pageSize = $this->getPageSize();
        $offset = ($page - 1) * $pageSize;

        $replies = FeedComment::query()
            ->where('parent_id', $this->getRequest()->input('id'))
            ->where('status', 1)
            ->orderBy('created_at', 'asc')
            ->offset($offset)
            ->limit($pageSize)
            ->get();

        $list = $replies->map(function ($reply) {
            $reply->images = $reply->images ?? [];
            return $reply;
        })->toArray();

        return $this->success(['list' => $list]);
    }

    #[Post(
        path: '/api/feed/comment/create',
        operationId: 'feedCommentCreate',
        summary: '创建评论',
        tags: ['信息流-评论']
    )]
    #[RequestBody(content: new JsonContent(
        required: ['target_type', 'target_id', 'content'],
        properties: [
            'target_type' => ['type' => 'integer', 'description' => '目标类型：1帖子 2文章 3公告 4新闻', 'example' => 1],
            'target_id' => ['type' => 'integer', 'description' => '目标ID', 'example' => 1],
            'parent_id' => ['type' => 'integer', 'description' => '父评论ID，0为顶级评论', 'example' => 0],
            'reply_to_user_id' => ['type' => 'integer', 'description' => '回复的用户ID'],
            'quoted_comment_id' => ['type' => 'integer', 'description' => '引用的评论ID'],
            'content' => ['type' => 'string', 'description' => '评论内容', 'example' => '这是一条评论'],
            'images' => ['type' => 'array', 'items' => ['type' => 'string'], 'description' => '图片URL列表'],
        ]
    ))]
    #[Middleware(TokenMiddleware::class)]
    #[ResultResponse(instance: new Result())]
    public function create(): Result
    {
        $data = $this->getRequestData();
        $data['user_id'] = $this->currentUser->id();
        $targetType = (int)$data['target_type'];
        $targetId = (int)$data['target_id'];
        $parentId = (int)($data['parent_id'] ?? 0);

        // 确定root_id
        if ($parentId > 0) {
            $parentComment = FeedComment::find($parentId);
            if ($parentComment) {
                $data['root_id'] = $parentComment->root_id ?: $parentId;
            }
        }

        // 创建评论
        $comment = new FeedComment();
        $comment->fill($data);
        $comment->save();
        // 更新目标内容的评论数
        $this->updateCommentCount($targetType, $targetId, 1);

        // 更新目标内容作者的总评论数统计
        $targetAuthorId = $this->getTargetAuthorId($targetType, $targetId);
        if ($targetAuthorId) {
            $this->followService->incrementUserCommentCount($targetAuthorId);
        }

        // 更新父评论的回复数
        if ($parentId > 0) {
            FeedComment::query()->where('id', $parentId)->increment('reply_count');

            // 如果有根评论且根评论不是父评论本身，也需要更新根评论的回复数
            $rootId = $data['root_id'] ?? 0;
            if ($rootId > 0 && $rootId != $parentId) {
                FeedComment::query()->where('id', $rootId)->increment('reply_count');
            }
        }

        // 重新加载评论，包含关联数据
        $comment = FeedComment::with(['profile:user_id,nickname,avatar,signed'])
            ->find($comment->id);

        // 格式化返回数据，与列表接口格式一致
        $result = [
            'id' => $comment->id,
            'target_type' => $comment->target_type,
            'target_id' => $comment->target_id,
            'user_id' => $comment->user_id,
            'parent_id' => $comment->parent_id,
            'root_id' => $comment->root_id,
            'reply_to_user_id' => $comment->reply_to_user_id,
            'content' => $comment->content ?? '',
            'images' => $comment->images ?? [],
            'like_count' => $comment->like_count ?? 0,
            'reply_count' => $comment->reply_count ?? 0,
            'created_at' => $comment->created_at->toDateTimeString(),
        ];

        $userCache = Tools::getUserCache($comment->user_id, ['user_id', 'nickname', 'avatar', 'signed']);
        $result['username'] = $userCache['nickname'] ?? '';
        $result['avatar'] = $userCache['avatar'] ?? '';

        // 如果是回复，添加被回复用户的信息
        if ($comment->parent_id != $comment->root_id) {
            $replyToUserCache = Tools::getUserCache($comment->reply_to_user_id, ['user_id', 'nickname', 'avatar', 'signed']);
            $result['reply_to_username'] = $replyToUserCache['nickname'] ?? '';
        }

        return $this->success($result);
    }

    #[Delete(
        path: '/api/feed/comment/delete',
        operationId: 'feedCommentDelete',
        summary: '删除评论',
        tags: ['信息流-评论']
    )]
    #[QueryParameter(name: 'id', description: '评论ID', example: '1')]
    #[Middleware(TokenMiddleware::class)]
    #[ResultResponse(instance: new Result())]
    public function delete(): Result
    {
        $userId = $this->currentUser->id();
        $comment = FeedComment::where(['id' => $this->getRequest()->input('id'), 'user_id' => $userId])->first();

        if (!$comment) {
            return $this->success();
        }

        // 更新目标内容的评论数
        $this->updateCommentCount($comment->target_type, $comment->target_id, -1);

        // 更新目标内容作者的总评论数统计
        $targetAuthorId = $this->getTargetAuthorId($comment->target_type, $comment->target_id);
        if ($targetAuthorId) {
            $this->followService->decrementUserCommentCount($targetAuthorId);
        }

        // 更新父评论的回复数
        if ($comment->parent_id > 0) {
            FeedComment::query()->where('id', $comment->parent_id)->decrement('reply_count');

            // 如果有根评论且根评论不是父评论本身，也需要更新根评论的回复数
            if ($comment->root_id > 0 && $comment->root_id != $comment->parent_id) {
                FeedComment::query()->where('id', $comment->root_id)->decrement('reply_count');
            }
        }

        $comment->delete();

        return $this->success();
    }

    private function updateCommentCount(int $targetType, int $targetId, int $increment): void
    {
        if ($targetType === 1 || $targetType === 2) {
            // 帖子/文章（FeedPost）
            FeedPost::query()->where('id', $targetId)->increment('comment_count', $increment);
        } elseif ($targetType === 3 || $targetType === 4) {
            // 公告/新闻（Article）
            Article::query()->where('id', $targetId)->increment('comment_count', $increment);
        }
    }

    /**
     * 获取目标内容的作者ID
     */
    private function getTargetAuthorId(int $targetType, int $targetId): ?int
    {
        if ($targetType === 1 || $targetType === 2) {
            // 帖子/文章（FeedPost）
            $post = $this->feedService->getPost($targetId);
            return $post['user_id'] ?? null;
        } elseif ($targetType === 3 || $targetType === 4) {
            // 公告/新闻（Article）
            $article = $this->feedService->getArticle($targetId);
            return $article['profile']['user_id'] ?? null;
        }

        return null;
    }
}
