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
use Plugin\Ds\Article\Http\Request\ArticleRequest as Request;
use Plugin\Ds\Article\Service\ArticleService as Service;


#[OA\Tag('文章')]
#[OA\HyperfServer('http')]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
#[Middleware(middleware: OperationMiddleware::class, priority: 98)]
class ArticleController extends AbstractController
{
    public function __construct(
        private readonly Service $service,
        private readonly CurrentUser $currentUser
    ) {}

    #[Get(
        path: '/admin/article/article/list',
        operationId: 'article:article:list',
        summary: '文章列表',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['文章'],
    )]
    #[Permission(code: 'article:article:list')]
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

    #[Post(
        path: '/admin/article/article/create',
        operationId: 'article:article:create',
        summary: '文章新增',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['文章'],
    )]
    #[Permission(code: 'article:article:create')]
    #[ResultResponse(instance: new Result())]
    public function create(Request $request): Result
    {
        $this->service->create(array_merge($request->all(), [
            'created_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[Put(
        path: '/admin/article/article/save/{id}',
        operationId: 'article:article:save',
        summary: '文章保存',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['文章'],
    )]
    #[Permission(code: 'article:article:save')]
    #[ResultResponse(instance: new Result())]
    public function save(int $id, Request $request): Result
    {
        $this->service->updateById($id, array_merge($request->all(), [
            'updated_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[Delete(
        path: '/admin/article/article/delete',
        operationId: 'article:article:delete',
        summary: '文章删除',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['文章'],
    )]
    #[ResultResponse(instance: new Result())]
    #[Permission(code: 'article:article:delete')]
    public function delete(): Result
    {
        $this->service->deleteById($this->getRequestData());
        return $this->success();
    }

}
