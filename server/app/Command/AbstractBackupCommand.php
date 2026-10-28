<?php

declare(strict_types=1);

namespace App\Command;

use Hyperf\Command\Command;
use Hyperf\DbConnection\Db;

abstract class AbstractBackupCommand extends Command
{
    protected function resolveNonPluginTables(string $prefix, string $tableOption = ''): array
    {
        $pluginTables = $this->getPluginTables($prefix);
        $this->info('识别到 ' . count($pluginTables) . ' 个插件表，将自动过滤');

        $pluginTablesMap = array_flip($pluginTables);
        $tables = array_filter($this->getAllTables($prefix), static function ($table) use ($pluginTablesMap, $prefix) {
            $tableName = str_replace($prefix, '', $table);
            return ! isset($pluginTablesMap[$tableName]) && ! isset($pluginTablesMap[$table]);
        });

        if ($tableOption !== '') {
            $tables = $this->filterTablesByOption($tables, $tableOption, $prefix);
        }

        return array_values($tables);
    }

    protected function getPluginTables(string $prefix): array
    {
        $pluginTables = [];
        $pluginPath = BASE_PATH . '/plugin';
        if (! is_dir($pluginPath)) {
            return $pluginTables;
        }

        $iterator = new \RecursiveIteratorIterator(new \RecursiveDirectoryIterator($pluginPath));
        foreach ($iterator as $file) {
            if (! $file->isFile() || $file->getExtension() !== 'php') {
                continue;
            }

            $filePath = $file->getRealPath();
            if (strpos($filePath, '/Database/Migrations/') === false) {
                continue;
            }

            $content = file_get_contents($filePath);
            if (! preg_match_all("/Schema::(create|table)\s*\(\s*['\"]([^'\"]+)['\"]/", $content, $matches)) {
                continue;
            }

            foreach ($matches[2] as $table) {
                $tableName = str_replace($prefix, '', $table);
                if (! in_array($tableName, $pluginTables, true)) {
                    $pluginTables[] = $tableName;
                }
                if ($prefix && ! in_array($table, $pluginTables, true)) {
                    $pluginTables[] = $table;
                }
            }
        }

        return $pluginTables;
    }

    protected function getAllTables(string $prefix): array
    {
        $database = env('DB_DATABASE');
        $sql = 'SELECT TABLE_NAME FROM information_schema.TABLES
                WHERE TABLE_SCHEMA = ?
                AND TABLE_TYPE = \'BASE TABLE\'';
        if ($prefix) {
            $sql .= " AND TABLE_NAME LIKE '{$prefix}%'";
        }

        $tables = Db::select($sql, [$database]);
        return array_map(static fn ($row) => $row->TABLE_NAME, $tables);
    }

    protected function filterTablesByOption(array $tables, string $tableOption, string $prefix): array
    {
        $requestedTables = array_values(array_unique(array_filter(array_map(
            static fn ($name) => trim($name),
            explode(',', $tableOption)
        ))));

        if ($requestedTables === []) {
            $this->warn('参数 --table 未提供有效表名，已回退为全量非插件表');
            return array_values($tables);
        }

        $candidateMap = [];
        foreach ($tables as $table) {
            $candidateMap[$table] = $table;
            if ($prefix !== '' && str_starts_with($table, $prefix)) {
                $withoutPrefix = substr($table, strlen($prefix));
                if ($withoutPrefix !== false && $withoutPrefix !== '') {
                    $candidateMap[$withoutPrefix] = $table;
                }
            }
        }

        $missingTables = [];
        $selectedTables = [];
        foreach ($requestedTables as $requestedTable) {
            if (! isset($candidateMap[$requestedTable])) {
                $missingTables[] = $requestedTable;
                continue;
            }
            $selectedTables[$candidateMap[$requestedTable]] = true;
        }

        if ($missingTables !== []) {
            $this->warn('以下表未找到或属于插件表，已忽略: ' . implode(', ', $missingTables));
        }

        return array_keys($selectedTables);
    }

    protected function ensureDirectory(string $path): void
    {
        if (! is_dir($path)) {
            mkdir($path, 0755, true);
        }
    }

    protected function boolOption(string $name): bool
    {
        return filter_var($this->input->getOption($name), FILTER_VALIDATE_BOOLEAN);
    }

    protected function escapeString(string $str): string
    {
        return str_replace("'", "\\'", $str);
    }

    protected function escapeBacktickIdentifier(string $name): string
    {
        return '`' . str_replace('`', '``', $name) . '`';
    }

    protected function formatSqlValue(mixed $value): string
    {
        if ($value === null) {
            return 'NULL';
        }
        if (is_bool($value)) {
            return $value ? '1' : '0';
        }
        if (is_int($value) || is_float($value)) {
            return (string) $value;
        }
        if (is_array($value) || is_object($value)) {
            $json = json_encode($value, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
            if ($json === false) {
                return 'NULL';
            }
            $value = $json;
        }

        $value = (string) $value;
        $value = str_replace(['\\', "'", "\r\n", "\n", "\r", "\0"], ['\\\\', "''", '\\n', '\\n', '\\n', ''], $value);
        return "'{$value}'";
    }
}
