<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Http\Api\Service;

class AppPageContentService
{
    /**
     * 获取固定文件路径（app-init格式）
     */
    public function getFixedFilePath(int $platform): string
    {
        $platformSuffix = $platform === 1 ? 'web' : 'app';
        return "storage/app/page-content/app-init-{$platformSuffix}.json";
    }
}

