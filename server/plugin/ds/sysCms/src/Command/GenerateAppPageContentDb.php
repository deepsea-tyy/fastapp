<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Command;

use Hyperf\Command\Annotation\AsCommand;
use Hyperf\Command\Command;
use Plugin\Ds\SysCms\Command\Service\AppPageContentGeneratorService;

/**
 * 生成App页面内容数据库文件命令
 * 
 * @author FastApp代码生成器
 * @date 2025-12-08
 */
#[AsCommand(
    signature: 'ds:sysCms:generate-app-page-content',
    description: '生成App页面内容JSON文件（统一使用JSON格式）',
)]
class GenerateAppPageContentDb extends Command
{
    public function __construct(
        private readonly AppPageContentGeneratorService $generatorService
    ) {
        parent::__construct();
    }

    public function handle(): int
    {
        $this->info("开始生成页面内容JSON文件（统一使用JSON格式）...");

        try {
            $results = $this->generatorService->generate();
            
            $this->info("文件生成成功！");
            foreach ($results as $result) {
                $platformName = $result['platform'] === 1 ? 'Web' : 'App';
                $this->info("  - {$platformName}平台JSON文件: {$result['file_path']}");
                $this->info("    版本号: {$result['version']}");
                $this->info("    文件大小: " . $this->formatBytes($result['file_size']));
                $this->info("    记录数: {$result['record_count']}");
            }
            
            return self::SUCCESS;
        } catch (\Exception $e) {
            $this->error('文件生成失败: ' . $e->getMessage());
            if ($this->output->isVerbose()) {
                $this->error($e->getTraceAsString());
            }
            return self::FAILURE;
        }
    }

    /**
     * 格式化字节大小
     */
    private function formatBytes(int $bytes, int $precision = 2): string
    {
        $units = ['B', 'KB', 'MB', 'GB', 'TB'];
        
        for ($i = 0; $bytes > 1024 && $i < count($units) - 1; $i++) {
            $bytes /= 1024;
        }
        
        return round($bytes, $precision) . ' ' . $units[$i];
    }
}

