<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Http\Api\Controller;

use App\Common\AbstractController;
use App\Common\Middleware\TokenMiddleware;
use App\Common\Result;
use App\Common\Swagger\ResultResponse;
use App\Http\CurrentUser;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\HyperfServer;
use Hyperf\Swagger\Annotation\JsonContent;
use Hyperf\Swagger\Annotation\Post;
use Hyperf\Swagger\Annotation\QueryParameter;
use Hyperf\Swagger\Annotation\RequestBody;
use Plugin\Ds\SysCms\Http\Api\Service\FeedCacheService;
use Plugin\Ds\SysCms\Http\Api\Service\FeedUserFollowService;
use Plugin\Ds\SysCms\Model\Article;
use Plugin\Ds\SysCms\Model\FeedCollect;
use Plugin\Ds\SysCms\Model\FeedComment;
use Plugin\Ds\SysCms\Model\FeedLike;
use Plugin\Ds\SysCms\Model\FeedPost;
use Plugin\Ds\SysCms\Model\FeedQualityFeedback;

/**
 * 信息流用户操作API控制器
 */
#[HyperfServer(name: 'http')]
#[Middleware(TokenMiddleware::class)]
class FeedUserController extends AbstractController
{
    #[ResultResponse(instance: new Result())]
    public function __construct(
        private readonly FeedCacheService      $cacheService,
        private readonly FeedUserFollowService $followService,
        private readonly CurrentUser           $currentUser
    )
    {
    }

    #[Post(
        path: '/api/feed/user/collectToggle',
        operationId: 'feedCollectToggle',
        summary: '切换收藏状态',
        tags: ['信息流-用户操作']
    )]
    #[RequestBody(content: new JsonContent(
        required: ['target_type', 'target_id'],
        properties: [
            'target_type' => ['type' => 'integer', 'description' => '目标类型：1帖子 2文章 3公告 4新闻', 'example' => 1],
            'target_id' => ['type' => 'integer', 'description' => '目标ID', 'example' => 1],
        ]
    ))]
    #[ResultResponse(instance: new Result())]
    public function collectToggle(): Result
    {
        $userId = $this->currentUser->id();

        $data = $this->getRequestData();
        $targetType = (int)$data['target_type'] ?: 1;
        $targetId = (int)$data['target_id'];

        // 检查是否已收藏（使用缓存）
        $isCollected = $this->cacheService->getUserCollectStatus($userId, $targetType, $targetId);

        if ($isCollected) {
            // 取消收藏
            FeedCollect::query()
                ->where('user_id', $userId)
                ->where('target_type', $targetType)
                ->where('target_id', $targetId)
                ->delete();
            $newStatus = 0;
        } else {
            // 添加收藏
            FeedCollect::create([
                'user_id' => $userId,
                'target_type' => $targetType,
                'target_id' => $targetId,
                'created_at' => date('Y-m-d H:i:s'),
            ]);
            $newStatus = 1;
        }

        if ($targetType === 1 || $targetType === 2) {
            // 帖子/文章（FeedPost）
            FeedPost::query()->where('id', $targetId)->increment('collect_count', $newStatus ? 1 : -1);
        } elseif ($targetType === 3 || $targetType === 4) {
            // 公告/新闻（Article）
            Article::query()->where('id', $targetId)->increment('collect_count', $newStatus ? 1 : -1);
        }
        // 清除用户收藏状态缓存
        $this->cacheService->clearUserCollect($userId, $targetType, $targetId);

        // 清除统计数据缓存
        $this->cacheService->clearStats($targetType, $targetId);

        return $this->success([
            'is_collected' => $newStatus,
            'message' => $newStatus ? '收藏成功' : '已取消收藏'
        ]);
    }

    #[Get(
        path: '/api/feed/user/collectList',
        operationId: 'feedCollectList',
        summary: '获取收藏列表',
        tags: ['信息流-用户操作']
    )]
    #[QueryParameter(name: 'page', description: '页码', example: '1')]
    #[QueryParameter(name: 'page_size', description: '每页数量', example: '20')]
    #[ResultResponse(instance: new Result())]
    public function collectList(): Result
    {
        $page = $this->getPage();
        $pageSize = $this->getPageSize();

        $userId = $this->currentUser->id();

        $offset = ($page - 1) * $pageSize;

        $collects = FeedCollect::query()
            ->where('user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->offset($offset)
            ->limit($pageSize)
            ->get();

        // 批量获取内容详情
        $list = [];
        foreach ($collects as $collect) {
            if ($collect->target_type === 1 || $collect->target_type === 2) {
                // 帖子/文章（FeedPost）
                $post = $this->cacheService->getPost($collect->target_id);
                if ($post) {
                    $post['collected_at'] = $collect->created_at?->toDateTimeString();
                    $list[] = $post;
                }
            } elseif ($collect->target_type === 3 || $collect->target_type === 4) {
                // 公告/新闻（Article）
                $article = $this->cacheService->getArticle($collect->target_id);
                if ($article) {
                    $article['collected_at'] = $collect->created_at?->toDateTimeString();
                    $list[] = $article;
                }
            }
        }

        return $this->success(['list' => $list]);
    }


    #[Post(
        path: '/api/feed/user/likeToggle',
        operationId: 'feedLikeToggle',
        summary: '切换点赞状态',
        tags: ['信息流-用户操作']
    )]
    #[RequestBody(content: new JsonContent(
        required: ['target_type', 'target_id'],
        properties: [
            'target_type' => ['type' => 'integer', 'description' => '目标类型：1帖子 2文章 3公告 4新闻 5评论', 'example' => 1],
            'target_id' => ['type' => 'integer', 'description' => '目标ID', 'example' => 1],
        ]
    ))]
    #[ResultResponse(instance: new Result())]
    public function likeToggle(): Result
    {
        $userId = $this->currentUser->id();

        $data = $this->getRequestData();
        $targetType = (int)$data['target_type'] ?: 1;
        $targetId = (int)$data['target_id'];

        // 检查是否已点赞（使用缓存）
        $isLiked = $this->cacheService->getUserLikeStatus($userId, $targetType, $targetId);

        if ($isLiked) {
            // 取消点赞
            FeedLike::query()
                ->where('user_id', $userId)
                ->where('target_type', $targetType)
                ->where('target_id', $targetId)
                ->delete();

            $this->updateLikeCount($targetType, $targetId, -1);
            $newStatus = 0;
        } else {
            // 添加点赞
            FeedLike::create([
                'user_id' => $userId,
                'target_type' => $targetType,
                'target_id' => $targetId,
                'created_at' => date('Y-m-d H:i:s'),
            ]);

            $this->updateLikeCount($targetType, $targetId, 1);
            $newStatus = 1;
        }

        // 清除用户点赞状态缓存
        $this->cacheService->clearUserLike($userId, $targetType, $targetId);

        // 清除统计数据缓存
        $this->cacheService->clearStats($targetType, $targetId);

        // 获取最新的点赞数
        $stats = $this->cacheService->getStats($targetType, $targetId);

        return $this->success([
            'is_liked' => $newStatus,
            'like_count' => $stats['like_count']
        ]);
    }

    private function updateLikeCount(int $targetType, int $targetId, int $increment): void
    {
        if ($targetType === 1 || $targetType === 2) {
            // 帖子/文章（FeedPost）
            $post = FeedPost::query()->where('id', $targetId)->first();
            if ($post) {
                $post->increment('like_count', $increment);

                // 更新帖子作者的总点赞数统计
                if ($increment > 0) {
                    $this->followService->incrementUserLikeCount($post->user_id);
                } else {
                    $this->followService->decrementUserLikeCount($post->user_id);
                }
            }
        } elseif ($targetType === 3 || $targetType === 4) {
            // 公告/新闻（Article）
            $article = Article::query()->where('id', $targetId)->first();
            if ($article) {
                $article->increment('like_count', $increment);

                // 更新作者的总点赞数统计
                if ($increment > 0) {
                    $this->followService->incrementUserLikeCount($article->created_by);
                } else {
                    $this->followService->decrementUserLikeCount($article->created_by);
                }
            }
        } elseif ($targetType === 5) {
            // 评论
            $comment = FeedComment::query()->where('id', $targetId)->first();
            if ($comment) {
                $comment->increment('like_count', $increment);

                // 更新评论作者的总点赞数统计
                if ($increment > 0) {
                    $this->followService->incrementUserLikeCount($comment->user_id);
                } else {
                    $this->followService->decrementUserLikeCount($comment->user_id);
                }
            }
        }
    }

    #[Post(
        path: '/api/feed/user/followToggle',
        operationId: 'feedFollowToggle',
        summary: '切换关注状态',
        tags: ['信息流-用户操作']
    )]
    #[RequestBody(content: new JsonContent(
        required: ['follow_user_id'],
        properties: [
            'follow_user_id' => ['type' => 'integer', 'description' => '被关注用户ID', 'example' => 1],
        ]
    ))]
    #[ResultResponse(instance: new Result())]
    public function followToggle(): Result
    {
        $userId = $this->currentUser->id();

        $data = $this->getRequestData();
        $followUserId = (int)$data['follow_user_id'];

        try {
            $isFollowing = $this->followService->toggleFollow($userId, $followUserId);

            return $this->success([
                'is_following' => $isFollowing ? 1 : 0,
            ]);
        } catch (\InvalidArgumentException $e) {
            return $this->error($e->getMessage(), 400);
        }
    }

    #[Get(
        path: '/api/feed/user/followingList',
        operationId: 'feedFollowingList',
        summary: '获取关注列表',
        tags: ['信息流-用户操作']
    )]
    #[QueryParameter(name: 'page', description: '页码', example: '1')]
    #[QueryParameter(name: 'page_size', description: '每页数量', example: '20')]
    #[ResultResponse(instance: new Result())]
    public function followingList(): Result
    {
        $page = $this->getPage();
        $pageSize = $this->getPageSize();

        $userId = $this->currentUser->id();
        $list = $this->followService->getFollowingList($userId, $page, $pageSize);
        return $this->success(['list' => $list]);
    }

    #[Get(
        path: '/api/feed/user/followersList',
        operationId: 'feedFollowersList',
        summary: '获取粉丝列表',
        tags: ['信息流-用户操作']
    )]
    #[QueryParameter(name: 'page', description: '页码', example: '1')]
    #[QueryParameter(name: 'page_size', description: '每页数量', example: '20')]
    #[ResultResponse(instance: new Result())]
    public function followersList(): Result
    {
        $page = $this->getPage();
        $pageSize = $this->getPageSize();

        $userId = $this->currentUser->id();

        $followerUserIds = $this->followService->getFollowersList($userId, $page, $pageSize);

        // 批量检查是否互相关注
        $mutualFollowing = $this->followService->batchCheckFollowing($userId, $followerUserIds);

        // TODO: 批量获取用户信息
        $list = [];
        foreach ($followerUserIds as $followerUserId) {
            $list[] = [
                'user_id' => $followerUserId,
                'is_mutual' => $mutualFollowing[$followerUserId] ?? false, // 是否互相关注
                // TODO: 添加用户详细信息
            ];
        }

        return $this->success($list);
    }

    #[Get(
        path: '/api/feed/user/stats',
        operationId: 'feedUserFollowStats',
        summary: '获取用户统计信息',
        tags: ['信息流-用户操作']
    )]
    #[QueryParameter(name: 'user_id', description: '用户ID（可选，不传则获取当前用户）', example: '1')]
    #[ResultResponse(instance: new Result())]
    public function stats(): Result
    {
        $queryUserId = $this->getRequest()->input('user_id');
        $userId = $queryUserId ? (int)$queryUserId : $this->currentUser->id();

        // 使用新的统计表获取数据，性能更好
        $stats = $this->followService->getUserStats($userId);

        return $this->success($stats);
    }

    #[Get(
        path: '/api/feed/user/followStatus',
        operationId: 'feedUserFollowStatus',
        summary: '检查是否关注某用户',
        tags: ['信息流-用户操作']
    )]
    #[QueryParameter(name: 'follow_user_id', description: '被关注用户ID', example: '1')]
    #[ResultResponse(instance: new Result())]
    public function followStatus(): Result
    {
        $userId = $this->currentUser->id();

        $res = $this->followService->isFollowing($userId, (int)$this->getRequest()->input('follow_user_id'));
        return $this->success($res);
    }

    #[Get(
        path: '/api/feed/user/collectStatus',
        operationId: 'feedUserCollectStatus',
        summary: '获取收藏状态',
        tags: ['信息流-用户操作']
    )]
    #[QueryParameter(name: 'target_type', description: '目标类型：1帖子 2文章 3公告 4新闻', example: '1')]
    #[QueryParameter(name: 'target_id', description: '目标ID', example: '1')]
    #[ResultResponse(instance: new Result())]
    public function collectStatus(): Result
    {
        $userId = $this->currentUser->id();
        $targetType = (int)$this->getRequest()->input('target_type', 1);
        $targetId = (int)$this->getRequest()->input('target_id');

        // 使用缓存查询收藏状态
        $isCollected = $this->cacheService->getUserCollectStatus($userId, $targetType, $targetId);

        return $this->success([
            'is_collected' => $isCollected ? 1 : 0
        ]);
    }

    #[Post(
        path: '/api/feed/user/qualityFeedback',
        operationId: 'feedQualityFeedback',
        summary: '提交内容质量反馈',
        tags: ['信息流-用户操作']
    )]
    #[RequestBody(content: new JsonContent(
        required: ['target_type', 'target_id', 'quality_type'],
        properties: [
            'target_type' => ['type' => 'integer', 'description' => '目标类型：1帖子 2文章 3公告 4新闻', 'example' => 1],
            'target_id' => ['type' => 'integer', 'description' => '目标ID', 'example' => 1],
            'quality_type' => ['type' => 'integer', 'description' => '质量类型：1对投资没有帮助 2内容质量差', 'example' => 1],
        ]
    ))]
    #[ResultResponse(instance: new Result())]
    public function qualityFeedback(): Result
    {
        $userId = $this->currentUser->id();
        $map = $this->getRequestData();
        $map['user_id'] = $userId;
        $exists = FeedQualityFeedback::query()->where($map)->exists();
        if ($exists) {
            return $this->success();
        }
        (new FeedQualityFeedback)->fill($map)->save();
        return $this->success();
    }
}
