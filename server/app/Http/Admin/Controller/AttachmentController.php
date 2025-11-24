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
use Hyperf\HttpServer\Annotation\Controller;
use Hyperf\HttpServer\Annotation\DeleteMapping;
use Hyperf\HttpServer\Annotation\GetMapping;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\HttpServer\Annotation\PostMapping;
#[Controller]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
class AttachmentController extends AbstractController
{
    use AttachmentControllerTrait;

    public function __construct(
        protected readonly AttachmentService $service,
        protected readonly CurrentUser $currentUser
    ) {}

    #[GetMapping(path: '/attachment/list')]
    #[Permission(code: 'dataCenter:attachment:list')]
    public function list(): Result
    {
        return $this->handleList();
    }

    #[PostMapping(path: '/attachment/upload')]
    #[Permission(code: 'dataCenter:attachment:upload')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function upload(UploadRequest $request): Result
    {
        return $this->handleUpload($request);
    }

    #[DeleteMapping(path: '/attachment/{id}')]
    #[Permission(code: 'dataCenter:attachment:delete')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function delete(int $id): Result
    {
        return $this->handleDelete($id);
    }

    #[PostMapping(path: '/attachment/chunk-upload')]
    #[Permission(code: 'dataCenter:attachment:upload')]
    public function uploadChunk(ChunkUploadRequest $request): Result
    {
        return $this->handleUploadChunk($request);
    }

    #[PostMapping(path: '/attachment/chunk-merge')]
    #[Permission(code: 'dataCenter:attachment:upload')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function mergeChunk(ChunkMergeRequest $request): Result
    {
        return $this->handleMergeChunk($request);
    }
}
