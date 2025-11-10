<?php

declare(strict_types=1);


namespace App\Http\Admin\Controller\Logstash;

use App\Common\Middleware\AccessTokenMiddleware;
use App\Common\Result;
use App\Common\Swagger\PageResponse;
use App\Common\Swagger\ResultResponse;
use App\Http\Admin\Controller\AbstractController;
use App\Http\Admin\Middleware\PermissionMiddleware;
use App\Http\Admin\Permission;
use App\Http\Admin\Service\Logstash\UserAdminOperationLogService;
use App\Http\CurrentUser;
use App\Schema\UserAdminOperationLogSchema;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\HttpServer\Contract\RequestInterface;
use Hyperf\Swagger\Annotation\Delete;
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\HyperfServer;

#[HyperfServer(name: 'http')]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
final class UserAdminOperationLogController extends AbstractController
{
    public function __construct(
        protected readonly UserAdminOperationLogService $service,
        protected readonly CurrentUser                  $currentUser
    ) {}

    #[Get(
        path: '/admin/user-operation-log/list',
        operationId: 'UserOperationLogList',
        summary: '用户操作日志列表',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['系统管理'],
    )]
    #[Permission(code: 'log:userOperation:list')]
    #[PageResponse(instance: UserAdminOperationLogSchema::class)]
    public function page(): Result
    {
        return $this->success($this->service->page(
            $this->getRequestData(),
            $this->getCurrentPage(),
            $this->getPageSize()
        ));
    }

    #[Delete(
        path: '/admin/user-operation-log',
        operationId: 'UserOperationLogDelete',
        summary: '删除用户操作日志',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['系统管理'],
    )]
    #[Permission(code: 'log:userOperation:delete')]
    #[ResultResponse(instance: Result::class)]
    public function delete(RequestInterface $request): Result
    {
        $this->service->deleteById($request->input('ids'));
        return $this->success();
    }
}
