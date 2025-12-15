<?php

declare(strict_types=1);
namespace Plugin\Ds\SysCms\Http\Admin\Controller;

use App\Http\Admin\Controller\AbstractController;
use App\Common\Result;
use App\Http\CurrentUser;
use Plugin\Ds\SysCms\Http\Admin\Request\AppPageContentRequest as Request;
use Plugin\Ds\SysCms\Http\Admin\Service\AppPageContentService as Service;
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
 * App页面内容控制器
 * 
 * @author FastApp代码生成器
 * @date 2025-12-08
 */
#[Controller]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
class AppPageContentController extends AbstractController
{
    public function __construct(
        private readonly Service $service,
        private readonly CurrentUser $currentUser
    ) {}

    #[GetMapping(path: '/admin/ds/sysCms/app_page_content/list')]
    #[Permission(code: 'ds:sysCms:app_page_content:list')]
    public function pageList(): Result
    {
        return $this->success(
            $this->service->page(
                $this->getRequestData(),
                $this->getPage(),
                $this->getPageSize()
            )
        );
    }

    #[PostMapping(path: '/admin/ds/sysCms/app_page_content/create')]
    #[Permission(code: 'ds:sysCms:app_page_content:create')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function create(): Result
    {
        $this->service->create($this->getRequestData() + ['created_by' => $this->currentUser->id()]);
        return $this->success();
    }

    #[PutMapping(path: '/admin/ds/sysCms/app_page_content/save/{id}')]
    #[Permission(code: 'ds:sysCms:app_page_content:save')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function save(int $id): Result
    {
        $this->service->updateById($id, $this->getRequestData() + ['updated_by' => $this->currentUser->id()]);
        return $this->success();
    }

    #[DeleteMapping(path: '/admin/ds/sysCms/app_page_content/delete')]
    #[Permission(code: 'ds:sysCms:app_page_content:delete')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function delete(): Result
    {
        $this->service->deleteById($this->getRequestData());
        return $this->success();
    }
}

