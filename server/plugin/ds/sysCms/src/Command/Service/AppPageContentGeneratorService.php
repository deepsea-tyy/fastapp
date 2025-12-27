<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Command\Service;

use App\Common\Tools;
use App\Exception\BusinessException;
use Plugin\Ds\SysCms\Repository\AppPageContentRepository;
use Plugin\Ds\SysCms\Model\AppPageContentSync;
use Carbon\Carbon;

class AppPageContentGeneratorService
{
    private const PLATFORM_WEB = 1;
    private const PLATFORM_APP = 2;
    private const STORAGE_DIR = '/storage/app/page-content';
    private const PLATFORMS = [
        self::PLATFORM_APP => 'app',
        self::PLATFORM_WEB => 'web',
    ];

    public function __construct(
        protected readonly AppPageContentRepository $contentRepository
    )
    {
    }

    /**
     * 生成文件（统一使用JSON格式，App和Web都生成JSON）
     */
    public function generate(): array
    {
        $version = (string)time();
        $results = [];

        foreach (self::PLATFORMS as $platform => $suffix) {
            $contents = $this->contentRepository->getEnabledContents($platform);
            if (!$contents->isEmpty()) {
                $results[] = $this->generateJSON($platform, $suffix, $contents, $version);
            }
        }

        if (empty($results)) {
            throw new BusinessException(message: '没有可用的页面内容数据，请先添加并启用页面内容后再生成文件');
        }

        return $results;
    }

    /**
     * 生成JSON文件（以code为key的扁平字典结构）
     */
    private function generateJSON(int $platform, string $suffix, $contents, string $version): array
    {
        $filePath = $this->getFilePath($suffix);

        // 构建数据字典
        $data = [];
        foreach ($contents as $content) {
            $data[$content->code] = [
                'data' => $content->data,
                'content_type' => $content->content_type,
            ];
        }

        // 写入文件：开发环境格式化，生产环境压缩
        $jsonFlags = JSON_UNESCAPED_UNICODE;
        if (\Hyperf\Config\config('env') !== 'prod') {
            $jsonFlags |= JSON_PRETTY_PRINT;
        }
        $json = json_encode($data, $jsonFlags);
        file_put_contents($filePath, $json);
        Tools::getRedis()->set('app:init' . $platform, $json);
        // 保存记录并返回结果
        $fileSize = filesize($filePath);
        $relativePath = str_replace(BASE_PATH . '/', '', $filePath);
        AppPageContentSync::create([
            'version' => $version,
            'platform' => $platform,
            'file_path' => $relativePath,
            'file_size' => $fileSize,
            'record_count' => $contents->count(),
            'generated_at' => Carbon::now(),
        ]);

        return [
            'platform' => $platform,
            'version' => $version,
            'file_path' => $filePath,
            'file_size' => $fileSize,
            'record_count' => $contents->count(),
        ];
    }

    /**
     * 获取文件路径并确保目录存在
     */
    private function getFilePath(string $suffix): string
    {
        $storageDir = BASE_PATH . self::STORAGE_DIR;
        if (!is_dir($storageDir)) {
            mkdir($storageDir, 0755, true);
        }
        return "{$storageDir}/app-init-{$suffix}.json";
    }
}

