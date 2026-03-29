<?php

declare(strict_types=1);
namespace App\Http\Admin\Controller\Search;

use App\Http\Admin\Controller\AbstractController;
use App\Common\Result;
use App\Http\CurrentUser;
use App\Http\Admin\Request\Search\KeywordRequest as Request;
use App\Http\Admin\Service\Search\KeywordService as Service;
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
 * 搜索关键词记录控制器
 * 
 * @author FastApp代码生成器
 * @date 2025-12-23 20:31:50
 */
#[Controller]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
class KeywordController extends AbstractController
{
    public function __construct(
        private readonly Service $service,
        private readonly CurrentUser $currentUser
    ) {}

    #[GetMapping(path: '/admin/search/keyword/list')]
    #[Permission(code: 'search:keyword:list')]
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

    #[PostMapping(path: '/admin/search/keyword/create')]
    #[Permission(code: 'search:keyword:create')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function create(Request $request): Result
    {
        $this->service->create(array_merge($this->getRequestData(), [
            'created_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[PutMapping(path: '/admin/search/keyword/save/{id}')]
    #[Permission(code: 'search:keyword:save')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function save(int $id, Request $request): Result
    {
        $this->service->updateById($id, array_merge($this->getRequestData(), [
            'updated_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[DeleteMapping(path: '/admin/search/keyword/delete')]
    #[Permission(code: 'search:keyword:delete')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function delete(): Result
    {
        $this->service->deleteById($this->getRequestData(), []);
        return $this->success();
    }
}
