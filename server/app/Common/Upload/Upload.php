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
        private readonly int    $size,
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

    public function getSizeByte(): int
    {
        return $this->size;
    }

    public function getSizeInfo(): string
    {
        $size = $this->size;
        $gb = 1024 ** 3;
        $mb = 1024 ** 2;
        $kb = 1024;

        return match (true) {
            $size >= $gb => round($size / $gb, 2) . 'G',
            $size >= $mb => round($size / $mb, 2) . 'M',
            default => round($size / $kb, 2) . 'K',
        };
    }

    public function getUrl(): string
    {
        return $this->storageMode === 'local' 
            ? parse_url($this->url, PHP_URL_PATH) 
            : $this->url;
    }

    public function toArray(): array
    {
        return [
            'storage_mode' => $this->getStorageMode(),
            'object_name' => $this->getObjectName(),
            'mime_type' => $this->getMimeType(),
            'storage_path' => $this->getStoragePath(),
            'hash' => $this->getHash(),
            'suffix' => $this->getSuffix(),
            'size_byte' => $this->getSizeByte(),
            'size_info' => $this->getSizeInfo(),
            'url' => $this->getUrl(),
        ];
    }
}