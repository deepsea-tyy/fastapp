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
use Plugin\Ds\SystemConfig\Http\Request\ConfigRequest as Request;
use Plugin\Ds\SystemConfig\Service\ConfigService as Service;

#[Controller]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
class ConfigController extends AbstractController
{
    public function __construct(
        private readonly Service $service,
        private readonly CurrentUser $currentUser
    ) {}

    #[GetMapping(path: '/system/Config/list')]
    #[Permission(code: 'plugin:ds:config:list')]
    public function pageList(): Result
    {
        return $this->success(
            $this->service->page(
                $this->getRequestData(),
                $this->getCurrentPage(),
                $this->getPageSize()
            )
        );
    }

    #[GetMapping(path: '/system/Config/Details/{code}')]
    #[Permission(code: 'plugin:ds:config:details')]
    public function details(string $code): Result
    {
        return $this->success(
            $this->service->getDetails(['group_code' => $code])
        );
    }

    #[PostMapping(path: '/system/Config')]
    #[Permission(code: 'plugin:ds:config:create')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function create(Request $request): Result
    {
        $this->service->create(array_merge($request->all(), [
            'created_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[PutMapping(path: '/system/Config/{id}')]
    #[Permission(code: 'plugin:ds:config:update')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function save(int $id, Request $request): Result
    {
        $this->service->updateById($id, array_merge($request->validated(), [
            'updated_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[DeleteMapping(path: '/system/Config')]
    #[Permission(code: 'plugin:ds:config:delete')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function delete(): Result
    {
        $this->service->deleteByKey($this->getRequestData());
        return $this->success();
    }

    #[PostMapping(path: '/system/Config/batchUpdate')]
    #[Permission(code: 'plugin:ds:config:batchUpdate')]
    public function batchUpdate(): Result
    {
        $this->service->upsertData($this->getRequestData());
        return $this->success();
    }
}
