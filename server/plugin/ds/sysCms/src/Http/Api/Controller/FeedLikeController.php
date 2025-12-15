<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Http\Api\Controller;

use App\Common\AbstractController;
use App\Common\Result;
use App\Http\CurrentUser;
use App\Service\Feed\FeedCacheService;
use Hyperf\HttpServer\Annotation\Controller;
use Hyperf\Swagger\Annotation\Post;
use Hyperf\Swagger\Annotation\HyperfServer;
use Hyperf\Swagger\Annotation\JsonContent;
use Hyperf\Swagger\Annotation\RequestBody;
use Plugin\Ds\SysCms\Model\FeedLike;
use Plugin\Ds\SysCms\Model\FeedPost;
use Plugin\Ds\SysCms\Model\FeedComment;

/**
 * 信息流点赞API控制器
 */
#[HyperfServer(name: 'http')]
#[Controller(prefix: '/api/feed/like')]
class FeedLikeController extends AbstractController
{
    public function __construct(
        private readonly FeedCacheService $cacheService,
        private readonly CurrentUser $currentUser
    ) {
        // 设置为API场景
        $this->currentUser->setScene('api');
    }

    #[Post(
        path: '/like-toggle',
        operationId: 'toggleFeedLike',
        summary: '切换点赞状态',
        tags: ['信息流-点赞']
    )]
    #[RequestBody(content: new JsonContent(
        required: ['target_type', 'target_id'],
        properties: [
            'target_type' => ['type' => 'integer', 'description' => '目标类型：1帖子 2文章 3评论', 'example' => 1],
            'target_id' => ['type' => 'integer', 'description' => '目标ID', 'example' => 1],
        ]
    ))]
    public function toggle(): Result
    {
        $userId = $this->currentUser->id();
        if (!$userId) {
            return $this->error('请先登录', 401);
        }

        $data = $this->getRequestData();
        $targetType = (int)$data['target_type'];
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
            $newStatus = false;
        } else {
            // 添加点赞
            FeedLike::create([
                'user_id' => $userId,
                'target_type' => $targetType,
                'target_id' => $targetId,
                'created_at' => date('Y-m-d H:i:s'),
            ]);

            $this->updateLikeCount($targetType, $targetId, 1);
            $newStatus = true;
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
        if ($targetType === 1) {
            // 更新帖子点赞数
            FeedPost::query()->where('id', $targetId)->increment('like_count', $increment);
        } elseif ($targetType === 3) {
            // 更新评论点赞数
            FeedComment::query()->where('id', $targetId)->increment('like_count', $increment);
        }
        // 文章点赞数暂不支持
    }
}
