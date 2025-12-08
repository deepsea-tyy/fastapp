<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Http\Api\Service;

use Plugin\Ds\SysCms\Repository\AppPageContentSyncRepository;
use Plugin\Ds\SysCms\Model\AppPageContentSync;

class AppPageContentService
{
    public function __construct(
        protected readonly AppPageContentSyncRepository $syncRepository
    )
    {
    }

    /**
     * 获取最新版本号（统一使用JSON格式）
     */
    public function getLatestVersion(int $platform): ?array
    {
        $sync = $this->syncRepository->getLatestVersion($platform);
        
        return $sync ? [
            'version' => $sync->version,
            'file_path' => $sync->file_path,
            'file_size' => $sync->file_size,
            'record_count' => $sync->record_count,
            'generated_at' => $sync->generated_at?->toDateTimeString(),
        ] : null;
    }

    /**
     * 获取文件路径（统一使用JSON格式）
     */
    public function getFilePath(string $version, int $platform): ?string
    {
        return AppPageContentSync::query()
            ->where('version', $version)
            ->where('platform', $platform)
            ->value('file_path');
    }
}

