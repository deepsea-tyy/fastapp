<?php

declare(strict_types=1);
namespace Plugin\Ds\SysCms\Http\Admin\Controller;

use App\Http\Admin\Controller\AbstractController;
use App\Common\Result;
use App\Http\CurrentUser;
use Plugin\Ds\SysCms\Http\Admin\Request\PlacementPositionRequest as Request;
use Plugin\Ds\SysCms\Http\Admin\Service\PlacementPositionService as Service;
use Hyperf\HttpServer\Annotation\Middleware;
use App\Http\Admin\Permission;
use App\Http\Admin\Middleware\PermissionMiddleware;
use App\Common\Middleware\AccessTokenMiddleware;
use App\Common\Middleware\OperationMiddleware;
use Hyperf\HttpServer\Annotation\Controller;
use Hyperf\HttpServer\Annotation\GetMapping;
use Hyperf\HttpServer\Annotation\PostMapping;
use Hyperf\HttpServer\Annotation\PutMapping;
use Hyperf\HttpServer\Annotation\DeleteMapping;


/**
 * 投放位置控制器
 * 
 * @author 代码生成器
 * @date 2025-12-08 07:41:23
 */
#[Controller]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
class PlacementPositionController extends AbstractController
{
    public function __construct(
        private readonly Service $service,
        private readonly CurrentUser $currentUser
    ) {}

    #[GetMapping(path: '/admin/ds/sysCms/placement_position/list')]
    #[Permission(code: 'ds:sysCms:placement_position:list')]
    public function pageList(): Result
    {
        return $this->success(
            $this->service->page(
                array_merge($this->getRequestData(), [
                    'created_by' => $this->currentUser->id(),
                ]),
                $this->getCurrentPage(),
                $this->getPageSize()
            )
        );
    }
    #[GetMapping(path: '/admin/ds/sysCms/placement_position/selectPlacementPosition')]
    #[Permission(code: 'ds:sysCms:placement_position:list')]
    public function selectPlacementPosition(): Result
    {
        return $this->success(
            $this->service->selectPlacementPosition()
        );
    }

    #[PostMapping(path: '/admin/ds/sysCms/placement_position/create')]
    #[Permission(code: 'ds:sysCms:placement_position:create')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function create(): Result
    {
        $this->service->create(array_merge($this->getRequestData(), [
            'created_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[PutMapping(path: '/admin/ds/sysCms/placement_position/save/{id}')]
    #[Permission(code: 'ds:sysCms:placement_position:save')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function save(int $id): Result
    {
        $this->service->updateById($id, array_merge($this->getRequestData(), [
            'updated_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[DeleteMapping(path: '/admin/ds/sysCms/placement_position/delete')]
    #[Permission(code: 'ds:sysCms:placement_position:delete')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function delete(): Result
    {
        $this->service->deleteById($this->getRequestData(), []);
        return $this->success();
    }
}
