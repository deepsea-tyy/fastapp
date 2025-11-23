<?php

declare(strict_types=1);


namespace Plugin\Ds\SystemConfig\Http\Controller;

use App\Http\Admin\Permission;
use App\Common\Middleware\AccessTokenMiddleware;
use App\Common\Middleware\OperationMiddleware;
use App\Common\Result;
use App\Http\Admin\Controller\AbstractController;
use App\Http\Admin\Middleware\PermissionMiddleware;
use App\Http\CurrentUser;
use Hyperf\HttpServer\Annotation\Controller;
use Hyperf\HttpServer\Annotation\DeleteMapping;
use Hyperf\HttpServer\Annotation\GetMapping;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\HttpServer\Annotation\PostMapping;
use Hyperf\HttpServer\Annotation\PutMapping;
use Plugin\Ds\SystemConfig\Http\Request\ConfigGroupRequest as Request;
use Plugin\Ds\SystemConfig\Service\ConfigGroupService as Service;

/**
 * 参数配置分组表控制器
 * Class SystemConfigGroupController.
 */
#[Controller]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
#[Middleware(middleware: OperationMiddleware::class, priority: 98)]
final class ConfigGroupController extends AbstractController
{
    /**
     * 业务处理服务
     * SystemConfigGroupService.
     */
    public function __construct(
        protected readonly Service $service,
        protected readonly CurrentUser $currentUser
    ) {}

    #[GetMapping(path: '/system/ConfigGroup/list')]
    #[Permission(code: 'plugin:ds:configGroup:list')]
    public function page(): Result
    {
        return $this->success(data: $this->service->getList([]));
    }

    #[PostMapping(path: '/system/ConfigGroup')]
    #[Permission(code: 'plugin:ds:configGroup:index:create')]
    public function create(Request $request): Result
    {
        $this->service->create(array_merge($request->post(), [
            'created_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[PutMapping(path: '/system/ConfigGroup/{id}')]
    #[Permission(code: 'plugin:ds:configGroup:update')]
    public function save(int $id, Request $request): Result
    {
        $this->service->updateById($id, array_merge($request->validated(), [
            'updated_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[DeleteMapping(path: '/system/ConfigGroup')]
    #[Permission(code: 'plugin:ds:configGroup:delete')]
    public function delete(): Result
    {
        $this->service->deleteById($this->getRequestData());
        return $this->success();
    }
}
