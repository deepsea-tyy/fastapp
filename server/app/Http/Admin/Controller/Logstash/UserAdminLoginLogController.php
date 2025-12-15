<?php

declare(strict_types=1);


namespace App\Http\Admin\Controller\Logstash;

use App\Common\Middleware\AccessTokenMiddleware;
use App\Common\Result;
use App\Http\Admin\Controller\AbstractController;
use App\Http\Admin\Middleware\PermissionMiddleware;
use App\Http\Admin\Permission;
use App\Http\Admin\Service\Logstash\UserAdminLoginLogService;
use App\Http\CurrentUser;
use Hyperf\HttpServer\Annotation\Controller;
use Hyperf\HttpServer\Annotation\DeleteMapping;
use Hyperf\HttpServer\Annotation\GetMapping;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\HttpServer\Contract\RequestInterface;
#[Controller]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
final class UserAdminLoginLogController extends AbstractController
{
    public function __construct(
        protected readonly UserAdminLoginLogService $service,
        protected readonly CurrentUser              $currentUser
    ) {}

    #[GetMapping(path: '/admin/user-login-log/list')]
    #[Permission(code: 'log:userLogin:list')]
    public function page(): Result
    {
        return $this->success(
            $this->service->page(
                $this->getRequestData(),
                $this->getPage(),
                $this->getPageSize()
            )
        );
    }

    #[DeleteMapping(path: '/admin/user-login-log')]
    #[Permission(code: 'log:userLogin:delete')]
    public function delete(RequestInterface $request): Result
    {
        $this->service->deleteById($request->input('ids'));
        return $this->success();
    }
}
