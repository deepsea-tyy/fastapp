<?php

declare(strict_types=1);


namespace App\Http\Admin\Controller\Permission;

use App\Common\Middleware\AccessTokenMiddleware;
use App\Common\Middleware\OperationMiddleware;
use App\Common\Result;
use App\Common\ResultCode;
use App\Exception\BusinessException;
use App\Http\Admin\Controller\AbstractController;
use App\Http\Admin\Middleware\PermissionMiddleware;
use App\Http\Admin\Permission;
use App\Http\Admin\Request\Permission\BatchGrantPermissionsForRoleRequest;
use App\Http\Admin\Request\Permission\RoleRequest;
use App\Http\Admin\Service\Permission\RoleService;
use App\Http\CurrentUser;
use App\Model\Permission\Menu;
use App\Model\Permission\Department;
use Hyperf\Collection\Arr;
use Hyperf\HttpServer\Annotation\Controller;
use Hyperf\HttpServer\Annotation\DeleteMapping;
use Hyperf\HttpServer\Annotation\GetMapping;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\HttpServer\Annotation\PostMapping;
use Hyperf\HttpServer\Annotation\PutMapping;
#[Controller]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
final class RoleController extends AbstractController
{
    public function __construct(
        private readonly RoleService $service,
        private readonly CurrentUser $currentUser
    ) {}

    #[GetMapping(path: '/admin/role/list')]
    #[Permission(code: 'permission:role:index')]
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

    #[PostMapping(path: '/admin/role')]
    #[Permission(code: 'permission:role:save')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function create(RoleRequest $request): Result
    {
        $validated = $request->validated();
        $deptIds = Arr::pull($validated, 'dept_id', []);
        
        $role = $this->service->create(array_merge($validated, [
            'created_by' => $this->currentUser->id(),
        ]));
        
        if (!empty($deptIds)) {
            $this->service->batchGrantDepartmentsForRole($role->id, $deptIds);
        }
        
        return $this->success();
    }

    #[PutMapping(path: '/admin/role/{id}')]
    #[Permission(code: 'permission:role:update')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function save(int $id, RoleRequest $request): Result
    {
        $validated = $request->validated();
        $deptIds = Arr::pull($validated, 'dept_id', []);
        
        $this->service->updateById($id, array_merge($validated, [
            'updated_by' => $this->currentUser->id(),
        ]));
        
        if ($request->has('dept_id')) {
            $this->service->batchGrantDepartmentsForRole($id, $deptIds);
        }
        
        return $this->success();
    }

    #[DeleteMapping(path: '/admin/role')]
    #[Permission(code: 'permission:role:delete')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function delete(): Result
    {
        $this->service->deleteById($this->getRequestData());
        return $this->success();
    }

    #[GetMapping(path: '/admin/role/{id}/permissions')]
    #[Permission(code: 'permission:role:save')]
    public function getRolePermissionForRole(int $id): Result
    {
        return $this->success($this->service->getRolePermission($id)->map(static fn (Menu $menu) => $menu->only([
            'id', 'name',
        ]))->toArray());
    }

    #[PutMapping(path: '/admin/role/{id}/permissions')]
    #[Permission(code: 'permission:role:save')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function batchGrantPermissionsForRole(int $id, BatchGrantPermissionsForRoleRequest $request): Result
    {
        if (! $this->service->existsById($id)) {
            throw new BusinessException(code: ResultCode::NOT_FOUND);
        }
        $permissionsCode = Arr::get($request->validated(), 'permissions', []);
        $this->service->batchGrantPermissionsForRole($id, $permissionsCode);
        return $this->success();
    }

    #[GetMapping(path: '/admin/role/{id}/departments')]
    #[Permission(code: 'permission:role:save')]
    public function getRoleDepartments(int $id): Result
    {
        return $this->success($this->service->getRoleDepartments($id)->map(static fn (Department $dept) => $dept->only([
            'id', 'name',
        ]))->toArray());
    }
}
