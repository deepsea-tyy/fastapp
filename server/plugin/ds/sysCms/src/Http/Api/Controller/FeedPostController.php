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
use Plugin\Ds\SysCms\Http\Api\Request\FeedPostRequest;
use Plugin\Ds\SysCms\Http\Api\Service\FeedCacheService;
use Plugin\Ds\SysCms\Http\Api\Service\FeedUserFollowService;
use Plugin\Ds\SysCms\Model\FeedPost;
use Swoole\Coroutine;

/**
 * 信息流用户帖子API控制器
 */
#[HyperfServer(name: 'http')]
class FeedPostController extends AbstractController
{
    public function __construct(
        private readonly FeedCacheService      $cacheService,
        private readonly FeedUserFollowService $followService,
        private readonly CurrentUser           $currentUser
    )
    {
        // 设置为API场景
        $this->currentUser->setScene('api');
    }

    #[Get(
        path: '/api/feed/post/detail',
        operationId: 'feedPostDetail',
        summary: '获取帖子详情',
        tags: ['信息流-帖子']
    )]
    #[QueryParameter(name: 'id', description: '帖子ID', example: '1')]
    #[ResultResponse(instance: new Result())]
    public function detail(int $id): Result
    {
        // 获取帖子详情（自动使用缓存）
        $post = $this->cacheService->getPost($id);

        if (!$post) {
            return $this->error('帖子不存在');
        }

        // 获取统计数据（自动使用缓存）
        $stats = $this->cacheService->getStats(1, $id);

        // 异步增加浏览数
        $this->cacheService->incrementViewCount(1, $id);

        // 如果用户已登录，获取用户动作状态
        $userId = $this->currentUser->id();
        if ($userId) {
            $post['is_liked'] = $this->cacheService->getUserLikeStatus($userId, 1, $id);
            $post['is_collected'] = $this->cacheService->getUserCollectStatus($userId, 1, $id);
        }

        return $this->success(array_merge($post, $stats));
    }

    #[Get(
        path: '/api/feed/post/list',
        operationId: 'feedPostList',
        summary: '获取用户发布的帖子列表',
        tags: ['信息流-帖子']
    )]
    #[QueryParameter(name: 'user_id', description: '用户ID', example: '1')]
    #[QueryParameter(name: 'page', description: '页码', example: '1')]
    #[QueryParameter(name: 'page_size', description: '每页数量', example: '20')]
    #[QueryParameter(name: 'type', description: '1帖子 2文章', example: '1')]
    #[QueryParameter(name: 'status', description: '状态：0草稿 1已发布 2已下架', example: '1')]
    #[ResultResponse(instance: new Result())]
    public function list(): Result
    {
        $page = $this->getPage();
        $pageSize = $this->getPageSize();
        $offset = ($page - 1) * $pageSize;
        $map['user_id'] = (int)$this->getRequest()->input('user_id');
        if ($this->getRequest()->input('type')) {
            $map['type'] = (int)$this->getRequest()->input('type');
        }
        if ($this->getRequest()->has('status')) {
            $map['status'] = (int)$this->getRequest()->input('status');
        }

        $list = FeedPost::query()
            ->where($map)
            ->orderBy('created_at', 'desc')
            ->offset($offset)
            ->limit($pageSize)
            ->get()
            ->map(function ($post) {
                return [
                    'id' => $post->id,
                    'profile' => Tools::getUserCache($post->user_id, ['user_id', 'nickname', 'avatar', 'signed']),
                    'user_id' => $post->user_id,
                    'type' => $post->type,
                    'title' => $post->title ?? '',
                    'content' => $post->content ?? '',
                    'images' => $post->images ?? [],
                    'status' => $post->status,
                    'like_count' => $post->like_count ?? 0,
                    'comment_count' => $post->comment_count ?? 0,
                    'created_at' => $post->created_at->toDateTimeString(),
                ];
            });

        return $this->success(['list' => $list]);
    }

    #[Post(
        path: '/api/feed/post/create',
        operationId: 'feedPostCreate',
        summary: '创建帖子',
        tags: ['信息流-帖子']
    )]
    #[RequestBody(content: new JsonContent(
        required: ['content'],
        properties: [
            'type' => ['type' => 'integer', 'description' => '帖子类型：1帖子 2文章', 'example' => 1],
            'content_type' => ['type' => 'integer', 'description' => '内容类型：1纯文本 2图文 3视频 4链接', 'example' => 2],
            'title' => ['type' => 'string', 'description' => '标题', 'example' => '这是一个标题'],
            'content' => ['type' => 'string', 'description' => '内容', 'example' => '这是帖子内容...'],
            'images' => ['type' => 'array', 'items' => ['type' => 'string'], 'description' => '图片URL列表'],
            'videos' => ['type' => 'array', 'items' => ['type' => 'string'], 'description' => '视频URL列表'],
        ]
    ))]
    #[Middleware(TokenMiddleware::class)]
    #[ResultResponse(instance: new Result())]
    public function create(FeedPostRequest $request): Result
    {
        $userId = $this->currentUser->id();

        $data = $request->validated();
        $data['user_id'] = $userId;
        $data['ip'] = $this->getRequest()->getClientIps()[0] ?? '';
        $data['type'] = $data['type'] ?? 1; // 默认为帖子类型
        $data['status'] = $data['status'] ?? 1; // 默认已发布

        // 创建帖子
        $post = new FeedPost;
        $post->fill($data)->save();

        // 增加用户帖子数统计
        $this->followService->incrementUserPostCount($userId);

        // 清除信息流列表缓存
        $this->cacheService->clearFeedList();

        return $this->success([
            'id' => $post->id,
            'profile' => Tools::getUserCache($userId, ['user_id', 'nickname', 'avatar', 'signed']),
            'user_id' => $post->user_id,
            'type' => $post->type,
            'title' => $post->title ?? '',
            'content' => $post->content ?? '',
            'images' => $post->images ?? [],
            'status' => $post->status,
            'like_count' => $post->like_count ?? 0,
            'comment_count' => $post->comment_count ?? 0,
            'created_at' => $post->created_at->toDateTimeString(),
        ]);
    }

    #[Post(
        path: '/api/feed/post/update',
        operationId: 'feedPostUpdate',
        summary: '更新帖子',
        tags: ['信息流-帖子']
    )]
    #[RequestBody(content: new JsonContent(
        required: ['id'],
        properties: [
            'id' => ['type' => 'integer', 'description' => '帖子ID', 'example' => 1],
            'status' => ['type' => 'integer', 'description' => '状态：0草稿 1已发布 2已下架', 'example' => 1],
            'is_top' => ['type' => 'integer', 'description' => '是否置顶：0否 1是', 'example' => 0],
        ]
    ))]
    #[Middleware(TokenMiddleware::class)]
    #[ResultResponse(instance: new Result())]
    public function update(FeedPostRequest $request): Result
    {
        $userId = $this->currentUser->id();
        $data = $request->validated();

        $post = FeedPost::query()->where(['id' => $data['id'], 'user_id' => $userId])->first();
        if (!$post) {
            return $this->error('帖子不存在或无权限');
        }

        $post->fill($data)->save();

        // 清除信息流列表缓存和帖子缓存
        $this->cacheService->clearFeedList();
        $this->cacheService->clearPost($post->id);

        return $this->success([
            'id' => $post->id,
            'profile' => Tools::getUserCache($userId, ['user_id', 'nickname', 'avatar', 'signed']),
            'user_id' => $post->user_id,
            'type' => $post->type,
            'title' => $post->title ?? '',
            'content' => $post->content ?? '',
            'images' => $post->images ?? [],
            'status' => $post->status,
            'is_top' => $post->is_top,
            'like_count' => $post->like_count ?? 0,
            'comment_count' => $post->comment_count ?? 0,
            'created_at' => $post->created_at->toDateTimeString(),
        ]);
    }

    #[Delete(
        path: '/api/feed/post/delete',
        operationId: 'feedPostDelete',
        summary: '删除帖子',
        tags: ['信息流-帖子']
    )]
    #[QueryParameter(name: 'id', description: '帖子ID', example: '1')]
    #[Middleware(TokenMiddleware::class)]
    #[ResultResponse(instance: new Result())]
    public function delete(FeedPostRequest $request): Result
    {
        $userId = $this->currentUser->id();
        $data = $request->validated();
        $id = $data['id'];

        $post = FeedPost::where(['id' => $id, 'user_id' => $userId])->first();
        if (!$post) {
            return $this->error('帖子不存在或无权限');
        }

        $post->delete();

        // 减少用户帖子数统计
        $this->followService->decrementUserPostCount($userId);

        // 清除相关缓存
        $this->cacheService->clearPost($id);
        $this->cacheService->clearStats(1, $id);
        $this->cacheService->clearCommentList(1, $id);
        $this->cacheService->clearFeedList();

        return $this->success(['message' => '删除成功']);
    }

    #[Post(
        path: '/api/feed/post/view',
        operationId: 'feedPostView',
        summary: '增加帖子浏览数',
        tags: ['信息流-帖子']
    )]
    #[RequestBody(content: new JsonContent(
        required: ['id'],
        properties: [
            'id' => ['type' => 'integer', 'description' => '帖子ID', 'example' => 1],
            'target_type' => ['type' => 'integer', 'description' => '目标类型：1帖子 2文章', 'example' => 1],
        ]
    ))]
    #[ResultResponse(instance: new Result())]
    public function view(): Result
    {
        $id = (int)$this->getRequest()->input('id');
        $targetType = (int)$this->getRequest()->input('target_type', 1);
        Coroutine::create(function () use ($id, $targetType) {
            // 异步增加浏览数
            $this->cacheService->incrementViewCount($targetType, $id);
        });
        return $this->success();
    }
}
