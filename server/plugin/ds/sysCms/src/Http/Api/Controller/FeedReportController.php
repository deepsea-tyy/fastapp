<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Http\Api\Controller;

use App\Common\AbstractController;
use App\Common\Middleware\TokenMiddleware;
use App\Common\Result;
use App\Common\Swagger\ResultResponse;
use App\Http\CurrentUser;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\Swagger\Annotation\HyperfServer;
use Hyperf\Swagger\Annotation\JsonContent;
use Hyperf\Swagger\Annotation\Post;
use Hyperf\Swagger\Annotation\RequestBody;
use Plugin\Ds\SysCms\Service\FeedReportService;

/**
 * 信息流举报API控制器
 */
#[HyperfServer(name: 'http')]
#[Middleware(TokenMiddleware::class)]
class FeedReportController extends AbstractController
{
    #[ResultResponse(instance: new Result())]
    public function __construct(
        private readonly FeedReportService $feedReportService,
        private readonly CurrentUser $currentUser
    ) {}

    #[Post(
        path: '/api/feed/report/submit',
        operationId: 'feedReportSubmit',
        summary: '提交举报',
        tags: ['信息流-举报']
    )]
    #[RequestBody(content: new JsonContent(
        required: ['target_type', 'target_id', 'report_type'],
        properties: [
            'target_type' => ['type' => 'integer', 'description' => '目标类型：1帖子 2文章 3评论', 'example' => 1],
            'target_id' => ['type' => 'integer', 'description' => '目标ID', 'example' => 1],
            'report_type' => ['type' => 'integer', 'description' => '举报类型：1垃圾广告 2色情低俗 3违法违规 4侮辱谩骂 5其他', 'example' => 1],
            'content' => ['type' => 'string', 'description' => '举报说明（可选）', 'example' => '举报说明'],
            'images' => ['type' => 'array', 'items' => ['type' => 'string'], 'description' => '举报图片（可选）'],
        ]
    ))]
    public function submit(): Result
    {
        $userId = $this->currentUser->id();
        $targetType = (int)$this->getRequest()->input('target_type'); // 1帖子 2文章 3评论
        $targetId = (int)$this->getRequest()->input('target_id');
        $reportType = (int)$this->getRequest()->input('report_type'); // 1垃圾广告 2色情低俗 3违法违规 4侮辱谩骂 5其他
        $content = (string)$this->getRequest()->input('content', ''); // 举报说明
        $images = $this->getRequest()->input('images', []); // 举报图片

        // 参数验证
        if (!in_array($targetType, [1, 2, 3])) {
            return $this->error('目标类型参数错误');
        }

        if ($targetId <= 0) {
            return $this->error('目标ID参数错误');
        }

        if (!in_array($reportType, [1, 2, 3, 4, 5])) {
            return $this->error('举报类型参数错误');
        }

        // 举报类型为"其他"时，必须填写说明
        if ($reportType === 5 && empty($content)) {
            return $this->error('请填写举报说明');
        }

        $data = $this->getRequestData();
        $data['user_id'] = $userId;

        if ($this->feedReportService->submitReport($data)) {
            return $this->success();
        }

        return $this->error('举报提交失败');
    }
}
