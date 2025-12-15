<?php

declare(strict_types=1);

namespace Plugin\Ds\SysNotify\Http\Admin\Controller;

use App\Http\Admin\Controller\AbstractController;
use App\Common\Result;
use App\Http\CurrentUser;
use Plugin\Ds\SysNotify\Http\Admin\Request\MessageNotifyRequest as Request;
use Plugin\Ds\SysNotify\Http\Admin\Service\MessageNotifyService as Service;
use App\Http\Admin\Permission;
use App\Http\Admin\Middleware\PermissionMiddleware;
use App\Common\Middleware\AccessTokenMiddleware;
use App\Common\Middleware\OperationMiddleware;
use Hyperf\HttpServer\Annotation\Controller;
use Hyperf\HttpServer\Annotation\DeleteMapping;
use Hyperf\HttpServer\Annotation\GetMapping;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\HttpServer\Annotation\PostMapping;
use Hyperf\HttpServer\Annotation\PutMapping;

/**
 * 消息通知控制器
 * 
 * @author FastApp代码生成器
 * @date 2025-11-06 10:28:18
 */
#[Controller]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
class MessageNotifyController extends AbstractController
{
    public function __construct(
        private readonly Service $service,
        private readonly CurrentUser $currentUser
    ) {}

    #[GetMapping(path: '/admin/ds/sysNotify/message_notify/list')]
    #[Permission(code: 'ds:sysNotify:admin:message_notify:list')]
    public function pageList(): Result
    {
        return $this->success(
            $this->service->page(
                $this->getRequestData(),
                $this->getPage(),
                $this->getPageSize()
            )
        );
    }

    #[PostMapping(path: '/admin/ds/sysNotify/message_notify/create')]
    #[Permission(code: 'ds:sysNotify:admin:message_notify:create')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function create(Request $request): Result
    {
        $this->service->create(array_merge($request->all(), [
            'created_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[PutMapping(path: '/admin/ds/sysNotify/message_notify/save/{id}')]
    #[Permission(code: 'ds:sysNotify:admin:message_notify:save')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function save(int $id, Request $request): Result
    {
        $this->service->updateById($id, array_merge($request->all(), [
            'updated_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[DeleteMapping(path: '/admin/ds/sysNotify/message_notify/delete')]
    #[Permission(code: 'ds:sysNotify:admin:message_notify:delete')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function delete(): Result
    {
        $this->service->deleteById($this->getRequestData());
        return $this->success();
    }
}
