<?php

declare(strict_types=1);

namespace Plugin\Ds\SysKefu\Http\Admin\Controller;

use App\Common\Middleware\AccessTokenMiddleware;
use App\Common\Middleware\OperationMiddleware;
use App\Common\Result;
use App\Http\Admin\Controller\AbstractController;
use App\Http\Admin\Middleware\PermissionMiddleware;
use App\Http\Admin\Permission;
use App\Http\CurrentUser;
use Hyperf\HttpServer\Annotation\Controller;
use Hyperf\HttpServer\Annotation\DeleteMapping;
use Hyperf\HttpServer\Annotation\GetMapping;
use Hyperf\HttpServer\Annotation\Middleware;
use Plugin\Ds\SysKefu\Service\KefuConversationService;

/**
 * 客服会话表控制器
 */
#[Controller]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
final class KefuConversationController extends AbstractController
{
    public function __construct(
        private readonly KefuConversationService $service,
        private readonly CurrentUser             $currentUser
    )
    {
    }

    #[GetMapping(path: '/admin/ds/sysKefu/kefuConversation/list')]
    #[Permission(code: 'sysKefu:kefuConversation:index')]
    public function page(): Result
    {
        return $this->success(data: $this->service->page(array_merge([
            'created_by' => $this->currentUser->id()
        ], $this->getRequestData()), $this->getPage(), $this->getPageSize()));
    }

    #[DeleteMapping(path: '/admin/ds/sysKefu/kefuConversation')]
    #[Permission(code: 'sysKefu:kefuConversation:delete')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function delete(): Result
    {
        $this->service->deleteById($this->getRequestData());
        return $this->success();
    }

    #[GetMapping(path: '/admin/ds/sysKefu/kefuConversation/message')]
    #[Permission(code: 'sysKefu:kefuConversation:index')]
    public function message(): Result
    {
        $res = $this->service->message($this->getRequestData());
        return $res ? $this->success($res) : $this->error();
    }

    #[GetMapping(path: '/admin/ds/sysKefu/kefuConversation/chatTree')]
    #[Permission(code: 'sysKefu:kefuConversation:index')]
    public function chatTree(): Result
    {
        return $this->success(data: $this->service->chatTree($this->currentUser->id()));
    }

    #[GetMapping(path: '/admin/ds/sysKefu/kefuConversation/messageVisitor')]
    #[Permission(code: 'sysKefu:kefuConversation:index')]
    public function messageVisitor(): Result
    {
        $res = $this->service->messageVisitor($this->getRequestData());
        return $res ? $this->success($res) : $this->error();
    }

    #[GetMapping(path: '/admin/ds/sysKefu/kefuConversation/chatVisitorTree')]
    #[Permission(code: 'sysKefu:kefuConversation:index')]
    public function chatVisitorTree(): Result
    {
        return $this->success(data: $this->service->chatVisitorTree($this->currentUser->id()));
    }
}
