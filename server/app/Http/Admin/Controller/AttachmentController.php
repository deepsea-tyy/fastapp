<?php

declare(strict_types=1);


namespace App\Http\Admin\Controller;

use App\Common\Middleware\AccessTokenMiddleware;
use App\Common\Middleware\OperationMiddleware;
use App\Http\Admin\Middleware\PermissionMiddleware;
use App\Http\Admin\Permission;
use App\Http\Admin\Request\ChunkMergeRequest;
use App\Http\Admin\Request\ChunkUploadRequest;
use App\Http\Admin\Request\UploadRequest;
use App\Http\Admin\Service\AttachmentService;
use App\Http\Common\Traits\AttachmentControllerTrait;
use App\Http\CurrentUser;
use App\Common\Result;
use App\Common\Swagger\PageResponse;
use App\Common\Swagger\ResultResponse;
use App\Schema\AttachmentSchema;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\Swagger\Annotation\Delete;
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\Post;
use Hyperf\Swagger\Annotation\HyperfServer;

#[HyperfServer(name: 'http')]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
#[Middleware(middleware: OperationMiddleware::class, priority: 98)]
class AttachmentController extends AbstractController
{
    use AttachmentControllerTrait;

    public function __construct(
        protected readonly AttachmentService $service,
        protected readonly CurrentUser $currentUser
    ) {}

    #[Get(
        path: '/attachment/list',
        operationId: 'AttachmentList',
        summary: '附件列表',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['数据中心'],
    )]
    #[Permission(code: 'dataCenter:attachment:list')]
    #[PageResponse(instance: AttachmentSchema::class)]
    public function list(): Result
    {
        return $this->handleList();
    }

    #[Post(
        path: '/attachment/upload',
        operationId: 'UploadAttachment',
        summary: '上传附件',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['数据中心'],
    )]
    #[Permission(code: 'dataCenter:attachment:upload')]
    #[ResultResponse(instance: new Result())]
    public function upload(UploadRequest $request): Result
    {
        return $this->handleUpload($request);
    }

    #[Delete(
        path: '/attachment/{id}',
        operationId: 'DeleteAttachment',
    )]
    #[Permission(code: 'dataCenter:attachment:delete')]
    #[ResultResponse(instance: new Result())]
    public function delete(int $id): Result
    {
        return $this->handleDelete($id);
    }

    #[Post(
        path: '/attachment/chunk-upload',
        operationId: 'UploadChunkAttachment',
        summary: '分片上传附件',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['数据中心'],
    )]
    #[Permission(code: 'dataCenter:attachment:upload')]
    #[ResultResponse(instance: new Result())]
    public function uploadChunk(ChunkUploadRequest $request): Result
    {
        return $this->handleUploadChunk($request);
    }

    #[Post(
        path: '/attachment/chunk-merge',
        operationId: 'MergeChunkAttachment',
        summary: '分片合并',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['数据中心'],
    )]
    #[Permission(code: 'dataCenter:attachment:upload')]
    #[ResultResponse(instance: new Result())]
    public function mergeChunk(ChunkMergeRequest $request): Result
    {
        return $this->handleMergeChunk($request);
    }
}
