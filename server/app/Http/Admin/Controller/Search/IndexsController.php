<?php

declare(strict_types=1);
namespace App\Http\Admin\Controller\Search;

use App\Http\Admin\Controller\AbstractController;
use App\Common\Result;
use App\Http\CurrentUser;
use App\Http\Admin\Request\Search\IndexsRequest as Request;
use App\Http\Admin\Service\Search\IndexsService as Service;
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
 * 搜索索引 - 统一存储可搜索内容控制器
 * 
 * @author FastApp代码生成器
 * @date 2025-12-24 10:09:06
 */
#[Controller]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
class IndexsController extends AbstractController
{
    public function __construct(
        private readonly Service $service,
        private readonly CurrentUser $currentUser
    ) {}

    #[GetMapping(path: '/admin/search/indexs/list')]
    #[Permission(code: 'search:indexs:list')]
    public function pageList(): Result
    {
        return $this->success(
            $this->service->page(
                array_merge($this->getRequestData(), [
                    'created_by' => $this->currentUser->id(),
                ]),
                $this->getPage(),
                $this->getPageSize()
            )
        );
    }

    #[PostMapping(path: '/admin/search/indexs/create')]
    #[Permission(code: 'search:indexs:create')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function create(Request $request): Result
    {
        $this->service->create(array_merge($this->getRequestData(), [
            'created_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[PutMapping(path: '/admin/search/indexs/save/{id}')]
    #[Permission(code: 'search:indexs:save')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function save(int $id, Request $request): Result
    {
        $this->service->updateById($id, array_merge($this->getRequestData(), [
            'updated_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[DeleteMapping(path: '/admin/search/indexs/delete')]
    #[Permission(code: 'search:indexs:delete')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function delete(): Result
    {
        $this->service->deleteById($this->getRequestData(), []);
        return $this->success();
    }
}
