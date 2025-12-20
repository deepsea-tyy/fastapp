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
use Plugin\Ds\SysCms\Http\Api\Service\FeedService;
use Plugin\Ds\SysCms\Http\Api\Service\FeedUserFollowService;
use Plugin\Ds\SysCms\Model\FeedCollect;
use Plugin\Ds\SysCms\Model\FeedLike;
use Plugin\Ds\SysCms\Model\FeedPost;
use Swoole\Coroutine;

/**
 * 信息流用户帖子API控制器
 */
#[HyperfServer(name: 'http')]
class FeedPostController extends AbstractController
{
    public function __construct(
        private readonly FeedService           $feedService,
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
    public function detail(): Result
    {
        $id = (int)$this->getRequest()->input('id');
        $post = $this->feedService->getPost($id);

        if (!$post) {
            return $this->error();
        }
        $this->feedService->incrementViewCount(1, $id);
        $userId = $this->currentUser->id();
        if ($userId) {
            $map['user_id'] = $userId;
            $map['target_type'] = $post['type'];
            $map['target_id'] = $id;
            $post['is_liked'] = FeedLike::query()->where($map)->exists() ? 1 : 0;
            $post['is_collected'] = FeedCollect::query()->where($map)->exists() ? 1 : 0;
            $post['is_following'] = $this->followService->isFollowing($userId, $post['user_id']);
        }
        return $this->success($post);
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

        return $this->success(['message' => '删除成功']);
    }
}
