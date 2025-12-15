<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Http\Api\Controller;

use App\Common\AbstractController;
use App\Common\Result;
use App\Http\CurrentUser;
use App\Service\Feed\FeedCacheService;
use Hyperf\HttpServer\Annotation\Controller;
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\Post;
use Hyperf\Swagger\Annotation\Delete;
use Hyperf\Swagger\Annotation\HyperfServer;
use Hyperf\Swagger\Annotation\PathParameter;
use Hyperf\Swagger\Annotation\QueryParameter;
use Hyperf\Swagger\Annotation\JsonContent;
use Hyperf\Swagger\Annotation\RequestBody;
use Plugin\Ds\SysCms\Model\FeedPost;

/**
 * 信息流帖子API控制器
 */
#[HyperfServer(name: 'http')]
#[Controller(prefix: '/api/feed/post')]
class FeedPostController extends AbstractController
{
    public function __construct(
        private readonly FeedCacheService $cacheService,
        private readonly CurrentUser $currentUser
    ) {
        // 设置为API场景
        $this->currentUser->setScene('api');
    }

    #[Get(
        path: '/post-detail/{id}',
        operationId: 'getFeedPostDetail',
        summary: '获取帖子详情',
        tags: ['信息流-帖子']
    )]
    #[PathParameter(name: 'id', description: '帖子ID', example: '1')]
    public function detail(int $id): Result
    {
        // 获取帖子详情（自动使用缓存）
        $post = $this->cacheService->getPost($id);

        if (!$post) {
            return $this->error('帖子不存在', 404);
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
        path: '/user/{userId}',
        operationId: 'getUserFeedPosts',
        summary: '获取用户发布的帖子列表',
        tags: ['信息流-帖子']
    )]
    #[PathParameter(name: 'userId', description: '用户ID', example: '1')]
    #[QueryParameter(name: 'page', description: '页码', example: '1')]
    #[QueryParameter(name: 'page_size', description: '每页数量', example: '20')]
    public function userPosts(int $userId): Result
    {
        $page = $this->getPage();
        $pageSize = $this->getPageSize();
        $offset = ($page - 1) * $pageSize;

        $posts = FeedPost::query()
            ->where('user_id', $userId)
            ->where('status', 1)
            ->where('audit_status', 1)
            ->orderBy('created_at', 'desc')
            ->offset($offset)
            ->limit($pageSize)
            ->get();

        $list = $posts->map(function ($post) {
            return [
                'id' => $post->id,
                'title' => $post->title,
                'content' => $post->content,
                'images' => json_decode($post->images ?? '[]', true),
                'like_count' => $post->like_count,
                'comment_count' => $post->comment_count,
                'created_at' => $post->created_at?->toDateTimeString(),
            ];
        })->toArray();

        return $this->success($list);
    }

    #[Post(
        path: '/post-create',
        operationId: 'createFeedPost',
        summary: '创建帖子',
        tags: ['信息流-帖子']
    )]
    #[RequestBody(content: new JsonContent(
        required: ['content'],
        properties: [
            'content_type' => ['type' => 'integer', 'description' => '内容类型：1纯文本 2图文 3视频 4链接', 'example' => 2],
            'title' => ['type' => 'string', 'description' => '标题', 'example' => '这是一个标题'],
            'content' => ['type' => 'string', 'description' => '内容', 'example' => '这是帖子内容...'],
            'images' => ['type' => 'array', 'items' => ['type' => 'string'], 'description' => '图片URL列表'],
            'videos' => ['type' => 'array', 'items' => ['type' => 'string'], 'description' => '视频URL列表'],
        ]
    ))]
    public function create(): Result
    {
        $userId = $this->currentUser->id();
        if (!$userId) {
            return $this->error('请先登录', 401);
        }

        $data = $this->getRequestData();

        // 创建帖子
        $post = FeedPost::create([
            'user_id' => $userId,
            'content_type' => $data['content_type'] ?? 1,
            'title' => $data['title'] ?? null,
            'content' => $data['content'],
            'images' => json_encode($data['images'] ?? []),
            'videos' => json_encode($data['videos'] ?? []),
            'audit_status' => 0, // 待审核
            'status' => 1,
            'ip' => $this->getRequest()->getClientIps(),
        ]);

        // 清除信息流列表缓存
        $this->cacheService->clearFeedList();

        return $this->success([
            'id' => $post->id,
            'message' => '发布成功，待审核'
        ]);
    }

    #[Delete(
        path: '/post-detail/{id}',
        operationId: 'deleteFeedPost',
        summary: '删除帖子',
        tags: ['信息流-帖子']
    )]
    #[PathParameter(name: 'id', description: '帖子ID', example: '1')]
    public function delete(int $id): Result
    {
        $userId = $this->currentUser->id();
        if (!$userId) {
            return $this->error('请先登录', 401);
        }

        $post = FeedPost::find($id);
        if (!$post) {
            return $this->error('帖子不存在', 404);
        }

        // 只能删除自己的帖子
        if ($post->user_id !== $userId) {
            return $this->error('无权删除', 403);
        }

        $post->delete();

        // 清除相关缓存
        $this->cacheService->clearPost($id);
        $this->cacheService->clearStats(1, $id);
        $this->cacheService->clearCommentList(1, $id);
        $this->cacheService->clearFeedList();

        return $this->success(['message' => '删除成功']);
    }
}
