<?php

declare(strict_types=1);

namespace App\Http\Common\Traits;

use App\Common\Result;
use App\Http\Admin\Service\AttachmentService;
use App\Http\CurrentUser;
use Hyperf\Validation\Request\FormRequest;

trait AttachmentControllerTrait
{
    protected readonly AttachmentService $service;
    protected readonly CurrentUser $currentUser;

    /**
     * 附件列表
     */
    public function handleList(): Result
    {
        $params = $this->getRequest()->all();
        $params['current_user_id'] = $this->currentUser->id();
        if (isset($params['suffix'])) {
            $params['suffix'] = explode(',', $params['suffix']);
        }
        return $this->success(
            $this->service->page($params, $this->getCurrentPage(), $this->getPageSize())
        );
    }

    /**
     * 上传附件
     */
    public function handleUpload(FormRequest $request): Result
    {
        $uploadFile = $request->file('file');

        return $this->success(
            $this->service->upload($uploadFile, $this->currentUser->id())
        );
    }

    /**
     * 删除附件
     */
    public function handleDelete(int $id): Result
    {
        if (!$this->service->getRepository()->existsById($id)) {
            return $this->error(trans('attachment.attachment_not_exist'));
        }

        $attachment = $this->service->getRepository()->findById($id);
        if ($attachment && $attachment->created_by !== $this->currentUser->id()) {
            return $this->error('无权限删除此附件');
        }

        $this->service->deleteById($id);
        return $this->success();
    }

    /**
     * 分片上传附件
     */
    public function handleUploadChunk(FormRequest $request): Result
    {
        $hash = $request->post('file_md5');
        $chunkIndex = $request->post('chunk_index');

        // 检查文件是否已存在
        if ($existingAttachment = $this->service->checkFileExists($hash)) {
            $existingAttachment->file_exists = true;
            $existingAttachment->chunk_index = $chunkIndex;
            return $this->success($existingAttachment);
        }

        $uploadFile = $request->file('file');

        try {
            $this->service->uploadChunk($hash, (int)$chunkIndex, $uploadFile);
            return $this->success(['chunk_index' => $chunkIndex]);
        } catch (\Exception $e) {
            return $this->error('分片上传失败: ' . $e->getMessage());
        }
    }

    /**
     * 分片合并
     */
    private function handleMergeChunk(FormRequest $request): Result
    {
        $hash = $request->post('file_md5');
        $filename = $request->post('filename');
        $totalChunks = $request->post('total_chunks');

        if ($existingAttachment = $this->service->checkFileExists($hash)) {
            return $this->success($existingAttachment);
        }

        try {
            return $this->success($this->service->mergeChunks($hash, $filename, $totalChunks, $this->currentUser->id()));
        } catch (\Exception $e) {
            return $this->error('分片合并失败: ' . $e->getMessage());
        }
    }
}
