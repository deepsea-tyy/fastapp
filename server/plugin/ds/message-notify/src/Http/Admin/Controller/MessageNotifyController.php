<?php

declare(strict_types=1);

namespace Plugin\Ds\MessageNotify\Http\Admin\Controller;

use App\Http\Admin\Controller\AbstractController;
use App\Common\Result;
use App\Http\CurrentUser;
use Plugin\Ds\MessageNotify\Http\Admin\Request\MessageNotifyRequest as Request;
use Plugin\Ds\MessageNotify\Http\Admin\Service\MessageNotifyService as Service;
use App\Http\Admin\Permission;
use App\Http\Admin\Middleware\PermissionMiddleware;
use App\Common\Middleware\AccessTokenMiddleware;
use App\Common\Middleware\OperationMiddleware;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\Swagger\Annotation as OA;
use Hyperf\Swagger\Annotation\Delete;
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\Post;
use Hyperf\Swagger\Annotation\Put;
use App\Common\Swagger\ResultResponse;



/**
 * 消息通知控制器
 * 
 * @author 代码生成器
 * @date 2025-11-06 10:28:18
 */
#[OA\Tag('消息通知')]
#[OA\HyperfServer('http')]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
#[Middleware(middleware: OperationMiddleware::class, priority: 98)]
class MessageNotifyController extends AbstractController
{
    public function __construct(
        private readonly Service $service,
        private readonly CurrentUser $currentUser
    ) {}

    #[Get(
        path: '/admin/ds/message-notify/message_notify/list',
        operationId: 'ds:message-notify:admin:message_notify:list',
        summary: '消息通知列表',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['消息通知'],
    )]
    #[Permission(code: 'ds:message-notify:admin:message_notify:list')]
    #[ResultResponse(instance: new Result())]
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

    #[Post(
        path: '/admin/ds/message-notify/message_notify/create',
        operationId: 'ds:message-notify:admin:message_notify:create',
        summary: '消息通知新增',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['消息通知'],
    )]
    #[Permission(code: 'ds:message-notify:admin:message_notify:create')]
    #[ResultResponse(instance: new Result())]
    public function create(Request $request): Result
    {
        $this->service->create(array_merge($request->all(), [
            'created_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[Put(
        path: '/admin/ds/message-notify/message_notify/save/{id}',
        operationId: 'ds:message-notify:admin:message_notify:save',
        summary: '消息通知保存',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['消息通知'],
    )]
    #[Permission(code: 'ds:message-notify:admin:message_notify:save')]
    #[ResultResponse(instance: new Result())]
    public function save(int $id, Request $request): Result
    {
        $this->service->updateById($id, array_merge($request->all(), [
            'updated_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[Delete(
        path: '/admin/ds/message-notify/message_notify/delete',
        operationId: 'ds:message-notify:admin:message_notify:delete',
        summary: '消息通知删除',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['消息通知'],
    )]
    #[ResultResponse(instance: new Result())]
    #[Permission(code: 'ds:message-notify:admin:message_notify:delete')]
    public function delete(): Result
    {
        $this->service->deleteById($this->getRequestData());
        return $this->success();
    }
}
