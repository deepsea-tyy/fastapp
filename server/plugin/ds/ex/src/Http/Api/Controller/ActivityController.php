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
use Plugin\Ds\Ex\Http\Api\Service\ActivityService as Service;

/**
 * 活动API控制器
 */
#[HyperfServer(name: 'http')]
class ActivityController extends AbstractController
{
    public function __construct(
        protected readonly Service $service,
        protected readonly CurrentUser $currentUser
    ) {}

    #[Get(path: '/api/ex/activities', operationId: 'ExActivityList', summary: '获取活动列表', tags: ['交易所活动'])]
    #[QueryParameter(name: 'type', description: '活动类型', required: false)]
    #[QueryParameter(name: 'status', description: '状态', required: false)]
    #[QueryParameter(name: 'is_hot', description: '是否热门', required: false)]
    #[QueryParameter(name: 'is_recommend', description: '是否推荐', required: false)]
    #[QueryParameter(name: 'page', description: '页码', required: false, example: '1')]
    #[QueryParameter(name: 'limit', description: '每页数量', required: false, example: '20')]
    #[ResultResponse(instance: new Result())]
    public function list(): Result
    {
        $params = $this->getRequestData();
        $data = $this->service->getActivityList($params, $this->getLang());
        return $this->success($data);
    }

    #[Get(path: '/api/ex/activities/my', operationId: 'ExMyActivities', summary: '我参与的活动', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['交易所活动'])]
    #[QueryParameter(name: 'page', description: '页码', required: false, example: '1')]
    #[QueryParameter(name: 'page_size', description: '每页数量', required: false, example: '20')]
    #[ResultResponse(instance: new Result())]
    #[Middleware(middleware: TokenMiddleware::class)]
    public function myActivities(): Result
    {
        $params = $this->getRequestData();
        $page = (int)($params['page'] ?? 1);
        $pageSize = (int)($params['page_size'] ?? 20);

        $result = $this->service->getUserActivities($this->currentUser->id(), $page, $pageSize);
        return $this->success($result);
    }

    #[Get(path: '/api/ex/activities/detail', operationId: 'ExActivityDetail', summary: '获取活动详情', tags: ['交易所活动'])]
    #[QueryParameter(name: 'id', description: '活动ID', required: true)]
    #[ResultResponse(instance: new Result())]
    public function detail(): Result
    {
        $params = $this->getRequestData();
        $id = (int)($params['id'] ?? 0);
        $uid = $this->currentUser->id() ?: null;
        $data = $this->service->getActivityDetail($id, $this->getLang(), $uid);

        return $data ? $this->success($data) : $this->error('活动不存在');
    }

    #[Post(path: '/api/ex/activities/join', operationId: 'ExActivityJoin', summary: '参与活动', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['交易所活动'])]
    #[QueryParameter(name: 'id', description: '活动ID', required: true)]
    #[ResultResponse(instance: new Result())]
    #[Middleware(middleware: TokenMiddleware::class)]
    public function join(): Result
    {
        $params = $this->getRequestData();
        $id = (int)($params['id'] ?? 0);
        $uid = $this->currentUser->id();

        $result = $this->service->joinActivity($uid, $id);

        return $result ? $this->success() : $this->error('参与失败，请检查活动状态或是否已参与');
    }
}
