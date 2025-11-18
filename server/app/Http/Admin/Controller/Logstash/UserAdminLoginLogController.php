<?php

declare(strict_types=1);


namespace App\Http\Admin\Controller\Logstash;

use App\Common\Middleware\AccessTokenMiddleware;
use App\Common\Result;
use App\Common\Swagger\PageResponse;
use App\Http\Admin\Controller\AbstractController;
use App\Http\Admin\Middleware\PermissionMiddleware;
use App\Http\Admin\Permission;
use App\Http\Admin\Service\Logstash\UserAdminLoginLogService;
use App\Http\CurrentUser;
use App\Schema\UserAdminLoginLogSchema;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\HttpServer\Contract\RequestInterface;
use Hyperf\Swagger\Annotation\Delete;
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\HyperfServer;

#[HyperfServer(name: 'http')]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
final class UserAdminLoginLogController extends AbstractController
{
    public function __construct(
        protected readonly UserAdminLoginLogService $service,
        protected readonly CurrentUser              $currentUser
    ) {}

    #[Get(
        path: '/admin/user-login-log/list',
        operationId: 'UserLoginLogList',
        summary: '用户登录日志列表',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['系统管理'],
    )]
    #[Permission(code: 'log:userLogin:list')]
    #[PageResponse(instance: UserAdminLoginLogSchema::class)]
    public function page(): Result
    {
        return $this->success(
            $this->service->page(
                $this->getRequestData(),
                $this->getCurrentPage(),
                $this->getPageSize()
            )
        );
    }

    #[Delete(
        path: '/admin/user-login-log',
        operationId: 'UserLoginLogDelete',
        summary: '删除用户登录日志',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['系统管理'],
    )]
    #[Permission(code: 'log:userLogin:delete')]
    public function delete(RequestInterface $request): Result
    {
        $this->service->deleteById($request->input('ids'));
        return $this->success();
    }
}
