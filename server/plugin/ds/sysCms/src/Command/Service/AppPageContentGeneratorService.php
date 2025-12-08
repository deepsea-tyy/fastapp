<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Command\Service;

use App\Exception\BusinessException;
use Plugin\Ds\SysCms\Repository\AppPageContentRepository;
use Plugin\Ds\SysCms\Repository\AppPageContentSyncRepository;
use Plugin\Ds\SysCms\Model\AppPageContentSync;
use Carbon\Carbon;

class AppPageContentGeneratorService
{
    private const PLATFORM_WEB = 1;
    private const PLATFORM_APP = 2;
    private const STORAGE_DIR = '/storage/app/page-content';

    public function __construct(
        protected readonly AppPageContentRepository $contentRepository,
        protected readonly AppPageContentSyncRepository $syncRepository
    ) {
    }

    /**
     * 生成文件（统一使用JSON格式，App和Web都生成JSON）
     */
    public function generate(): array
    {
        $results = [];
        // 统一生成一个版本号，确保同一批次生成的文件版本一致
        $version = (string)time();
        
        // 检查是否有App平台的数据（platform=2或3）
        $appContents = $this->contentRepository->getEnabledContents(self::PLATFORM_APP);
        if (!$appContents->isEmpty()) {
            // 生成App的JSON文件（统一使用JSON格式）
            $results[] = $this->generateJSON(self::PLATFORM_APP, $appContents, $version);
        }
        
        // 检查是否有Web平台的数据（platform=1或3）
        $webContents = $this->contentRepository->getEnabledContents(self::PLATFORM_WEB);
        if (!$webContents->isEmpty()) {
            // 生成Web的JSON文件
            $results[] = $this->generateJSON(self::PLATFORM_WEB, $webContents, $version);
        }

        if (empty($results)) {
            throw new BusinessException(message: '没有可用的页面内容数据，请先添加并启用页面内容后再生成文件');
        }

        return $results;
    }

    /**
     * 生成JSON文件（以code为key的扁平字典结构，App和Web统一使用）
     */
    private function generateJSON(int $platform, $contents, string $version): array
    {
        $platformSuffix = $platform === self::PLATFORM_WEB ? 'web' : 'app';
        $filePath = $this->getFilePath($version, $platformSuffix, 'json');

        $data = [];
        foreach ($contents as $content) {
            // 以code为key，直接访问，O(1)时间复杂度
            $data[$content->code] = $this->formatContentForJson($content);
        }

        file_put_contents($filePath, json_encode($data, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT));

        return $this->saveFileRecord($version, $platform, $filePath, $contents->count());
    }

    /**
     * 获取文件路径
     */
    private function getFilePath(string $version, string $platformSuffix, string $ext): string
    {
        $storageDir = BASE_PATH . self::STORAGE_DIR;
        if (!is_dir($storageDir)) {
            mkdir($storageDir, 0755, true);
        }
        return $storageDir . "/app-page-content-v{$version}-{$platformSuffix}.{$ext}";
    }

    /**
     * 格式化内容用于JSON输出
     */
    private function formatContentForJson($content): array
    {
        return [
            'code' => $content->code,
            'page_code' => $content->page_code,
            'component_code' => $content->component_code,
            'content_type' => $content->content_type,
            'data' => $content->data,
            'platform' => $content->platform,
            'start_at' => $content->start_at,
            'end_at' => $content->end_at,
            'fixed' => $content->fixed,
            'sort' => $content->sort,
            'remark' => $content->remark,
        ];
    }

    /**
     * 保存文件记录并返回结果（统一使用JSON格式）
     */
    private function saveFileRecord(string $version, int $platform, string $filePath, int $recordCount): array
    {
        $fileSize = filesize($filePath);
        $relativePath = str_replace(BASE_PATH . '/', '', $filePath);

        AppPageContentSync::create([
            'version' => $version,
            'platform' => $platform,
            'file_path' => $relativePath,
            'file_size' => $fileSize,
            'record_count' => $recordCount,
            'generated_at' => Carbon::now(),
        ]);

        return [
            'platform' => $platform,
            'version' => $version,
            'file_path' => $filePath,
            'file_size' => $fileSize,
            'record_count' => $recordCount,
        ];
    }
}

