<?php

declare(strict_types=1);


namespace Plugin\Ds\SystemConfig\Http\Controller;

use App\Http\Admin\Permission;
use App\Common\Middleware\AccessTokenMiddleware;
use App\Common\Middleware\OperationMiddleware;
use App\Common\Result;
use App\Common\Swagger\PageResponse;
use App\Http\Admin\Controller\AbstractController;
use App\Http\Admin\Middleware\PermissionMiddleware;
use App\Http\CurrentUser;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\Swagger\Annotation\Delete;
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\HyperfServer;
use Hyperf\Swagger\Annotation\JsonContent;
use Hyperf\Swagger\Annotation\Post;
use Hyperf\Swagger\Annotation\Put;
use Hyperf\Swagger\Annotation\RequestBody;
use Plugin\Ds\SystemConfig\Http\Request\ConfigGroupRequest as Request;
use Plugin\Ds\SystemConfig\Service\ConfigGroupService as Service;

/**
 * 参数配置分组表控制器
 * Class SystemConfigGroupController.
 */
#[HyperfServer(name: 'http')]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
#[Middleware(middleware: OperationMiddleware::class, priority: 98)]
final class ConfigGroupController extends AbstractController
{
    /**
     * 业务处理服务
     * SystemConfigGroupService.
     */
    public function __construct(
        protected readonly Service $service,
        protected readonly CurrentUser $currentUser
    ) {}

    #[Get(
        path: '/system/ConfigGroup/list',
        operationId: 'configGroupList',
        summary: '配置分组列表',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['系统分组列表'],
    )]
    #[Permission(code: 'plugin:ds:configGroup:list')]
    #[PageResponse(instance: new Result())]
    public function page(): Result
    {
        return $this->success(data: $this->service->getList([]));
    }

    #[Post(
        path: '/system/ConfigGroup',
        operationId: 'configGroupCreate',
        summary: '创建配置分组',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['系统分组创建'],
    )]
    #[RequestBody(
        content: new JsonContent(ref: Request::class, title: '创建配置分组')
    )]
    #[PageResponse(instance: new Result())]
    #[Permission(code: 'plugin:ds:configGroup:index:create')]
    public function create(Request $request): Result
    {
        $this->service->create(array_merge($request->post(), [
            'created_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[Put(
        path: '/system/ConfigGroup/{id}',
        operationId: 'configGroupEdit',
        summary: '编辑配置分组',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['系统分组更新']
    )]
    #[RequestBody(
        content: new JsonContent(ref: Request::class, title: '编辑配置分组')
    )]
    #[PageResponse(instance: new Result())]
    #[Permission(code: 'plugin:ds:configGroup:update')]
    public function save(int $id, Request $request): Result
    {
        $this->service->updateById($id, array_merge($request->validated(), [
            'updated_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[Delete(
        path: '/system/ConfigGroup',
        operationId: 'configGroupDelete',
        summary: '删除配置分组',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['系统分组删除']
    )]
    #[PageResponse(instance: new Result())]
    #[Permission(code: 'plugin:ds:configGroup:delete')]
    public function delete(): Result
    {
        $this->service->deleteById($this->getRequestData());
        return $this->success();
    }
}
