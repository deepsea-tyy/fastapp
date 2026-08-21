<?php

declare(strict_types=1);

namespace App\Http\Admin\Service;

use App\Common\IService;
use App\Common\Tools;
use App\Common\Upload\FileStorage;
use App\Common\Upload\StoredFile;
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
        protected readonly FileStorage $storage,
    ) {}

    public function upload(UploadedFileInterface $uploadedFile, int $userId): Attachment
    {
        $fileHash = md5_file($uploadedFile->getRealPath());
        if ($attachment = $this->repository->findByHash($fileHash)) {
            return $attachment;
        }
        return $this->createFromStoredFile(
            $this->storage->putUploaded($uploadedFile, $fileHash),
            $userId,
            (string) $uploadedFile->getClientFilename(),
        );
    }

    public function getRepository(): AttachmentRepository
    {
        return $this->repository;
    }

    public function uploadChunk(string $hash, int $chunkIndex, UploadedFileInterface $chunkFile): bool
    {
        $this->storage->putChunk($hash, $chunkIndex, $chunkFile);
        return true;
    }

    public function checkFileExists(string $hash): ?Attachment
    {
        return $this->repository->findByHash($hash);
    }

    public function mergeChunks(string $hash, string $filename, int $totalChunks, int $userId): Attachment
    {
        if ($attachment = $this->repository->findByHash($hash)) {
            return $attachment;
        }
        return $this->createFromStoredFile(
            $this->storage->mergeChunks($hash, $filename, $totalChunks),
            $userId,
            $filename,
        );
    }

    public function deleteById(mixed $id, array $where = []): int
    {
        $md = $this->findById($id);
        if ($s = parent::deleteById($id)) {
            try {
                unlink(Tools::storage_path($md->url));
            } catch (\RuntimeException) {
            }
        }
        return $s;
    }

    private function createFromStoredFile(StoredFile $file, int $userId, string $originName): Attachment
    {
        return $this->repository->create(array_merge($file->toArray(), [
            'created_by' => $userId,
            'origin_name' => $originName,
            'source' => 1,
        ]));
    }
}
