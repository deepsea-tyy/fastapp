<?php

declare(strict_types=1);


namespace App\Http\Admin\Controller\Permission;

use App\Common\Middleware\AccessTokenMiddleware;
use App\Common\Middleware\OperationMiddleware;
use App\Common\Result;
use App\Http\Admin\Controller\AbstractController;
use App\Http\Admin\Middleware\PermissionMiddleware;
use App\Http\Admin\Permission;
use App\Http\Admin\Request\Permission\DepartmentRequest;
use App\Http\Admin\Service\Permission\DepartmentService;
use App\Http\CurrentUser;
use Hyperf\HttpServer\Annotation\Controller;
use Hyperf\HttpServer\Annotation\DeleteMapping;
use Hyperf\HttpServer\Annotation\GetMapping;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\HttpServer\Annotation\PostMapping;
use Hyperf\HttpServer\Annotation\PutMapping;
#[Controller]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
final class DepartmentController extends AbstractController
{
    public function __construct(
        private readonly DepartmentService $service,
        private readonly CurrentUser $currentUser
    ) {}

    #[GetMapping(path: '/admin/department/list')]
    #[Permission(code: 'permission:department:index')]
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

    #[GetMapping(path: '/admin/department/selectDept')]
    #[Permission(code: 'permission:department:index')]
    public function selectDept(): Result
    {
        return $this->success(data: $this->service->selectDept());
    }

    #[PostMapping(path: '/admin/department')]
    #[Permission(code: 'permission:department:save')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function create(DepartmentRequest $request): Result
    {
        $this->service->create(array_merge($request->validated(), [
            'created_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[PutMapping(path: '/admin/department/{id}')]
    #[Permission(code: 'permission:department:update')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function save(int $id, DepartmentRequest $request): Result
    {
        $this->service->updateById($id, array_merge($request->validated(), [
            'updated_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[DeleteMapping(path: '/admin/department')]
    #[Permission(code: 'permission:department:delete')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function delete(): Result
    {
        $this->service->deleteById($this->getRequestData());
        return $this->success();
    }
}
