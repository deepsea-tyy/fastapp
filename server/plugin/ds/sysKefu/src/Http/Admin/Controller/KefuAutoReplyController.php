<?php

declare(strict_types=1);
namespace Plugin\Ds\SysKefu\Http\Admin\Controller;

use App\Http\Admin\Controller\AbstractController;
use App\Common\Result;
use App\Http\CurrentUser;
use Plugin\Ds\SysKefu\Http\Admin\Request\KefuAutoReplyRequest as Request;
use Plugin\Ds\SysKefu\Http\Admin\Service\KefuAutoReplyService as Service;
use Hyperf\HttpServer\Annotation\Middleware;
use App\Http\Admin\Permission;
use App\Http\Admin\Middleware\PermissionMiddleware;
use App\Common\Middleware\AccessTokenMiddleware;
use App\Common\Middleware\OperationMiddleware;
use Hyperf\HttpServer\Annotation\Controller;
use Hyperf\HttpServer\Annotation\GetMapping;
use Hyperf\HttpServer\Annotation\PostMapping;
use Hyperf\HttpServer\Annotation\PutMapping;
use Hyperf\HttpServer\Annotation\DeleteMapping;


/**
 * 客服自动回复规则控制器
 * 
 * @author FastApp代码生成器
 * @date 2025-12-26 19:17:40
 */
#[Controller]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
class KefuAutoReplyController extends AbstractController
{
    public function __construct(
        private readonly Service $service,
        private readonly CurrentUser $currentUser
    ) {}

    #[GetMapping(path: '/admin/ds/syskefu/kefu_auto_reply/list')]
    #[Permission(code: 'ds:syskefu:kefu_auto_reply:list')]
    public function pageList(): Result
    {
        return $this->success(
            $this->service->page(
                array_merge($this->getRequestData(), [
                    'created_by' => $this->currentUser->id(),
                ]),
                $this->getPage(),
                $this->getPageSize()
            )
        );
    }

    #[PostMapping(path: '/admin/ds/syskefu/kefu_auto_reply/create')]
    #[Permission(code: 'ds:syskefu:kefu_auto_reply:create')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function create(Request $request): Result
    {
        $this->service->create(array_merge($this->getRequestData(), [
            'created_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[PutMapping(path: '/admin/ds/syskefu/kefu_auto_reply/save/{id}')]
    #[Permission(code: 'ds:syskefu:kefu_auto_reply:save')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function save(int $id, Request $request): Result
    {
        $this->service->updateById($id, array_merge($this->getRequestData(), [
            'updated_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[DeleteMapping(path: '/admin/ds/syskefu/kefu_auto_reply/delete')]
    #[Permission(code: 'ds:syskefu:kefu_auto_reply:delete')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function delete(): Result
    {
        $this->service->deleteById($this->getRequestData(), []);
        return $this->success();
    }
}
