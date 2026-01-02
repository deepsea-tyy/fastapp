<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Http\Api\Controller;

use App\Common\AbstractController;
use App\Common\Middleware\TokenMiddleware;
use App\Common\Result;
use App\Common\Swagger\ResultResponse;
use App\Http\CurrentUser;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\Swagger\Annotation\{Get, Post, HyperfServer, QueryParameter};
use Plugin\Ds\Ex\Http\Api\Service\TaskService as Service;

/**
 * 任务API控制器
 */
#[HyperfServer(name: 'http')]
class TaskController extends AbstractController
{
    public function __construct(
        protected readonly Service $service,
        protected readonly CurrentUser $currentUser
    ) {}

    #[Get(path: '/api/ex/tasks', operationId: 'ExTaskList', summary: '获取任务列表', tags: ['交易所任务'])]
    #[QueryParameter(name: 'category', description: '任务分类', required: false)]
    #[QueryParameter(name: 'activity_id', description: '活动ID', required: false)]
    #[ResultResponse(instance: new Result())]
    public function list(): Result
    {
        $params = $this->getRequestData();
        $category = $params['category'] ?? null;
        $activityId = isset($params['activity_id']) ? (int)$params['activity_id'] : null;
        $uid = $this->currentUser->id() ?: null;

        $data = $this->service->getTaskList($category, $activityId, $this->getLang(), $uid);
        return $this->success($data);
    }

    #[Get(path: '/api/ex/tasks/detail', operationId: 'ExTaskDetail', summary: '获取任务详情', tags: ['交易所任务'])]
    #[QueryParameter(name: 'id', description: '任务ID', required: true)]
    #[ResultResponse(instance: new Result())]
    public function detail(): Result
    {
        $params = $this->getRequestData();
        $id = (int)($params['id'] ?? 0);
        $uid = $this->currentUser->id() ?: null;
        $data = $this->service->getTaskDetail($id, $this->getLang(), $uid);

        return $data ? $this->success($data) : $this->error('任务不存在');
    }

    #[Post(path: '/api/ex/tasks/claim', operationId: 'ExTaskClaim', summary: '领取任务奖励', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['交易所任务'])]
    #[QueryParameter(name: 'id', description: '任务ID', required: true)]
    #[ResultResponse(instance: new Result())]
    #[Middleware(middleware: TokenMiddleware::class)]
    public function claim(): Result
    {
        $params = $this->getRequestData();
        $id = (int)($params['id'] ?? 0);
        $uid = $this->currentUser->id();

        $result = $this->service->claimTaskReward($uid, $id);

        return $result['success'] ? $this->success($result['data']) : $this->error($result['message']);
    }
}
