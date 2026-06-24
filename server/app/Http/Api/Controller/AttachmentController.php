<?php

declare(strict_types=1);

namespace App\Http\Api\Controller;

use App\Common\AbstractController;
use App\Common\Middleware\TokenMiddleware;
use App\Common\Result;
use App\Common\Swagger\PageResponse;
use App\Common\Swagger\ResultResponse;
use App\Http\Admin\Service\AttachmentService;
use App\Http\Common\Request\UploadRequest;
use App\Http\Common\Traits\AttachmentControllerTrait;
use App\Http\CurrentUser;
use App\Schema\AttachmentSchema;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\Swagger\Annotation\Delete;
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\HyperfServer;
use Hyperf\Swagger\Annotation\Post;
use Hyperf\Swagger\Annotation\Put;

#[HyperfServer(name: 'http')]
#[Middleware(middleware: TokenMiddleware::class)]
class AttachmentController extends AbstractController
{
    use AttachmentControllerTrait;

    public function __construct(
        protected readonly AttachmentService $service,
        protected readonly CurrentUser $currentUser
    ) {}

    #[Get(
        path: '/api/attachment/list',
        operationId: 'ApiAttachmentList',
        summary: '附件列表',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['文件管理'],
    )]
    #[PageResponse(instance: AttachmentSchema::class)]
    public function list(): Result
    {
        return $this->handleList();
    }

    #[Post(
        path: '/api/attachment/upload',
        operationId: 'ApiUploadAttachment',
        summary: '上传附件',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['文件管理'],
    )]
    #[ResultResponse(instance: new Result())]
    public function upload(UploadRequest $request): Result
    {
        return $this->handleUpload($request);
    }

    #[Delete(
        path: '/api/attachment/{id}',
        operationId: 'ApiDeleteAttachment',
        summary: '删除附件',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['文件管理'],
    )]
    #[ResultResponse(instance: new Result())]
    public function delete(int $id): Result
    {
        return $this->handleDelete($id);
    }

    #[Put(
        path: '/api/attachment/{id}',
        operationId: 'ApiUpdateAttachment',
        summary: '更新附件',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['文件管理'],
    )]
    #[ResultResponse(instance: new Result())]
    public function update(int $id): Result
    {
        return $this->handleUpdate($id);
    }

    #[Post(
        path: '/api/attachment/chunk-upload',
        operationId: 'ApiUploadChunkAttachment',
        summary: '分片上传附件',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['文件管理'],
    )]
    #[ResultResponse(instance: new Result())]
    public function uploadChunk(UploadRequest $request): Result
    {
        return $this->handleUploadChunk($request);
    }

    #[Post(
        path: '/api/attachment/chunk-merge',
        operationId: 'ApiMergeChunkAttachment',
        summary: '分片合并',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['文件管理'],
    )]
    #[ResultResponse(instance: new Result())]
    public function mergeChunk(UploadRequest $request): Result
    {
        return $this->handleMergeChunk($request);
    }
}
