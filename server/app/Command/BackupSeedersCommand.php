<?php
/**
 * FastApp.
 * 备份非插件表数据为 SQL 文件
 */

declare(strict_types=1);

namespace App\Command;

use Hyperf\Command\Annotation\AsCommand;
use Hyperf\DbConnection\Db;

#[AsCommand(
    signature: 'ds:backup-seeders {--force=false} {--prefix=} {--filename=} {--limit=1000} {--chunk-size=10}',
    description: '备份非插件表数据为 SQL 文件（支持自动分片）',
)]
class BackupSeedersCommand extends AbstractBackupCommand
{
    public function handle(): int
    {
        $force = $this->boolOption('force');
        $prefix = $this->input->getOption('prefix') ?? env('DB_PREFIX', '');
        $filename = $this->input->getOption('filename') ?? 'all_data';
        $limit = (int) ($this->input->getOption('limit') ?? 1000);
        $chunkSizeMB = (int) ($this->input->getOption('chunk-size') ?? 10);

        $this->info('开始备份 Seeder 数据...');

        try {
            $tables = $this->resolveNonPluginTables($prefix);
            if ($tables === []) {
                $this->warn('未找到任何非插件数据库表');
                return self::FAILURE;
            }

            $this->info('找到 ' . count($tables) . ' 个非插件表');

            $seedersPath = BASE_PATH . '/databases/seeders';
            $this->ensureDirectory($seedersPath);

            $fileName = date('Y_m_d_His') . '_' . $filename . '.sql';
            $filePath = $seedersPath . '/' . $fileName;

            if (! $force && file_exists($filePath)) {
                $this->warn("SQL 文件已存在: {$fileName}");
                $this->info('提示: 使用 --force=true 可以强制覆盖已存在的文件');
                return self::FAILURE;
            }

            $this->generateCombinedSeederFile($tables, $filePath, $prefix, $limit, $chunkSizeMB);
            $this->info("✓ 已备份 SQL 文件: {$fileName}");
            $this->info('包含 ' . count($tables) . ' 个表的数据');

            return self::SUCCESS;
        } catch (\Throwable $e) {
            $this->error('备份失败: ' . $e->getMessage());
            $this->error($e->getTraceAsString());
            return self::FAILURE;
        }
    }

    /**
     * 生成合并的 SQL 文件（所有表数据在一个文件中，支持自动分片）
     */
    protected function generateCombinedSeederFile(array $tables, string $filePath, string $prefix, int $limit, int $chunkSizeMB): void
    {
        $chunkSizeBytes = $chunkSizeMB * 1024 * 1024;
        $fileIndex = 1;
        $totalRecords = 0;
        $filePaths = [];

        $header = $this->buildSqlHeader();
        $footer = "\nSET FOREIGN_KEY_CHECKS = 1;\n";
        $headerSize = $this->getStringSize($header);

        $currentFileContent = $header;
        $currentFileSize = $headerSize;

        foreach ($tables as $table) {
            $tableName = str_replace($prefix, '', $table);
            $data = Db::table($table)->limit($limit)->get()->toArray();
            
            if (empty($data)) {
                $this->warn("  跳过表 {$tableName} (无数据)");
                continue;
            }

            $recordCount = count($data);
            $totalRecords += $recordCount;

            $columns = Db::select("SHOW COLUMNS FROM `{$table}`");
            $columnNames = array_map(fn($col) => $col->Field, $columns);
            $columnsStr = $this->buildColumnsString($columnNames);
            $tableComment = $this->buildTableComment($table, $recordCount);
            $tableCommentSize = $this->getStringSize($tableComment);

            // 检查是否需要新文件（表注释）
            if ($currentFileSize + $tableCommentSize > $chunkSizeBytes && $currentFileSize > $headerSize) {
                $fileIndex = $this->saveChunkFile($filePath, $fileIndex, $currentFileContent, $footer, $filePaths);
                $currentFileContent = $header;
                $currentFileSize = $headerSize;
            }

            $currentFileContent .= $tableComment;
            $currentFileSize += $tableCommentSize;

            // 生成 INSERT 语句
            $chunks = array_chunk($data, 100);
            foreach ($chunks as $chunk) {
                $insertSql = $this->buildInsertSql($table, $columnsStr, $columnNames, $chunk);
                $insertSize = $this->getStringSize($insertSql);

                // 检查是否需要新文件（INSERT 语句）
                if ($currentFileSize + $insertSize > $chunkSizeBytes && $currentFileSize > $headerSize) {
                    $fileIndex = $this->saveChunkFile($filePath, $fileIndex, $currentFileContent, $footer, $filePaths);
                    $currentFileContent = $header . $tableComment;
                    $currentFileSize = $headerSize + $tableCommentSize;
                }

                $currentFileContent .= $insertSql;
                $currentFileSize += $insertSize;
            }
            
            $this->info("  ✓ 表 {$tableName}: {$recordCount} 条记录");
        }

        // 保存最后一个文件
        if (!empty($currentFileContent) && $currentFileSize > $headerSize) {
            $this->saveChunkFile($filePath, $fileIndex, $currentFileContent, $footer, $filePaths);
        }

        $this->info("总计: {$totalRecords} 条记录");
        if (count($filePaths) > 1) {
            $this->info("已生成 " . count($filePaths) . " 个分片文件（每个文件最大 {$chunkSizeMB}MB）");
        } else {
            $this->info("SQL 文件已生成: " . basename($filePath));
        }
    }

    /**
     * 构建 SQL 文件头部
     */
    protected function buildSqlHeader(): string
    {
        return "-- 数据备份 SQL 文件\n"
            . '-- 备份时间: ' . date('Y-m-d H:i:s') . "\n"
            . "-- 说明: 此文件包含所有非插件表的数据 INSERT 语句\n\n"
            . "SET FOREIGN_KEY_CHECKS = 0;\n\n";
    }

    /**
     * 构建表注释
     */
    protected function buildTableComment(string $table, int $recordCount): string
    {
        $escapedTableName = str_replace(['--', '/*', '*/'], ['', '', ''], $table);
        return "-- ============================================\n"
            . "-- 表: {$escapedTableName} (共 {$recordCount} 条记录)\n"
            . "-- ============================================\n\n";
    }

    /**
     * 构建字段字符串
     */
    protected function buildColumnsString(array $columnNames): string
    {
        $escapedColumns = array_map(fn($name) => $this->escapeBacktick($name), $columnNames);
        return implode(', ', $escapedColumns);
    }

    /**
     * 构建 INSERT SQL 语句
     */
    protected function buildInsertSql(string $table, string $columnsStr, array $columnNames, array $chunk): string
    {
        $escapedTableName = $this->escapeBacktick($table);
        $insertSql = "INSERT INTO {$escapedTableName} ({$columnsStr}) VALUES\n";
        
        $values = [];
        foreach ($chunk as $row) {
            $rowArray = (array)$row;
            $rowValues = [];
            foreach ($columnNames as $colName) {
                $rowValues[] = $this->formatSqlValue($rowArray[$colName] ?? null);
            }
            $values[] = '(' . implode(', ', $rowValues) . ')';
        }
        
        return $insertSql . implode(",\n", $values) . ";\n\n";
    }

    protected function escapeBacktick(string $str): string
    {
        return $this->escapeBacktickIdentifier($str);
    }

    /**
     * 获取字符串大小（多字节字符）
     */
    protected function getStringSize(string $str): int
    {
        return mb_strlen($str, 'UTF-8');
    }

    /**
     * 保存分片文件
     */
    protected function saveChunkFile(string $filePath, int $fileIndex, string $content, string $footer, array &$filePaths): int
    {
        $content .= $footer;
        $currentFilePath = $this->getChunkedFilePath($filePath, $fileIndex);
        file_put_contents($currentFilePath, $content);
        $filePaths[] = $currentFilePath;
        $actualFileSize = filesize($currentFilePath);
        $this->info("  备份分片文件 #{$fileIndex}: " . basename($currentFilePath) . ' (' . $this->formatFileSize($actualFileSize) . ')');
        return $fileIndex + 1;
    }

    /**
     * 获取分片文件路径
     */
    protected function getChunkedFilePath(string $originalPath, int $index): string
    {
        $pathInfo = pathinfo($originalPath);
        $dirname = $pathInfo['dirname'];
        $filename = $pathInfo['filename'];
        $extension = $pathInfo['extension'] ?? 'sql';
        
        if ($index === 1) {
            return $originalPath;
        }
        
        return $dirname . '/' . $filename . '_part' . $index . '.' . $extension;
    }

    /**
     * 格式化文件大小
     */
    protected function formatFileSize(int $bytes): string
    {
        if ($bytes >= 1024 * 1024) {
            return number_format($bytes / (1024 * 1024), 2) . ' MB';
        } elseif ($bytes >= 1024) {
            return number_format($bytes / 1024, 2) . ' KB';
        }
        return $bytes . ' B';
    }

}

