<?php

declare(strict_types=1);

namespace App\Common\Upload;

final class StoredFile
{
    public function __construct(
        public readonly string $storageMode,
        public readonly string $objectName,
        public readonly string $mimeType,
        public readonly string $storagePath,
        public readonly string $hash,
        public readonly string $suffix,
        public readonly int $sizeByte,
        public readonly string $url,
    ) {}

    public function sizeInfo(): string
    {
        return self::formatSizeByte($this->sizeByte);
    }

    public static function formatSizeByte(int $size): string
    {
        $gb = 1024 ** 3;
        $mb = 1024 ** 2;
        $kb = 1024;

        return match (true) {
            $size >= $gb => round($size / $gb, 2) . 'G',
            $size >= $mb => round($size / $mb, 2) . 'M',
            default => round($size / $kb, 2) . 'K',
        };
    }

    public function publicUrl(): string
    {
        return $this->storageMode === 'local'
            ? parse_url($this->url, PHP_URL_PATH)
            : $this->url;
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
            'size_byte' => $this->sizeByte,
            'size_info' => $this->sizeInfo(),
            'url' => $this->publicUrl(),
        ];
    }
}
