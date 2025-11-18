<?php
/**
 * FastApp.
 * 10/19/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Common\Upload;

final class Upload
{
    public function __construct(
        private readonly string $storageMode,
        private readonly string $objectName,
        private readonly string $mimeType,
        private readonly string $storagePath,
        private readonly string $hash,
        private readonly string $suffix,
        private readonly int $size,
        private readonly string $url
    ) {}

    public function getStorageMode(): string
    {
        return $this->storageMode;
    }

    public function getObjectName(): string
    {
        return $this->objectName;
    }

    public function getMimeType(): string
    {
        return $this->mimeType;
    }

    public function getStoragePath(): string
    {
        return $this->storagePath;
    }

    public function getHash(): string
    {
        return $this->hash;
    }

    public function getSuffix(): string
    {
        return $this->suffix;
    }

    public function getSize(): int
    {
        return $this->size;
    }

    public function getSizeByte(): int
    {
        return $this->size;
    }

    public function getSizeInfo(): int
    {
        return $this->size;
    }

    public function getUrl(): string
    {
        return $this->url;
    }

    public function toArray(): array
    {
        return [
            'storage_mode' => $this->storageMode,
            'object_name' => $this->objectName,
            'mime_type' => $this->mimeType,
            'storage_path' => $this->storagePath,
            'hash' => $this->hash,
            'suffix' => $this->suffix,
            'size_byte' => $this->size,
            'size_info' => $this->size,
            'url' => $this->url,
        ];
    }
}