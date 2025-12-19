<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Http\Api\Controller;

use App\Common\AbstractController;
use App\Common\Middleware\TokenMiddleware;
use App\Common\Result;
use App\Common\Swagger\ResultResponse;
use App\Http\CurrentUser;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\Swagger\Annotation\Delete;
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\HyperfServer;
use Hyperf\Swagger\Annotation\JsonContent;
use Hyperf\Swagger\Annotation\Post;
use Hyperf\Swagger\Annotation\QueryParameter;
use Hyperf\Swagger\Annotation\RequestBody;
use Plugin\Ds\SysCms\Http\Api\Service\FeedCacheService;
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
        private readonly FeedCacheService      $cacheService,
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
    #[ResultResponse(instance: new Result())]
    public function list(): Result
    {
        $params = $this->getRequestData();
        $targetType = (int)$params['target_type'];
        $targetId = (int)$params['target_id'];
        $page = (int)($params['page'] ?? 1);
        $pageSize = (int)($params['page_size'] ?? 20);

        // 获取评论列表（自动使用缓存）
        $comments = $this->cacheService->getCommentList($targetType, $targetId, $page, $pageSize);

        // TODO: 批量获取用户信息

        return $this->success(['list' => $comments]);
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
            return [
                'id' => $reply->id,
                'user_id' => $reply->user_id,
                'reply_to_user_id' => $reply->reply_to_user_id,
                'content' => $reply->content,
                'images' => $reply->images ?? [],
                'like_count' => $reply->like_count,
                'created_at' => $reply->created_at?->toDateTimeString(),
            ];
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
            'content' => ['type' => 'string', 'description' => '评论内容', 'example' => '这是一条评论'],
            'images' => ['type' => 'array', 'items' => ['type' => 'string'], 'description' => '图片URL列表'],
        ]
    ))]
    #[Middleware(TokenMiddleware::class)]
    #[ResultResponse(instance: new Result())]
    public function create(): Result
    {
        $userId = $this->currentUser->id();

        $data = $this->getRequestData();
        $targetType = (int)$data['target_type'];
        $targetId = (int)$data['target_id'];
        $parentId = (int)($data['parent_id'] ?? 0);

        // 确定root_id
        $rootId = 0;
        if ($parentId > 0) {
            $parentComment = FeedComment::find($parentId);
            if ($parentComment) {
                $rootId = $parentComment->root_id ?: $parentId;
            }
        }

        // 创建评论
        $comment = FeedComment::create([
            'target_type' => $targetType,
            'target_id' => $targetId,
            'user_id' => $userId,
            'parent_id' => $parentId,
            'root_id' => $rootId,
            'reply_to_user_id' => $data['reply_to_user_id'] ?? null,
            'content' => $data['content'],
            'images' => json_encode($data['images'] ?? []),
            'status' => 1,
        ]);

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
        }

        // 清除评论列表缓存
        $this->cacheService->clearCommentList($targetType, $targetId);

        // 清除目标内容的统计数据缓存
        $this->cacheService->clearStats($targetType, $targetId);

        return $this->success([
            'id' => $comment->id,
            'message' => '评论成功'
        ]);
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
        }

        $comment->delete();

        // 清除评论列表缓存
        $this->cacheService->clearCommentList($comment->target_type, $comment->target_id);

        // 清除目标内容的统计数据缓存
        $this->cacheService->clearStats($comment->target_type, $comment->target_id);

        return $this->success(['message' => '删除成功']);
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
            $post = $this->cacheService->getPost($targetId);
            return $post['user_id'] ?? null;
        } elseif ($targetType === 3 || $targetType === 4) {
            // 公告/新闻（Article）
            $article = $this->cacheService->getArticle($targetId);
            return $article['profile']['user_id'] ?? null;
        }

        return null;
    }
}
