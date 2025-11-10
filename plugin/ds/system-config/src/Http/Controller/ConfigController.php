<?php

declare(strict_types=1);


namespace Plugin\Ds\SystemConfig\Http\Controller;

use App\Http\Admin\Permission;
use App\Common\Middleware\AccessTokenMiddleware;
use App\Common\Middleware\OperationMiddleware;
use App\Common\Result;
use App\Common\Swagger\ResultResponse;
use App\Http\Admin\Controller\AbstractController;
use App\Http\Admin\Middleware\PermissionMiddleware;
use App\Http\CurrentUser;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\Swagger\Annotation as OA;
use Hyperf\Swagger\Annotation\Delete;
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\Post;
use Hyperf\Swagger\Annotation\Put;
use Plugin\Ds\SystemConfig\Http\Request\ConfigRequest as Request;
use Plugin\Ds\SystemConfig\Service\ConfigService as Service;

#[OA\Tag('System/Config')]
#[OA\HyperfServer('http')]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
#[Middleware(middleware: OperationMiddleware::class, priority: 98)]
class ConfigController extends AbstractController
{
    public function __construct(
        private readonly Service $service,
        private readonly CurrentUser $currentUser
    ) {}

    #[Get(
        path: '/system/Config/list',
        operationId: 'configList',
        summary: 'System/Config列表',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['系统配置列表'],
    )]
    #[Permission(code: 'plugin:ds:config:list')]
    public function pageList(): Result
    {
        return $this->success(
            $this->service->page(
                $this->getRequestData(),
                $this->getCurrentPage(),
                $this->getPageSize()
            )
        );
    }

    #[Get(
        path: '/system/Config/Details/{code}',
        operationId: 'Details',
        summary: 'System/Details详情',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['系统配置详情'],
    )]
    #[Permission(code: 'plugin:ds:config:details')]
    #[ResultResponse(instance: new Result())]
    public function details(string $code): Result
    {
        return $this->success(
            $this->service->getDetails(['group_code' => $code])
        );
    }

    #[Post(
        path: '/system/Config',
        operationId: 'configCreate',
        summary: '新增System/Config',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['系统配置创建'],
    )]
    #[Permission(code: 'plugin:ds:config:create')]
    #[ResultResponse(instance: new Result())]
    public function create(Request $request): Result
    {
        $this->service->create(array_merge($request->all(), [
            'created_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[Put(
        path: '/system/Config/{id}',
        operationId: 'configUpdate',
        summary: '保存System/Config',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['系统配置更新'],
    )]
    #[Permission(code: 'plugin:ds:config:update')]
    #[ResultResponse(instance: new Result())]
    public function save(int $id, Request $request): Result
    {
        $this->service->updateById($id, array_merge($request->validated(), [
            'updated_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[Delete(
        path: '/system/Config',
        operationId: 'configDelete',
        summary: '删除System/Config',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['系统配置删除'],
    )]
    #[ResultResponse(new Result())]
    #[Permission(code: 'plugin:ds:config:delete')]
    public function delete(): Result
    {
        $this->service->deleteByKey($this->getRequestData());
        return $this->success();
    }

    #[Post(
        path: '/system/Config/batchUpdate',
        operationId: 'configBatchUpdate',
        summary: '批量更新',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['系统配置批量更新'],
    )]
    #[ResultResponse(instance: new Result())]
    #[Permission(code: 'plugin:ds:config:batchUpdate')]
    public function batchUpdate(): Result
    {
        $this->service->upsertData($this->getRequestData());
        return $this->success();
    }
}
