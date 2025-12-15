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
use Hyperf\Swagger\Annotation\HyperfServer;
use Hyperf\Swagger\Annotation\QueryParameter;
use Hyperf\Swagger\Annotation\JsonContent;
use Hyperf\Swagger\Annotation\RequestBody;
use Plugin\Ds\SysCms\Model\FeedCollect;
use Plugin\Ds\SysCms\Model\FeedPost;

/**
 * 信息流收藏API控制器
 */
#[HyperfServer(name: 'http')]
#[Controller(prefix: '/api/feed/collect')]
class FeedCollectController extends AbstractController
{
    public function __construct(
        private readonly FeedCacheService $cacheService,
        private readonly CurrentUser $currentUser
    ) {
        // 设置为API场景
        $this->currentUser->setScene('api');
    }

    #[Post(
        path: '/collect-toggle',
        operationId: 'toggleFeedCollect',
        summary: '切换收藏状态',
        tags: ['信息流-收藏']
    )]
    #[RequestBody(content: new JsonContent(
        required: ['target_type', 'target_id'],
        properties: [
            'target_type' => ['type' => 'integer', 'description' => '目标类型：1帖子 2文章', 'example' => 1],
            'target_id' => ['type' => 'integer', 'description' => '目标ID', 'example' => 1],
        ]
    ))]
    public function toggle(): Result
    {
        $userId = $this->currentUser->id();
        if (!$userId) {
            return $this->error('请先登录');
        }

        $data = $this->getRequestData();
        $targetType = (int)$data['target_type'];
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

            $this->updateCollectCount($targetType, $targetId, -1);
            $newStatus = false;
        } else {
            // 添加收藏
            FeedCollect::create([
                'user_id' => $userId,
                'target_type' => $targetType,
                'target_id' => $targetId,
                'created_at' => date('Y-m-d H:i:s'),
            ]);

            $this->updateCollectCount($targetType, $targetId, 1);
            $newStatus = true;
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
        path: '/my-collects',
        operationId: 'getFeedCollectList',
        summary: '获取收藏列表',
        tags: ['信息流-收藏']
    )]
    #[QueryParameter(name: 'page', description: '页码', example: '1')]
    #[QueryParameter(name: 'page_size', description: '每页数量', example: '20')]
    public function getList(): Result
    {
        $page = $this->getPage();
        $pageSize = $this->getPageSize();

        $userId = $this->currentUser->id();
        if (!$userId) {
            return $this->error('请先登录');
        }

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
            if ($collect->target_type === 1) {
                $post = $this->cacheService->getPost($collect->target_id);
                if ($post) {
                    $post['collected_at'] = $collect->created_at?->toDateTimeString();
                    $list[] = $post;
                }
            } elseif ($collect->target_type === 2) {
                $article = $this->cacheService->getArticle($collect->target_id);
                if ($article) {
                    $article['collected_at'] = $collect->created_at?->toDateTimeString();
                    $list[] = $article;
                }
            }
        }

        return $this->success($list);
    }

    private function updateCollectCount(int $targetType, int $targetId, int $increment): void
    {
        if ($targetType === 1) {
            FeedPost::query()->where('id', $targetId)->increment('collect_count', $increment);
        }
        // 文章收藏数暂不支持
    }
}
