<?php

declare(strict_types=1);


namespace App\Http\Admin\Controller\Permission;

use App\Common\Middleware\AccessTokenMiddleware;
use App\Common\Middleware\OperationMiddleware;
use App\Common\Request\Request;
use App\Common\Result;
use App\Http\Admin\Controller\AbstractController;
use App\Http\Admin\Middleware\PermissionMiddleware;
use App\Http\Admin\Permission;
use App\Http\Admin\Request\Permission\BatchGrantRolesForUserRequest;
use App\Http\Admin\Request\Permission\UpdateInfoRequest;
use App\Http\Admin\Request\Permission\UserRequest;
use App\Http\Admin\Service\Permission\DataScopeTool;
use App\Http\Admin\Service\Permission\AdminUserService;
use App\Http\CurrentUser;
use App\Model\Permission\Role;
use Hyperf\HttpServer\Annotation\Controller;
use Hyperf\HttpServer\Annotation\DeleteMapping;
use Hyperf\HttpServer\Annotation\GetMapping;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\HttpServer\Annotation\PostMapping;
use Hyperf\HttpServer\Annotation\PutMapping;
#[Controller]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
final class UserController extends AbstractController
{
    public function __construct(
        private readonly AdminUserService $userService,
        private readonly CurrentUser      $currentUser
    )
    {
    }

    #[GetMapping(path: '/admin/user/list')]
    #[Permission(code: 'permission:user:index')]
    public function pageList(): Result
    {
        return $this->success(
            $this->userService->page(
                array_merge($this->getRequestData(), ['created_by' => $this->currentUser->id()]),
                $this->getPage(),
                $this->getPageSize()
            )
        );
    }
    #[GetMapping(path: '/admin/user/selectUser')]
    public function selectUser(Request $request): Result
    {
        return $this->success($this->userService->selectUser($request->input('keyword', '')));
    }
    #[GetMapping(path: '/admin/user/clearCache')]
    public function clearCache(): Result
    {
        DataScopeTool::clearCurrentUserCache($this->currentUser->id());
        return $this->success();
    }

    #[PutMapping(path: '/admin/user/info')]
    #[Permission(code: 'permission:user:update')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function updateInfo(UpdateInfoRequest $request): Result
    {
        $this->userService->updateById($this->currentUser->id(), $request->validated());
        return $this->success();
    }

    #[PutMapping(path: '/admin/user/password')]
    #[Permission(code: 'permission:user:password')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function resetPassword(): Result
    {
        return $this->userService->resetPassword($this->getRequest()->input('id'))
            ? $this->success()
            : $this->error();
    }

    #[PostMapping(path: '/admin/user')]
    #[Permission(code: 'permission:user:save')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function create(UserRequest $request): Result
    {
        $this->userService->create(array_merge($request->validated(), [
            'created_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[DeleteMapping(path: '/admin/user')]
    #[Permission(code: 'permission:user:delete')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function delete(): Result
    {
        $this->userService->deleteById($this->getRequestData());
        return $this->success();
    }

    #[PutMapping(path: '/admin/user/{userId}')]
    #[Permission(code: 'permission:user:update')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function save(int $userId, UserRequest $request): Result
    {
        $this->userService->updateById($userId, array_merge($request->validated(), [
            'updated_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[GetMapping(path: '/admin/user/{userId}/roles')]
    #[Permission(code: 'permission:user:getRole')]
    public function getUserRole(int $userId): Result
    {
        return $this->success($this->userService->getUserRole($userId)->map(static fn(Role $role) => $role->only([
            'id',
            'code',
            'name',
        ])));
    }

    #[PutMapping(path: '/admin/user/{userId}/roles')]
    #[Permission(code: 'permission:user:setRole')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function batchGrantRolesForUser(int $userId, BatchGrantRolesForUserRequest $request): Result
    {
        $this->userService->batchGrantRoleForUser($userId, $request->input('role_codes'));
        return $this->success();
    }
}
