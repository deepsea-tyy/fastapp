<?php

declare(strict_types=1);

namespace App\Http\Api\Controller;

use App\Common\AbstractController;
use App\Common\Middleware\TokenMiddleware;
use App\Common\Result;
use App\Http\Admin\Service\AttachmentService;
use App\Http\Common\Request\UploadRequest;
use App\Http\Common\Traits\AttachmentControllerTrait;
use App\Http\CurrentUser;
use Hyperf\HttpServer\Annotation\Controller;
use Hyperf\HttpServer\Annotation\DeleteMapping;
use Hyperf\HttpServer\Annotation\GetMapping;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\HttpServer\Annotation\PostMapping;
use Hyperf\HttpServer\Annotation\PutMapping;

#[Controller]
#[Middleware(middleware: TokenMiddleware::class)]
class AttachmentController extends AbstractController
{
    use AttachmentControllerTrait;

    public function __construct(
        protected readonly AttachmentService $service,
        protected readonly CurrentUser $currentUser
    ) {}

    #[GetMapping(path: '/api/attachment/list')]
    public function list(): Result
    {
        return $this->handleList();
    }

    #[PostMapping(path: '/api/attachment/upload')]
    public function upload(UploadRequest $request): Result
    {
        return $this->handleUpload($request);
    }

    #[DeleteMapping(path: '/api/attachment/{id}')]
    public function delete(int $id): Result
    {
        return $this->handleDelete($id);
    }

    #[PutMapping(path: '/api/attachment/{id}')]
    public function update(int $id): Result
    {
        return $this->handleUpdate($id);
    }

    #[PostMapping(path: '/api/attachment/chunk-upload')]
    public function uploadChunk(UploadRequest $request): Result
    {
        return $this->handleUploadChunk($request);
    }

    #[PostMapping(path: '/api/attachment/chunk-merge')]
    public function mergeChunk(UploadRequest $request): Result
    {
        return $this->handleMergeChunk($request);
    }
}
