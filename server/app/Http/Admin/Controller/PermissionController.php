<?php

declare(strict_types=1);


namespace App\Http\Admin\Controller;

use App\Common\AbstractController;
use App\Common\Middleware\AccessTokenMiddleware;
use App\Common\Result;
use App\Common\ResultCode;
use App\Common\Swagger\PageResponse;
use App\Common\Swagger\ResultResponse;
use App\Exception\BusinessException;
use App\Http\Admin\Request\Permission\PermissionRequest;
use App\Http\Admin\Service\Permission\UserService;
use App\Http\CurrentUser;
use App\Model\Enums\User\Status;
use App\Repository\Permission\MenuRepository;
use App\Repository\Permission\RoleRepository;
use App\Schema\MenuSchema;
use App\Schema\RoleSchema;
use Hyperf\Collection\Arr;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\HyperfServer;
use Hyperf\Swagger\Annotation\Post;
use Psr\SimpleCache\CacheInterface;

#[HyperfServer(name: 'http')]
#[Middleware(AccessTokenMiddleware::class)]
final class PermissionController extends AbstractController
{
    public function __construct(
        private readonly CurrentUser $currentUser,
        private readonly MenuRepository $repository,
        private readonly RoleRepository $roleRepository,
        private readonly UserService $userService
    ) {}

    #[Get(
        path: '/admin/permission/menus',
        operationId: 'PermissionMenus',
        summary: '获取当前用户菜单',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['权限']
    )]
    #[PageResponse(
        instance: MenuSchema::class,
        example: '{"code":200,"message":"成功","data":[]}'
    )]
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

    #[Get(
        path: '/admin/permission/roles',
        operationId: 'PermissionRoles',
        summary: '获取当前用户角色',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['权限']
    )]
    #[PageResponse(
        instance: RoleSchema::class,
        example: '{"code":200,"message":"成功","data":[]}'
    )]
    public function roles(): Result
    {
        return $this->success(
            data: $this->currentUser->isSuperAdmin()
                ? $this->roleRepository->list(['status' => Status::Normal])
                : $this->currentUser->adminUser()->getRoles()
        );
    }

    #[Post(
        path: '/admin/permission/update',
        operationId: 'updateInfo',
        summary: '更新用户信息',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['权限'],
    )]
    #[ResultResponse(new Result())]
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
