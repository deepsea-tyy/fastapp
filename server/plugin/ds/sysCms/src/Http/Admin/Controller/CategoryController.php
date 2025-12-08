<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Http\Admin\Controller;

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
use Plugin\Ds\SysCms\Http\Admin\Request\CategoryRequest as Request;
use Plugin\Ds\SysCms\Http\Admin\Service\CategoryService as Service;

#[Controller]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
class CategoryController extends AbstractController
{
    public function __construct(
        private readonly Service $service,
        private readonly CurrentUser $currentUser
    ) {}

    #[GetMapping(path: '/admin/article/category/list')]
    #[Permission(code: 'article:category:list')]
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
    #[GetMapping(path: '/admin/article/category/selectCategory')]
    #[Permission(code: 'article:category:selectCategory')]
    public function selectCategory(Request $request): Result
    {
        return $this->success($this->service->selectCategory($request->all()));
    }

    #[PostMapping(path: '/admin/article/category/create')]
    #[Permission(code: 'article:category:create')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function create(Request $request): Result
    {
        $this->service->create(array_merge($request->all(), [
            'created_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[PutMapping(path: '/admin/article/category/save/{id}')]
    #[Permission(code: 'article:category:save')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function save(int $id, Request $request): Result
    {
        $this->service->updateById($id, array_merge($request->all(), [
            'updated_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[DeleteMapping(path: '/admin/article/category/delete')]
    #[Permission(code: 'article:category:delete')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function delete(): Result
    {
        $this->service->deleteById($this->getRequestData());
        return $this->success();
    }

}
