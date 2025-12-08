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
use Hyperf\HttpServer\Annotation\PostMapping;
use Hyperf\HttpServer\Annotation\PutMapping;
use Plugin\Ds\SysKefu\Service\KefuService;

#[Controller]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
final class KefuController extends AbstractController
{
    public function __construct(
        private readonly KefuService $service,
        private readonly CurrentUser $currentUser
    )
    {
    }

    #[GetMapping(path: '/admin/ds/sysKefu/kefu/list')]
    #[Permission(code: 'ds:sysKefu:kefu:index')]
    public function pageList(): Result
    {
        return $this->success(
            $this->service->page(
                array_merge(['created_by' => $this->currentUser->id()], $this->getRequestData()),
                $this->getCurrentPage(),
                $this->getPageSize()
            )
        );
    }

    #[PostMapping(path: '/admin/ds/sysKefu/kefu/create')]
    #[Permission(code: 'ds:sysKefu:kefu:save')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function create(): Result
    {
        $this->service->create(array_merge($this->getRequestData(), [
            'created_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[PutMapping(path: '/admin/ds/sysKefu/kefu/save/{id}')]
    #[Permission(code: 'ds:sysKefu:kefu:update')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function save(int $id): Result
    {
        $this->service->updateById($id, array_merge($this->getRequestData(), [
            'updated_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[DeleteMapping(path: '/admin/ds/sysKefu/kefu/delete')]
    #[Permission(code: 'ds:sysKefu:kefu:delete')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function delete(): Result
    {
        $this->service->deleteById($this->getRequestData());
        return $this->success();
    }
}
