<?php
/**
 * FastApp.
 * 导入 SQL 文件命令
 * 从 SQL 文件导入数据到数据库
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

declare(strict_types=1);

namespace App\Command\Generator;

use Hyperf\Command\Annotation\AsCommand;
use Hyperf\Command\Command;
use Hyperf\DbConnection\Db;

#[AsCommand(
    signature: 'ds:import-sql {file} {--skip-errors=false} {--transaction=true} {--batch-size=100}',
    description: '导入 SQL 文件到数据库（支持分片文件，自动识别）',
    aliases: ['ds:import'],
)]
class ImportSqlCommand extends Command
{
    /**
     * 命令执行
     */
    public function handle(): int
    {
        $filePath = $this->input->getArgument('file');
        $skipErrors = filter_var($this->input->getOption('skip-errors'), FILTER_VALIDATE_BOOLEAN);
        $useTransaction = filter_var($this->input->getOption('transaction'), FILTER_VALIDATE_BOOLEAN);
        $batchSize = (int)($this->input->getOption('batch-size') ?? 100);

        // 处理相对路径（相对于 seeders 目录）
        if (!str_starts_with($filePath, '/')) {
            $filePath = BASE_PATH . '/databases/seeders/' . ltrim($filePath, '/');
        }

        // 检查文件是否存在
        if (!file_exists($filePath)) {
            $this->error("文件不存在: {$filePath}");
            return self::FAILURE;
        }

        $this->info("开始导入 SQL 文件: {$filePath}");

        try {
            // 检查是否为分片文件
            $files = $this->getSqlFiles($filePath);
            
            if (empty($files)) {
                $this->warn('未找到任何 SQL 文件');
                return self::FAILURE;
            }

            $this->info("找到 " . count($files) . " 个 SQL 文件");

            $totalFiles = count($files);
            $totalStatements = 0;
            $successStatements = 0;
            $errorStatements = 0;

            foreach ($files as $index => $file) {
                $this->info("正在导入文件 [" . ($index + 1) . "/{$totalFiles}]: " . basename($file));
                
                $result = $this->importSqlFile($file, $skipErrors, $useTransaction, $batchSize);
                
                $totalStatements += $result['total'];
                $successStatements += $result['success'];
                $errorStatements += $result['errors'];
            }

            $this->info("✓ 导入完成");
            $this->info("总计: {$totalStatements} 条 SQL 语句");
            $this->info("成功: {$successStatements} 条");
            
            if ($errorStatements > 0) {
                $this->warn("失败: {$errorStatements} 条");
            }

            return self::SUCCESS;
        } catch (\Throwable $e) {
            $this->error("导入失败: " . $e->getMessage());
            $this->error($e->getTraceAsString());
            return self::FAILURE;
        }
    }

    /**
     * 获取 SQL 文件列表（支持分片文件）
     */
    protected function getSqlFiles(string $filePath): array
    {
        if (is_file($filePath)) {
            return $this->getChunkedFiles($filePath);
        }

        if (is_dir($filePath)) {
            return $this->getDirectoryFiles($filePath);
        }

        return [];
    }

    /**
     * 获取分片文件列表
     */
    protected function getChunkedFiles(string $filePath): array
    {
        $files = [$filePath];
        $pathInfo = pathinfo($filePath);
        $dirname = $pathInfo['dirname'];
        $filename = $pathInfo['filename'];
        $extension = $pathInfo['extension'] ?? 'sql';

        $partIndex = 2;
        while (true) {
            $partFile = "{$dirname}/{$filename}_part{$partIndex}.{$extension}";
            if (!file_exists($partFile)) {
                break;
            }
            $files[] = $partFile;
            $partIndex++;
        }

        return $files;
    }

    /**
     * 获取目录中的所有 SQL 文件
     */
    protected function getDirectoryFiles(string $dirPath): array
    {
        $files = [];
        $iterator = new \RecursiveIteratorIterator(
            new \RecursiveDirectoryIterator($dirPath)
        );

        foreach ($iterator as $file) {
            if ($file->isFile() && $file->getExtension() === 'sql') {
                $files[] = $file->getRealPath();
            }
        }

        sort($files);
        return $files;
    }

    /**
     * 导入单个 SQL 文件
     */
    protected function importSqlFile(string $filePath, bool $skipErrors, bool $useTransaction, int $batchSize): array
    {
        $content = file_get_contents($filePath);
        if ($content === false) {
            throw new \RuntimeException("无法读取文件: {$filePath}");
        }

        $statements = $this->splitSqlStatements($content);
        $validStatements = $this->filterValidStatements($statements);
        $total = count($validStatements);

        $this->info("  共 {$total} 条 SQL 语句");

        if ($useTransaction && !$skipErrors) {
            return $this->executeWithTransaction($validStatements, $batchSize, $total);
        }

        return $this->executeStatements($validStatements, $skipErrors, $batchSize, $total);
    }

    /**
     * 过滤有效的 SQL 语句
     */
    protected function filterValidStatements(array $statements): array
    {
        $valid = [];
        foreach ($statements as $statement) {
            $statement = trim($statement);
            if (!empty($statement) && !$this->isComment($statement)) {
                $valid[] = $statement;
            }
        }
        return $valid;
    }

    /**
     * 使用事务执行语句
     */
    protected function executeWithTransaction(array $statements, int $batchSize, int $total): array
    {
        $success = 0;
        $executed = 0;

        Db::beginTransaction();
        try {
            foreach ($statements as $statement) {
                $executed++;
                $this->executeStatement($statement);
                $success++;
                $this->showProgress($executed, $total, $batchSize);
            }
            Db::commit();
        } catch (\Throwable $e) {
            Db::rollBack();
            throw $e;
        }

        return ['total' => $executed, 'success' => $success, 'errors' => 0];
    }

    /**
     * 执行语句（不使用事务或允许跳过错误）
     */
    protected function executeStatements(array $statements, bool $skipErrors, int $batchSize, int $total): array
    {
        $success = 0;
        $errors = 0;
        $executed = 0;

        foreach ($statements as $statement) {
            $executed++;
            try {
                $this->executeStatement($statement);
                $success++;
                $this->showProgress($executed, $total, $batchSize);
            } catch (\Throwable $e) {
                $errors++;
                if (!$skipErrors) {
                    throw $e;
                }
                $this->warn("    语句执行失败 [{$executed}]: " . $e->getMessage());
            }
        }

        return ['total' => $executed, 'success' => $success, 'errors' => $errors];
    }

    /**
     * 显示执行进度
     */
    protected function showProgress(int $executed, int $total, int $batchSize): void
    {
        if ($executed % $batchSize === 0) {
            $this->line("    已执行: {$executed}/{$total}");
        }
    }

    /**
     * 检查是否为注释
     */
    protected function isComment(string $statement): bool
    {
        return preg_match('/^\s*--/', trim($statement)) === 1;
    }

    /**
     * 分割 SQL 语句
     */
    protected function splitSqlStatements(string $content): array
    {
        // 移除单行注释
        $content = preg_replace('/--[^\r\n]*/m', '', $content);
        // 移除多行注释
        $content = preg_replace('/\/\*.*?\*\//s', '', $content);
        
        // 按分号分割，处理字符串中的分号
        $statements = [];
        $current = '';
        $inString = false;
        $stringChar = '';
        $len = strlen($content);
        
        for ($i = 0; $i < $len; $i++) {
            $char = $content[$i];
            $prevChar = $i > 0 ? $content[$i - 1] : '';
            
            if (!$inString && ($char === '"' || $char === "'" || $char === '`')) {
                $inString = true;
                $stringChar = $char;
                $current .= $char;
            } elseif ($inString && $char === $stringChar && $prevChar !== '\\') {
                $inString = false;
                $current .= $char;
            } elseif (!$inString && $char === ';') {
                $statement = trim($current);
                if (!empty($statement)) {
                    $statements[] = $statement;
                }
                $current = '';
            } else {
                $current .= $char;
            }
        }
        
        // 添加最后一个语句
        $statement = trim($current);
        if (!empty($statement)) {
            $statements[] = $statement;
        }
        
        return array_filter($statements, fn($stmt) => !empty(trim($stmt)));
    }

    /**
     * 执行 SQL 语句
     */
    protected function executeStatement(string $statement): void
    {
        Db::statement($statement);
    }
}

