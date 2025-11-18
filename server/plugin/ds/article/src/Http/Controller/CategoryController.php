<?php

declare(strict_types=1);

namespace Plugin\Ds\Article\Http\Controller;

use App\Http\Admin\Permission;
use App\Common\Middleware\AccessTokenMiddleware;
use App\Common\Middleware\OperationMiddleware;
use App\Common\Result;
use App\Common\Swagger\ResultResponse;
use App\Http\Admin\Controller\AbstractController;
use App\Http\Admin\Middleware\PermissionMiddleware;
use App\Http\CurrentUser;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\Swagger\Annotation as OA;
use Hyperf\Swagger\Annotation\Delete;
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\Post;
use Hyperf\Swagger\Annotation\Put;
use Plugin\Ds\Article\Http\Request\CategoryRequest as Request;
use Plugin\Ds\Article\Service\CategoryService as Service;


#[OA\Tag('分类')]
#[OA\HyperfServer('http')]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
#[Middleware(middleware: OperationMiddleware::class, priority: 98)]
class CategoryController extends AbstractController
{
    public function __construct(
        private readonly Service $service,
        private readonly CurrentUser $currentUser
    ) {}

    #[Get(
        path: '/admin/article/category/list',
        operationId: 'article:category:list',
        summary: '分类列表',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['分类'],
    )]
    #[Permission(code: 'article:category:list')]
    #[ResultResponse(instance: new Result())]
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
    #[Get(
        path: '/admin/article/category/selectCategory',
        operationId: 'article:category:list',
        summary: '分类选择',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['分类'],
    )]
    #[Permission(code: 'article:category:selectCategory')]
    #[ResultResponse(instance: new Result())]
    public function selectCategory(Request $request): Result
    {
        return $this->success($this->service->selectCategory($request->all()));
    }

    #[Post(
        path: '/admin/article/category/create',
        operationId: 'article:category:create',
        summary: '分类新增',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['分类'],
    )]
    #[Permission(code: 'article:category:create')]
    #[ResultResponse(instance: new Result())]
    public function create(Request $request): Result
    {
        $this->service->create(array_merge($request->all(), [
            'created_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[Put(
        path: '/admin/article/category/save/{id}',
        operationId: 'article:category:save',
        summary: '分类保存',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['分类'],
    )]
    #[Permission(code: 'article:category:save')]
    #[ResultResponse(instance: new Result())]
    public function save(int $id, Request $request): Result
    {
        $this->service->updateById($id, array_merge($request->all(), [
            'updated_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[Delete(
        path: '/admin/article/category/delete',
        operationId: 'article:category:delete',
        summary: '分类删除',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['分类'],
    )]
    #[ResultResponse(instance: new Result())]
    #[Permission(code: 'article:category:delete')]
    public function delete(): Result
    {
        $this->service->deleteById($this->getRequestData());
        return $this->success();
    }

}
