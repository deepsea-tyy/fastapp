<?php

declare(strict_types=1);

namespace Plugin\Ds\MessageNotify\Http\Api;

use App\Common\AbstractController;
use App\Common\Middleware\TokenMiddleware;
use App\Common\Request\Request;
use App\Common\Result;
use App\Common\Swagger\ResultResponse;
use App\Http\CurrentUser;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\HyperfServer;
use Hyperf\Swagger\Annotation\Post;
use Hyperf\Swagger\Annotation\QueryParameter;
use Plugin\Ds\MessageNotify\Http\Api\Service\MessageNotifyService;

/**
 * 消息通知控制器
 *
 * @author deepsea
 * @date 2025-11-06
 */
#[HyperfServer(name: 'http')]
#[Middleware(middleware: TokenMiddleware::class)]
class MessageNotifyController extends AbstractController
{
    private const DEFAULT_PAGE = 1;
    private const DEFAULT_PAGE_SIZE = 10;
    private const MIN_PAGE = 1;
    private const MIN_PAGE_SIZE = 1;
    private const MAX_PAGE_SIZE = 100;

    public function __construct(
        private readonly MessageNotifyService $service,
        private readonly CurrentUser $currentUser
    ) {}

    /**
     * 消息列表接口
     */
    #[Get(
        path: '/api/message-notify/list',
        operationId: 'ApiMessageNotifyList',
        summary: '消息列表',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['消息通知'],
    )]
    #[QueryParameter(name: 'notify_type', description: '通知分类:1-系统通知,2-业务通知,3-其他', required: false)]
    #[QueryParameter(name: 'page', description: '页码', required: false)]
    #[QueryParameter(name: 'page_size', description: '每页数量', required: false)]
    #[ResultResponse(instance: new Result())]
    public function list(Request $request): Result
    {
        $userId = $this->currentUser->id();
        $params = $request->query();

        $page = $this->validatePage($params['page'] ?? self::DEFAULT_PAGE);
        $pageSize = $this->validatePageSize($params['page_size'] ?? self::DEFAULT_PAGE_SIZE);

        // 验证 notify_type 参数
        if (isset($params['notify_type'])) {
            $notifyType = (int) $params['notify_type'];
            $validNotifyTypes = [1, 2, 3]; // 1-系统通知,2-业务通知,3-其他
            if (!in_array($notifyType, $validNotifyTypes, true)) {
                return $this->error('通知分类参数错误');
            }
            $params['notify_type'] = $notifyType;
        }

        $data = $this->service->getMessageList($userId, $params, $page, $pageSize);
        return $this->success($data);
    }

    /**
     * 更新已读状态接口
     */
    #[Post(
        path: '/api/message-notify/read',
        operationId: 'ApiMessageNotifyRead',
        summary: '更新已读状态',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['消息通知'],
    )]
    #[ResultResponse(instance: new Result())]
    public function read(Request $request): Result
    {
        $userId = $this->currentUser->id();
        $notifyType = $request->post('notify_type');
        $notifyId = $request->post('notify_id');

        // 参数验证
        if (empty($notifyType) || empty($notifyId)) {
            return $this->error('参数不能为空');
        }

        $notifyType = (int) $notifyType;
        $notifyId = (int) $notifyId;

        if (!in_array($notifyType, [1, 2, 3], true)) {
            return $this->error('通知分类参数错误');
        }

        if ($notifyId < 1) {
            return $this->error('消息ID参数错误');
        }

        $this->service->updateReadStatus($userId, $notifyType, $notifyId);
        return $this->success([], '更新成功');
    }

    /**
     * 分类未读统计接口
     */
    #[Get(
        path: '/api/message-notify/unread-statistics',
        operationId: 'ApiMessageNotifyUnreadStatistics',
        summary: '分类未读统计',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['消息通知'],
    )]
    #[ResultResponse(instance: new Result())]
    public function unreadStatistics(): Result
    {
        $userId = $this->currentUser->id();
        $data = $this->service->getUnreadStatistics($userId);
        return $this->success($data);
    }

    /**
     * 验证页码参数
     *
     * @param mixed $page
     * @return int
     */
    private function validatePage($page): int
    {
        $page = (int) $page;
        return max(self::MIN_PAGE, $page);
    }

    /**
     * 验证每页数量参数
     *
     * @param mixed $pageSize
     * @return int
     */
    private function validatePageSize($pageSize): int
    {
        $pageSize = (int) $pageSize;
        return max(self::MIN_PAGE_SIZE, min(self::MAX_PAGE_SIZE, $pageSize));
    }
}