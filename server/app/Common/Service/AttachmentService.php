<?php

declare(strict_types=1);

namespace App\Common\Service;

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

    public function uploadChunk(string $hash, int $chunkIndex, UploadedFileInterface $chunkFile, int $userId): Attachment|array
    {
        if ($attachment = $this->repository->findByHash($hash)) {
            return $attachment;
        }

        $this->storage->putChunk($hash, $chunkIndex, $chunkFile);

        return ['chunk_index' => $chunkIndex];
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

    public function attachLocal(
        string $absolutePath,
        int $userId,
        ?string $originName = null,
        ?string $objectName = null,
        bool $move = false,
        string $assetType = null,
        ?int $parentId = null,
        ?int $source = null,
    ): Attachment {
        $path = realpath($absolutePath) ?: $absolutePath;
        $hash = md5_file($path) ?: '';
        $parent = $parentId ? $this->findById($parentId) : null;
        $source = $source ?? ($parent ? (int) ($parent->source ?? 0) : 0);
        $existing = $this->findExistingByHash($hash);
        if ($existing) {
            $this->unlinkStagingIfDifferent($path, $existing);
            $patch = [];
            if ($assetType && !$existing->asset_type) {
                $patch['asset_type'] = $assetType;
            }
            if ($parentId && !$existing->parent_id) {
                $patch['parent_id'] = $parentId;
            }
            if ($patch) {
                $this->repository->updateById($existing->id, $patch);
                return $this->findById($existing->id);
            }

            return $existing;
        }

        try {
            $stored = $this->storage->putLocal($path, $objectName, $move);

            return $this->repository->create(array_merge($stored->toArray(), [
                'created_by' => $userId,
                'updated_by' => $userId,
                'origin_name' => $originName ?: basename($path),
                'normalized' => 1,
                'source' => $source,
                'asset_type' => $assetType,
                'parent_id' => $parentId,
            ]));
        } catch (\Throwable $e) {
            $existing = $this->findExistingByHash($hash);
            if ($existing) {
                $this->unlinkStagingIfDifferent($path, $existing);

                return $existing;
            }

            throw $e;
        }
    }

    public function stagingPath(string $prefix, string $ext): string
    {
        return $this->storage->stagingPath($prefix, $ext);
    }

    public function getRepository(): AttachmentRepository
    {
        return $this->repository;
    }

    public function deleteById(mixed $id, array $where = []): int
    {
        $md = $this->findById($id);
        if ($s = parent::deleteById($id)) {
            @unlink(Tools::storage_path($md->url));
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

    public function replaceInPlace(Attachment $att, string $absolutePath, int $userId, bool $move = false, string $assetType = null, ?int $source = null): Attachment
    {
        $srcPath = realpath($absolutePath) ?: $absolutePath;
        $target = $att->absoluteStoragePath();
        $targetDir = dirname($target);
        if (!is_dir($targetDir)) {
            mkdir($targetDir, 0755, true);
        }
        if ($srcPath != $target) {
            $ok = $move ? rename($srcPath, $target) : copy($srcPath, $target);
            if (! $ok) {
                throw new \RuntimeException('ATTACHMENT_REPLACE_FAILED');
            }
        }
        $sizeByte = filesize($target) ?: 0;
        $suffix = pathinfo($target, PATHINFO_EXTENSION) ?: $att->suffix;
        $mimeType = mime_content_type($target) ?: $att->mime_type;
        $update = [
            'hash' => md5_file($target) ?: $att->hash,
            'size_byte' => $sizeByte,
            'size_info' => StoredFile::formatSizeByte($sizeByte),
            'suffix' => $suffix,
            'mime_type' => $mimeType,
            'normalized' => 1,
            'updated_by' => $userId,
        ];
        if ($assetType && !$att->asset_type) {
            $update['asset_type'] = $assetType;
        }
        if ($source !== null) {
            $update['source'] = $source;
        }
        $this->repository->updateById($att->id, $update);

        return $this->findById($att->id);
    }

    private function findExistingByHash(string $hash): ?Attachment
    {
        if (!$hash) {
            return null;
        }
        $existing = $this->repository->findByHash($hash);
        if (!$existing) {
            return null;
        }
        if (!is_file($existing->absoluteStoragePath())) {
            return null;
        }

        return $existing;
    }

    private function unlinkStagingIfDifferent(string $stagingPath, Attachment $existing): void
    {
        $storedPath = $existing->absoluteStoragePath();
        $normStaging = str_replace('\\', '/', realpath($stagingPath) ?: $stagingPath);
        $normStored = str_replace('\\', '/', realpath($storedPath) ?: $storedPath);
        if ($normStaging != $normStored) {
            @unlink($stagingPath);
        }
    }
}
