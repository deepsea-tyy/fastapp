<?php

declare(strict_types=1);

namespace Plugin\Ds\Article\Http\Controller;

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
use Plugin\Ds\Article\Http\Request\ArticleRequest as Request;
use Plugin\Ds\Article\Service\ArticleService as Service;

#[Controller]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
#[Middleware(middleware: OperationMiddleware::class, priority: 98)]
class ArticleController extends AbstractController
{
    public function __construct(
        private readonly Service $service,
        private readonly CurrentUser $currentUser
    ) {}

    #[GetMapping(path: '/admin/article/article/list')]
    #[Permission(code: 'article:article:list')]
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

    #[PostMapping(path: '/admin/article/article/create')]
    #[Permission(code: 'article:article:create')]
    public function create(Request $request): Result
    {
        $this->service->create(array_merge($request->all(), [
            'created_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[PutMapping(path: '/admin/article/article/save/{id}')]
    #[Permission(code: 'article:article:save')]
    public function save(int $id, Request $request): Result
    {
        $this->service->updateById($id, array_merge($request->all(), [
            'updated_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[DeleteMapping(path: '/admin/article/article/delete')]
    #[Permission(code: 'article:article:delete')]
    public function delete(): Result
    {
        $this->service->deleteById($this->getRequestData());
        return $this->success();
    }

}
