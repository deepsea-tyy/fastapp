<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Http\Api\Controller;

use App\Common\AbstractController;
use App\Common\Middleware\TokenMiddleware;
use App\Common\Result;
use App\Common\Swagger\ResultResponse;
use App\Http\CurrentUser;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\Swagger\Annotation\{Get, HyperfServer, QueryParameter};
use Plugin\Ds\Ex\Http\Api\Service\ExVipService as Service;

/**
 * VIP等级API控制器
 * 
 * @author FastApp代码生成器
 * @date 2025-12-13
 */
#[HyperfServer(name: 'http')]
class ExVipController extends AbstractController
{
    public function __construct(
        protected readonly Service $service,
        protected readonly CurrentUser $currentUser
    ) {}

    #[Get(path: '/api/ex/vip/levels', operationId: 'ExVipLevels', summary: '获取VIP等级列表', tags: ['VIP等级'])]
    #[ResultResponse(instance: new Result())]
    public function levels(): Result
    {
        $levels = $this->service->getVipLevels($this->getLang());
        return $this->success($levels);
    }

    #[Get(path: '/api/ex/vip/detail', operationId: 'ExVipDetail', summary: '获取当前用户的VIP详细信息（包含VIP等级配置）', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['VIP等级'])]
    #[ResultResponse(instance: new Result())]
    #[Middleware(middleware: TokenMiddleware::class)]
    public function detail(): Result
    {
        $detail = $this->service->getUserVipDetail($this->currentUser->id());
        return $detail ? $this->success($detail) : $this->error('VIP信息不存在');
    }

    #[Get(path: '/api/ex/vip/logs', operationId: 'ExVipLogs', summary: '获取当前用户的VIP升级记录', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['VIP等级'])]
    #[QueryParameter(name: 'page', description: '页码', required: false, example: '1')]
    #[QueryParameter(name: 'page_size', description: '每页数量', required: false, example: '20')]
    #[ResultResponse(instance: new Result())]
    #[Middleware(middleware: TokenMiddleware::class)]
    public function logs(): Result
    {
        $params = $this->getRequestData();
        $page = (int)($params['page'] ?? 1);
        $pageSize = (int)($params['page_size'] ?? 20);
        
        $result = $this->service->getUserVipLogs($this->currentUser->id(), $page, $pageSize);
        return $this->success($result);
    }
}




