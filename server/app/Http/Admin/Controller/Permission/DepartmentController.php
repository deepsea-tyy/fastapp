<?php

declare(strict_types=1);


namespace App\Http\Admin\Controller\Permission;

use App\Common\Middleware\AccessTokenMiddleware;
use App\Common\Middleware\OperationMiddleware;
use App\Common\Result;
use App\Common\Swagger\PageResponse;
use App\Common\Swagger\ResultResponse;
use App\Http\Admin\Controller\AbstractController;
use App\Http\Admin\Middleware\PermissionMiddleware;
use App\Http\Admin\Permission;
use App\Http\Admin\Request\Permission\DepartmentRequest;
use App\Http\Admin\Service\Permission\DepartmentService;
use App\Http\CurrentUser;
use App\Schema\DepartmentSchema;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\Swagger\Annotation\Delete;
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\HyperfServer;
use Hyperf\Swagger\Annotation\JsonContent;
use Hyperf\Swagger\Annotation\Post;
use Hyperf\Swagger\Annotation\Put;
use Hyperf\Swagger\Annotation\RequestBody;

#[HyperfServer(name: 'http')]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
#[Middleware(middleware: OperationMiddleware::class, priority: 98)]
final class DepartmentController extends AbstractController
{
    public function __construct(
        private readonly DepartmentService $service,
        private readonly CurrentUser $currentUser
    ) {}

    #[Get(
        path: '/admin/department/list',
        operationId: 'departmentList',
        summary: '部门列表',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['部门管理'],
    )]
    #[PageResponse(instance: DepartmentSchema::class)]
    #[Permission(code: 'permission:department:index')]
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
        path: '/admin/department/selectDept',
        operationId: 'departmentSelectDept',
        summary: '部门选择',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['部门管理'],
    )]
    #[ResultResponse(
        instance: new Result(),
        example: '{"code":200,"message":"成功","data":[]}'
    )]
    #[Permission(code: 'permission:department:index')]
    public function selectDept(): Result
    {
        return $this->success(data: $this->service->selectDept());
    }

    #[Post(
        path: '/admin/department',
        operationId: 'departmentCreate',
        summary: '创建部门',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['部门管理'],
    )]
    #[RequestBody(
        content: new JsonContent(ref: DepartmentRequest::class)
    )]
    #[Permission(code: 'permission:department:save')]
    #[ResultResponse(instance: new Result())]
    public function create(DepartmentRequest $request): Result
    {
        $this->service->create(array_merge($request->validated(), [
            'created_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[Put(
        path: '/admin/department/{id}',
        operationId: 'departmentSave',
        summary: '保存部门',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['部门管理'],
    )]
    #[RequestBody(
        content: new JsonContent(ref: DepartmentRequest::class)
    )]
    #[Permission(code: 'permission:department:update')]
    #[ResultResponse(instance: new Result())]
    public function save(int $id, DepartmentRequest $request): Result
    {
        $this->service->updateById($id, array_merge($request->validated(), [
            'updated_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[Delete(
        path: '/admin/department',
        operationId: 'departmentDelete',
        summary: '删除部门',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['部门管理'],
    )]
    #[ResultResponse(instance: new Result())]
    #[Permission(code: 'permission:department:delete')]
    public function delete(): Result
    {
        $this->service->deleteById($this->getRequestData());
        return $this->success();
    }
}
