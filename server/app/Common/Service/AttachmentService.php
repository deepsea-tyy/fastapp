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
        ?array $imageWh = null,
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
            if ($imageWh) {
                $patch['image_wh'] = $imageWh;
            }
            if ($patch) {
                $this->repository->updateById($existing->id, $patch);
                return $this->findById($existing->id);
            }

            return $existing;
        }

        try {
            $stored = $this->storage->putLocal($path, $objectName, $move);

            $row = array_merge($stored->toArray(), [
                'created_by' => $userId,
                'updated_by' => $userId,
                'origin_name' => $originName ?: basename($path),
                'source' => $source,
                'asset_type' => $assetType,
                'parent_id' => $parentId,
            ]);
            if ($imageWh) {
                $row['image_wh'] = $imageWh;
            }

            return $this->repository->create($row);
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

    public function findByAssetTypeAndObjectName(string $assetType, string $objectName): ?Attachment
    {
        $att = $this->repository->findByObjectName($objectName);
        if (!$att || $att->asset_type != $assetType) {
            return null;
        }

        return $att;
    }

    public function deleteByAssetTypeAndObjectName(string $assetType, string $objectName): int
    {
        $att = $this->findByAssetTypeAndObjectName($assetType, $objectName);
        if (!$att) {
            return 0;
        }

        return $this->deleteById($att->id);
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

    public function replaceInPlace(Attachment $att, string $absolutePath, int $userId, bool $move = false, string $assetType = null, ?int $source = null, ?array $imageWh = null): Attachment
    {
        $srcPath = realpath($absolutePath) ?: $absolutePath;
        $oldPath = $att->absoluteStoragePath();
        $srcSuffix = strtolower(pathinfo($srcPath, PATHINFO_EXTENSION) ?: '');
        $oldSuffix = strtolower(pathinfo($oldPath, PATHINFO_EXTENSION) ?: $att->suffix ?: '');

        $target = $oldPath;
        $objectName = $att->object_name;
        $url = $att->url;
        if ($srcSuffix && $srcSuffix != $oldSuffix) {
            $target = preg_replace('/\.[^.]+$/', '.' . $srcSuffix, $oldPath) ?: ($oldPath . '.' . $srcSuffix);
            $objectName = preg_replace('/\.[^.]+$/', '.' . $srcSuffix, $objectName ?: basename($oldPath));
            $url = preg_replace('/\.[^.]+$/', '.' . $srcSuffix, $url ?: '');
        }

        $targetDir = dirname($target);
        if (!is_dir($targetDir)) {
            mkdir($targetDir, 0755, true);
        }
        if ($srcPath != $target) {
            $ok = $move ? rename($srcPath, $target) : copy($srcPath, $target);
            if (!$ok) {
                throw new \RuntimeException('ATTACHMENT_REPLACE_FAILED');
            }
            if (!$move && is_file($srcPath)) {
                @unlink($srcPath);
            }
        }
        if ($oldPath != $target && is_file($oldPath)) {
            @unlink($oldPath);
        }

        $sizeByte = filesize($target) ?: 0;
        $suffix = pathinfo($target, PATHINFO_EXTENSION) ?: $att->suffix;
        $mimeType = mime_content_type($target) ?: $att->mime_type;
        $update = [
            'hash' => md5_file($target) ?: $att->hash,
            'object_name' => $objectName ?: $att->object_name,
            'url' => $url ?: $att->url,
            'size_byte' => $sizeByte,
            'size_info' => StoredFile::formatSizeByte($sizeByte),
            'suffix' => $suffix,
            'mime_type' => $mimeType,
            'updated_by' => $userId,
        ];
        if ($imageWh) {
            $update['image_wh'] = $imageWh;
        }
        if ($assetType) {
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
