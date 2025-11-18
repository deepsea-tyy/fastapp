<?php

declare(strict_types=1);

namespace Plugin\Ds\Kefu\Http\Admin\Controller;

use App\Common\Middleware\AccessTokenMiddleware;
use App\Common\Middleware\OperationMiddleware;
use App\Common\Result;
use App\Common\Swagger\PageResponse;
use App\Http\Admin\Controller\AbstractController;
use App\Http\Admin\Middleware\PermissionMiddleware;
use App\Http\Admin\Permission;
use App\Http\CurrentUser;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\Swagger\Annotation\Delete;
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\HyperfServer;
use Plugin\Ds\Kefu\Schema\KefuConversationSchema;
use Plugin\Ds\Kefu\Service\KefuConversationService;

/**
 * 客服会话表控制器
 */
#[HyperfServer(name: 'http')]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
#[Middleware(middleware: OperationMiddleware::class, priority: 98)]
final class KefuConversationController extends AbstractController
{
    public function __construct(
        private readonly KefuConversationService $service,
        private readonly CurrentUser             $currentUser
    )
    {
    }

    #[Get(
        path: '/admin/kefu/kefuConversation/list',
        operationId: 'KefuKefuconversationList',
        summary: '客服会话表控制器列表',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['客服会话表控制器'],
    )]
    #[Permission(code: 'kefu:kefuConversation:index')]
    #[PageResponse(instance: KefuConversationSchema::class)]
    public function page(): Result
    {
        return $this->success(data: $this->service->page(array_merge([
            'created_by' => $this->currentUser->id()
        ], $this->getRequestData()), $this->getCurrentPage(), $this->getPageSize()));
    }

    #[Delete(
        path: '/admin/kefu/kefuConversation',
        operationId: 'KefuKefuconversationDelete',
        summary: '删除客服会话表控制器',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['客服会话表控制器']
    )]
    #[PageResponse(instance: new Result())]
    #[Permission(code: 'kefu:kefuConversation:delete')]
    public function delete(): Result
    {
        $this->service->deleteById($this->getRequestData());
        return $this->success();
    }

    #[Get(
        path: '/admin/kefu/kefuConversation/message',
        operationId: 'KefuKefuconversationMessage',
        summary: '客服会话消息详情',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['客服会话表控制器'],
    )]
    #[Permission(code: 'kefu:kefuConversation:index')]
    public function message(): Result
    {
        $res = $this->service->message($this->getRequestData());
        return $res ? $this->success($res) : $this->error();
    }

    #[Get(
        path: '/admin/kefu/kefuConversation/chatTree',
        operationId: 'KefuKefuconversationChatTree',
        summary: '客服会话树列表',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['客服会话表控制器'],
    )]
    #[Permission(code: 'kefu:kefuConversation:index')]
    public function chatTree(): Result
    {
        return $this->success(data: $this->service->chatTree($this->currentUser->id()));
    }

    #[Get(
        path: '/admin/kefu/kefuConversation/messageVisitor',
        operationId: 'KefuKefuconversationMessageVisitor',
        summary: '客服游客会话消息详情',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['客服会话表控制器'],
    )]
    #[Permission(code: 'kefu:kefuConversation:index')]
    public function messageVisitor(): Result
    {
        $res = $this->service->messageVisitor($this->getRequestData());
        return $res ? $this->success($res) : $this->error();
    }

    #[Get(
        path: '/admin/kefu/kefuConversation/chatVisitorTree',
        operationId: 'KefuKefuconversationChatVisitorTree',
        summary: '客服游客会话列表',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['客服会话表控制器'],
    )]
    #[Permission(code: 'kefu:kefuConversation:index')]
    public function chatVisitorTree(): Result
    {
        return $this->success(data: $this->service->chatVisitorTree($this->currentUser->id()));
    }
}
