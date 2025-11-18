<?php

declare(strict_types=1);


namespace App\Http\Admin\Service;

use App\Common\IService;
use App\Common\Upload\UploadFactory;
use App\Model\Attachment;
use App\Repository\AttachmentRepository;
use Psr\Http\Message\UploadedFileInterface;

/**
 * @extends IService<Attachment>
 */
final class AttachmentService extends IService
{
    public function __construct(
        protected readonly AttachmentRepository $repository,
        protected readonly UploadFactory        $upload
    )
    {
    }

    public function upload(UploadedFileInterface $uploadedFile, int $userId): Attachment
    {
        $fileHash = md5_file($uploadedFile->getRealPath());
        if ($attachment = $this->repository->findByHash($fileHash)) {
            return $attachment;
        }
        $upload = $this->upload->upload($uploadedFile);
        $url = parse_url($upload->getUrl(), PHP_URL_PATH);
        return $this->repository->create(array_merge($upload->toArray(), [
            'created_by' => $userId,
            'origin_name' => $uploadedFile->getClientFilename(),
            'storage_path' => $url,
            'url' => $url,
        ]));
    }

    public function getRepository(): AttachmentRepository
    {
        return $this->repository;
    }

    public function uploadChunk(string $hash, int $chunkIndex, UploadedFileInterface $chunkFile): bool
    {
        return $this->upload->uploadChunk($hash, $chunkIndex, $chunkFile);
    }

    public function checkFileExists(string $hash): ?Attachment
    {
        return $this->repository->findByHash($hash);
    }

    public function mergeChunks(string $hash, string $filename, int $totalChunks, int $userId): Attachment
    {
        $upload = $this->upload->mergeChunks($hash, $filename, $totalChunks);
        $url = parse_url($upload->getUrl(), PHP_URL_PATH);
        return $this->repository->create(array_merge($upload->toArray(), [
            'created_by' => $userId,
            'origin_name' => $filename,
            'storage_path' => $url,
            'url' => $url,
        ]));
    }

    public function deleteById(mixed $id, array $where = []): int
    {
        $md = $this->findById($id);
        if ($s = parent::deleteById($id)) {
            @unlink(BASE_PATH . '/storage' . $md->url);
        }
        return $s;
    }
}
