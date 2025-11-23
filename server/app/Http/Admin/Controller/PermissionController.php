<?php

declare(strict_types=1);


namespace App\Http\Admin\Controller;

use App\Common\AbstractController;
use App\Common\Middleware\AccessTokenMiddleware;
use App\Common\Result;
use App\Common\ResultCode;
use App\Exception\BusinessException;
use App\Http\Admin\Request\Permission\PermissionRequest;
use App\Http\Admin\Service\Permission\UserService;
use App\Http\CurrentUser;
use App\Model\Enums\User\Status;
use App\Repository\Permission\MenuRepository;
use App\Repository\Permission\RoleRepository;
use Hyperf\Collection\Arr;
use Hyperf\HttpServer\Annotation\Controller;
use Hyperf\HttpServer\Annotation\GetMapping;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\HttpServer\Annotation\PostMapping;
use Psr\SimpleCache\CacheInterface;
#[Controller]
#[Middleware(AccessTokenMiddleware::class)]
final class PermissionController extends AbstractController
{
    public function __construct(
        private readonly CurrentUser $currentUser,
        private readonly MenuRepository $repository,
        private readonly RoleRepository $roleRepository,
        private readonly UserService $userService
    ) {}

    #[GetMapping(path: '/admin/permission/menus')]
    public function menus(): Result
    {
        return $this->success(
            data: $this->currentUser->isSuperAdmin()
                ? $this->repository->list([
                    'status' => Status::Normal,
                    'children' => true,
                    'parent_id' => 0,
                ])
                : $this->currentUser->filterCurrentUser()
        );
    }

    #[GetMapping(path: '/admin/permission/roles')]
    public function roles(): Result
    {
        return $this->success(
            data: $this->currentUser->isSuperAdmin()
                ? $this->roleRepository->list(['status' => Status::Normal])
                : $this->currentUser->adminUser()->getRoles()
        );
    }

    #[PostMapping(path: '/admin/permission/update')]
    public function update(PermissionRequest $request, CacheInterface $cache): Result
    {
        $data = $request->validated();
        $user = $this->currentUser->adminUser();
        if (Arr::exists($data, 'new_password')) {
            if (! $user->verifyPassword(Arr::get($data, 'old_password'))) {
                throw new BusinessException(ResultCode::UNPROCESSABLE_ENTITY, trans('user.old_password_error'));
            }
            $data['password'] = $data['new_password'];
        }
        $this->userService->updateById($user->id, $data);
        $cache->delete((string)$user->id);
        return $this->success();
    }
}
