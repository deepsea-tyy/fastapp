<?php

declare(strict_types=1);


namespace App\Http\Admin\Controller;

use App\Common\AbstractController;
use App\Common\Middleware\AdminTokenMiddleware;
use App\Common\Result;
use App\Common\ResultCode;
use App\Exception\BusinessException;
use App\Http\Admin\Request\Permission\PermissionRequest;
use App\Http\Admin\Service\Permission\MenuService;
use App\Http\CurrentUser;
use App\Model\Enums\User\Status;
use App\Repository\Permission\RoleRepository;
use Hyperf\Collection\Arr;
use Hyperf\HttpServer\Annotation\Controller;
use Hyperf\HttpServer\Annotation\GetMapping;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\HttpServer\Annotation\PostMapping;
use Psr\SimpleCache\CacheInterface;
#[Controller]
#[Middleware(AdminTokenMiddleware::class)]
final class PermissionController extends AbstractController
{
    public function __construct(
        private readonly RoleRepository $roleRepository,
        private readonly MenuService    $menuService,
        private readonly CurrentUser    $currentUser
    ) {}

    #[GetMapping(path: '/admin/permission/menus')]
    public function menus(): Result
    {
        $userId = $this->currentUser->id();
        if ($this->currentUser->isSuperAdmin($userId)) {
            $menuList = $this->menuService->getList([])->toArray();
        } else {
            $permissions = $this->currentUser->getInfo($userId, withRoles: true)?->getPermissions()
                ->pluck('name')
                ->unique();
            $menuList = $permissions && !$permissions->isEmpty()
                ? $this->menuService->getList(['status' => Status::Normal, 'name' => $permissions->toArray()])->toArray()
                : [];
        }
        return $this->success(MenuService::buildTree($menuList));
    }

    #[GetMapping(path: '/admin/permission/roles')]
    public function roles(): Result
    {
        return $this->success(
            data: $this->currentUser->isSuperAdmin()
                ? $this->roleRepository->list(['status' => Status::Normal])
                : $this->currentUser->getInfo(withRoles: true)?->getRoles()
        );
    }

    #[PostMapping(path: '/admin/permission/update')]
    public function update(PermissionRequest $request, CacheInterface $cache): Result
    {
        $data = $request->validated();
        $user = $this->currentUser->getInfo();
        if (Arr::exists($data, 'new_password')) {
            if (! $user->verifyPassword(Arr::get($data, 'old_password'))) {
                throw new BusinessException(ResultCode::UNPROCESSABLE_ENTITY, trans('user.old_password_error'));
            }
            $data['password'] = $data['new_password'];
        }
        $this->currentUser->updateUser($user->id, $data);
        $cache->delete((string)$user->id);
        return $this->success();
    }
}
