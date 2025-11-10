<?php

declare(strict_types=1);

namespace Plugin\Ds\Kefu\Http\Admin\Controller;

use App\Common\Middleware\AccessTokenMiddleware;
use App\Common\Middleware\OperationMiddleware;
use App\Common\Result;
use App\Common\Swagger\PageResponse;
use App\Http\Admin\Controller\AbstractController;
use App\Http\Admin\Middleware\PermissionMiddleware;
use App\Http\Admin\Permission;
use App\Http\CurrentUser;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\Swagger\Annotation\Delete;
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\HyperfServer;
use Hyperf\Swagger\Annotation\Post;
use Hyperf\Swagger\Annotation\Put;
use Plugin\Ds\Kefu\Schema\KefuSchema;
use Plugin\Ds\Kefu\Service\KefuService;

#[HyperfServer(name: 'http')]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
#[Middleware(middleware: OperationMiddleware::class, priority: 98)]
final class KefuController extends AbstractController
{
    public function __construct(
        private readonly KefuService $service,
        private readonly CurrentUser $currentUser
    )
    {
    }

    #[Get(
        path: '/admin/kefu/kefu/list',
        operationId: 'KefuKefuList',
        summary: '客服列表',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['客服管理'],
    )]
    #[Permission(code: 'kefu:kefu:index')]
    #[PageResponse(instance: KefuSchema::class)]
    public function pageList(): Result
    {
        return $this->success(
            $this->service->page(
                array_merge(['created_by' => $this->currentUser->id()], $this->getRequestData()),
                $this->getCurrentPage(),
                $this->getPageSize()
            )
        );
    }

    #[Post(
        path: '/admin/kefu/kefu/create',
        operationId: 'KefuKefuCreate',
        summary: '客服新增',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['客服管理'],
    )]
    #[Permission(code: 'kefu:kefu:save')]
    #[PageResponse(instance: new Result())]
    public function create(): Result
    {
        $this->service->create(array_merge($this->getRequestData(), [
            'created_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[Put(
        path: '/admin/kefu/kefu/save/{id}',
        operationId: 'KefuKefuSave',
        summary: '客服保存',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['客服管理'],
    )]
    #[Permission(code: 'kefu:kefu:update')]
    #[PageResponse(instance: new Result())]
    public function save(int $id): Result
    {
        $this->service->updateById($id, array_merge($this->getRequestData(), [
            'updated_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[Delete(
        path: '/admin/kefu/kefu/delete',
        operationId: 'KefuKefuDelete',
        summary: '客服删除',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['客服管理'],
    )]
    #[PageResponse(instance: new Result())]
    #[Permission(code: 'kefu:kefu:delete')]
    public function delete(): Result
    {
        $this->service->deleteById($this->getRequestData());
        return $this->success();
    }
}
