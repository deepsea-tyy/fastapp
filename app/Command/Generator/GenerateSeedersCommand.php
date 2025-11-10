<?php
/**
 * FastApp.
 * 批量生成数据迁移（Seeder）文件命令
 * 从现有数据库表数据生成所有 Seeder 文件，过滤插件表
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

declare(strict_types=1);

namespace App\Command\Generator;

use Hyperf\Command\Annotation\AsCommand;
use Hyperf\Command\Command;
use Hyperf\DbConnection\Db;

#[AsCommand(
    signature: 'ds:generate-seeders {--force=false} {--prefix=} {--filename=} {--limit=1000} {--chunk-size=10}',
    description: '从现有数据库表数据批量生成 Seeder 文件（过滤插件表，合并到一个文件，支持自动分片）',
    aliases: ['ds:gen-seeders'],
)]
class GenerateSeedersCommand extends Command
{
    /**
     * 命令执行
     */
    public function handle(): int
    {
        $force = filter_var($this->input->getOption('force'), FILTER_VALIDATE_BOOLEAN);
        $prefix = $this->input->getOption('prefix') ?? env('DB_PREFIX', '');
        $filename = $this->input->getOption('filename') ?? 'all_data';
        $limit = (int)($this->input->getOption('limit') ?? 1000);
        $chunkSizeMB = (int)($this->input->getOption('chunk-size') ?? 10); // 默认 10MB

        $this->info('开始生成 Seeder 文件...');

        try {
            // 获取插件表名列表（复用迁移命令的方法）
            $pluginTables = $this->getPluginTables($prefix);
            $this->info("识别到 " . count($pluginTables) . " 个插件表，将自动过滤");

            // 获取所有表名
            $allTables = $this->getAllTables($prefix);
            
            // 过滤插件表（使用关联数组提高性能）
            $pluginTablesMap = array_flip($pluginTables);
            $tables = array_filter($allTables, function($table) use ($pluginTablesMap, $prefix) {
                $tableName = str_replace($prefix, '', $table);
                return !isset($pluginTablesMap[$tableName]) && !isset($pluginTablesMap[$table]);
            });
            
            if (empty($tables)) {
                $this->warn('未找到任何非插件数据库表');
                return self::FAILURE;
            }

            $this->info("找到 " . count($tables) . " 个非插件表");

            $seedersPath = BASE_PATH . '/databases/seeders';
            if (!is_dir($seedersPath)) {
                mkdir($seedersPath, 0755, true);
            }

            // 生成单个合并的 SQL 文件
            $fileName = date('Y_m_d_His') . '_' . $filename . '.sql';
            $filePath = $seedersPath . '/' . $fileName;

            // 检查文件是否已存在
            if (!$force && file_exists($filePath)) {
                $this->warn("SQL 文件已存在: {$fileName}");
                $this->info("提示: 使用 --force=true 可以强制覆盖已存在的文件");
                return self::FAILURE;
            }

            // 生成合并的 SQL 文件
            $this->generateCombinedSeederFile($tables, $filePath, $prefix, $limit, $chunkSizeMB);
            $this->info("✓ 已生成 SQL 文件: {$fileName}");
            $this->info("包含 " . count($tables) . " 个表的数据");

            return self::SUCCESS;
        } catch (\Throwable $e) {
            $this->error("生成失败: " . $e->getMessage());
            $this->error($e->getTraceAsString());
            return self::FAILURE;
        }
    }

    /**
     * 获取插件表名列表（复用迁移命令的逻辑）
     */
    protected function getPluginTables(string $prefix): array
    {
        $pluginTables = [];
        $pluginPath = BASE_PATH . '/plugin';

        if (!is_dir($pluginPath)) {
            return $pluginTables;
        }

        // 扫描所有插件的迁移文件
        $iterator = new \RecursiveIteratorIterator(
            new \RecursiveDirectoryIterator($pluginPath)
        );

        foreach ($iterator as $file) {
            if ($file->isFile() && $file->getExtension() === 'php') {
                $filePath = $file->getRealPath();
                
                // 只处理迁移文件
                if (strpos($filePath, '/Database/Migrations/') === false) {
                    continue;
                }

                // 读取文件内容，提取表名
                $content = file_get_contents($filePath);
                
                // 匹配 Schema::create 或 Schema::table 中的表名
                if (preg_match_all("/Schema::(create|table)\s*\(\s*['\"]([^'\"]+)['\"]/", $content, $matches)) {
                    foreach ($matches[2] as $table) {
                        $tableName = str_replace($prefix, '', $table);
                        if (!in_array($tableName, $pluginTables)) {
                            $pluginTables[] = $tableName;
                            // 也添加带前缀的完整表名
                            if ($prefix && !in_array($table, $pluginTables)) {
                                $pluginTables[] = $table;
                            }
                        }
                    }
                }
            }
        }

        return $pluginTables;
    }

    /**
     * 获取所有表名
     */
    protected function getAllTables(string $prefix): array
    {
        $database = env('DB_DATABASE');
        $sql = "SELECT TABLE_NAME FROM information_schema.TABLES 
                WHERE TABLE_SCHEMA = ? 
                AND TABLE_TYPE = 'BASE TABLE'";

        if ($prefix) {
            $sql .= " AND TABLE_NAME LIKE '{$prefix}%'";
        }

        $tables = Db::select($sql, [$database]);
        return array_map(fn($row) => $row->TABLE_NAME, $tables);
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
        return "-- 数据迁移 SQL 文件\n"
            . "-- 生成时间: " . date('Y-m-d H:i:s') . "\n"
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

    /**
     * 转义反引号
     */
    protected function escapeBacktick(string $str): string
    {
        return '`' . str_replace('`', '``', $str) . '`';
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
        $this->info("  生成分片文件 #{$fileIndex}: " . basename($currentFilePath) . " (" . $this->formatFileSize($actualFileSize) . ")");
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

    /**
     * 格式化值（用于生成 SQL 语句）
     */
    protected function formatSqlValue($value): string
    {
        if ($value === null) {
            return 'NULL';
        }
        
        if (is_bool($value)) {
            return $value ? '1' : '0';
        }
        
        if (is_int($value) || is_float($value)) {
            return (string)$value;
        }
        
        if (is_array($value) || is_object($value)) {
            $json = json_encode($value, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
            if ($json === false) {
                return 'NULL';
            }
            $value = $json;
        }
        
        // 转义 SQL 特殊字符
        $value = (string)$value;
        $value = str_replace(['\\', "'", "\r\n", "\n", "\r", "\0"], ['\\\\', "''", '\\n', '\\n', '\\n', ''], $value);
        
        return "'{$value}'";
    }
}

