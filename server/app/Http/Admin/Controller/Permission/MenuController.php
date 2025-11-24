<?php

declare(strict_types=1);


namespace App\Http\Admin\Controller\Permission;

use App\Common\Middleware\AccessTokenMiddleware;
use App\Common\Middleware\OperationMiddleware;
use App\Common\Result;
use App\Http\Admin\Controller\AbstractController;
use App\Http\Admin\Middleware\PermissionMiddleware;
use App\Http\Admin\Permission;
use App\Http\Admin\Request\Permission\MenuRequest;
use App\Http\Admin\Service\Permission\MenuService;
use App\Http\CurrentUser;
use Hyperf\HttpServer\Annotation\Controller;
use Hyperf\HttpServer\Annotation\DeleteMapping;
use Hyperf\HttpServer\Annotation\GetMapping;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\HttpServer\Annotation\PostMapping;
use Hyperf\HttpServer\Annotation\PutMapping;
use Hyperf\HttpServer\Contract\RequestInterface;
#[Controller]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
final class MenuController extends AbstractController
{
    public function __construct(
        private readonly MenuService $service,
        private readonly CurrentUser $user
    ) {}

    #[GetMapping(path: '/admin/menu/list')]
    #[Permission(code: 'permission:menu:index')]
    public function pageList(RequestInterface $request): Result
    {
        return $this->success(data: $this->service->getRepository()->list([
            'children' => true,
            'parent_id' => 0,
        ]));
    }

    #[PostMapping(path: '/admin/menu')]
    #[Permission(code: 'permission:menu:create')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function create(MenuRequest $request): Result
    {
        $this->service->create(array_merge($request->validated(), [
            'created_by' => $this->user->id(),
        ]));
        return $this->success();
    }

    #[PutMapping(path: '/admin/menu/{id}')]
    #[Permission(code: 'permission:menu:save')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function save(int $id, MenuRequest $request): Result
    {
        $this->service->updateById($id, array_merge($request->validated(), [
            'updated_by' => $this->user->id(),
        ]));
        return $this->success();
    }

    #[DeleteMapping(path: '/admin/menu')]
    #[Permission(code: 'permission:menu:delete')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function delete(): Result
    {
        $this->service->deleteById($this->getRequestData());
        return $this->success();
    }
}
