<?php
/**
 * FastApp.
 * 批量生成数据库迁移文件命令
 * 从现有数据库表结构生成所有迁移文件
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

declare(strict_types=1);

namespace App\Command\Generator;

use Hyperf\Command\Annotation\AsCommand;
use Hyperf\Command\Command;
use Hyperf\DbConnection\Db;

#[AsCommand(
    signature: 'ds:generate-migrations {--force=false} {--prefix=} {--filename=} {--table=} {--with-data=false} {--data-limit=1000}',
    description: '从现有数据库表批量生成迁移文件（过滤插件表，合并到一个文件）',
    aliases: ['ds:gen-migrations'],
)]
class GenerateMigrationsCommand extends Command
{
    /**
     * 命令执行
     */
    public function handle(): int
    {
        $force = filter_var($this->input->getOption('force'), FILTER_VALIDATE_BOOLEAN);
        $prefix = $this->input->getOption('prefix') ?? env('DB_PREFIX', '');
        $filename = $this->input->getOption('filename') ?? 'all_tables';
        $tableOption = trim((string) ($this->input->getOption('table') ?? ''));
        $withData = filter_var($this->input->getOption('with-data'), FILTER_VALIDATE_BOOLEAN);
        $dataLimit = max(1, (int)($this->input->getOption('data-limit') ?? 1000));

        $this->info('开始生成迁移文件...');

        try {
            // 获取插件表名列表
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

            // 指定表名（支持逗号分隔）
            if ($tableOption !== '') {
                $tables = $this->filterTablesByOption($tables, $tableOption, $prefix);
            }
            
            if (empty($tables)) {
                $this->warn('未找到任何非插件数据库表');
                return self::FAILURE;
            }

            $this->info("找到 " . count($tables) . " 个非插件表");

            $migrationsPath = BASE_PATH . '/databases/migrations';
            if (!is_dir($migrationsPath)) {
                mkdir($migrationsPath, 0755, true);
            }

            // 生成单个合并的迁移文件
            $fileName = date('Y_m_d_His') . '_' . $filename . '.php';
            $filePath = $migrationsPath . '/' . $fileName;

            // 检查文件是否已存在
            if (!$force && file_exists($filePath)) {
                $this->warn("迁移文件已存在: {$fileName}");
                $this->info("提示: 使用 --force=true 可以强制覆盖已存在的文件");
                return self::FAILURE;
            }

            // 生成合并的迁移文件
            $this->generateCombinedMigrationFile($tables, $filePath, $prefix, $withData, $dataLimit);
            $this->info("✓ 已生成合并迁移文件: {$fileName}");
            $this->info("包含 " . count($tables) . " 个表的迁移定义");
            if ($withData) {
                $this->info("已包含表数据 INSERT 语句（每表最多 {$dataLimit} 条）");
            }

            return self::SUCCESS;
        } catch (\Throwable $e) {
            $this->error("生成失败: " . $e->getMessage());
            $this->error($e->getTraceAsString());
            return self::FAILURE;
        }
    }

    /**
     * 获取插件表名列表
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
     * 根据 --table 参数过滤表名
     */
    protected function filterTablesByOption(array $tables, string $tableOption, string $prefix): array
    {
        $requestedTables = array_values(array_unique(array_filter(array_map(
            static fn($name) => trim($name),
            explode(',', $tableOption)
        ))));

        if (empty($requestedTables)) {
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
            if (!isset($candidateMap[$requestedTable])) {
                $missingTables[] = $requestedTable;
                continue;
            }
            $selectedTables[$candidateMap[$requestedTable]] = true;
        }

        if (!empty($missingTables)) {
            $this->warn('以下表未找到或属于插件表，已忽略: ' . implode(', ', $missingTables));
        }

        return array_keys($selectedTables);
    }

    /**
     * 生成合并的迁移文件（所有表在一个文件中）
     */
    protected function generateCombinedMigrationFile(array $tables, string $filePath, string $prefix, bool $withData, int $dataLimit): void
    {
        $content = $this->buildMigrationHeader($withData);
        $content .= "    public function up(): void\n";
        $content .= "    {\n";

        foreach ($tables as $table) {
            $tableName = str_replace($prefix, '', $table);
            $content .= $this->buildTableDefinition($table, $tableName);
        }

        if ($withData) {
            foreach ($tables as $table) {
                $tableName = str_replace($prefix, '', $table);
                $content .= $this->buildTableInsertStatements($table, $tableName, $dataLimit);
            }
        }

        $content .= "    }\n\n";
        $content .= "    public function down(): void\n";
        $content .= "    {\n";
        
        foreach (array_reverse($tables) as $table) {
            $escapedTable = $this->escapeString($table);
            $content .= "        Schema::dropIfExists('{$escapedTable}');\n";
        }
        
        $content .= "    }\n";
        $content .= "}\n";

        file_put_contents($filePath, $content);
    }

    /**
     * 构建迁移文件头部
     */
    protected function buildMigrationHeader(bool $withData): string
    {
        $dbUse = $withData ? "use Hyperf\\DbConnection\\Db;\n" : '';
        return "<?php\n\n"
            . "declare(strict_types=1);\n\n"
            . "use Hyperf\Database\Migrations\Migration;\n"
            . "use Hyperf\Database\Schema\Schema;\n"
            . "use Hyperf\Database\Schema\Blueprint;\n"
            . $dbUse
            . "\n"
            . "class CreateAllTables extends Migration\n"
            . "{\n";
    }

    /**
     * 构建表数据 INSERT 语句
     */
    protected function buildTableInsertStatements(string $table, string $tableName, int $dataLimit): string
    {
        $rows = Db::table($table)->limit($dataLimit)->get()->toArray();
        if (empty($rows)) {
            return "        // 表数据: {$tableName}（无数据，已跳过）\n";
        }

        $columns = Db::select("SHOW COLUMNS FROM `{$table}`");
        $columnNames = array_map(fn($col) => $col->Field, $columns);
        if (empty($columnNames)) {
            return "        // 表数据: {$tableName}（未获取到字段，已跳过）\n";
        }

        $escapedTable = str_replace('`', '``', $table);
        $escapedColumns = array_map([$this, 'escapeBacktickIdentifier'], $columnNames);
        $columnsStr = implode(', ', $escapedColumns);
        $content = "        // 表数据: {$tableName}（最多 {$dataLimit} 条）\n";

        foreach (array_chunk($rows, 100) as $chunkIndex => $chunkRows) {
            $values = [];
            foreach ($chunkRows as $row) {
                $rowArray = (array) $row;
                $rowValues = [];
                foreach ($columnNames as $columnName) {
                    $rowValues[] = $this->formatSqlValue($rowArray[$columnName] ?? null);
                }
                $values[] = '(' . implode(', ', $rowValues) . ')';
            }

            $sql = "INSERT INTO `{$escapedTable}` ({$columnsStr}) VALUES " . implode(', ', $values);
            $content .= $this->buildSqlStatementBlock($sql, $tableName, $chunkIndex);
        }

        $content .= "\n";
        return $content;
    }

    /**
     * 使用 nowdoc 输出 SQL，减少整句转义噪音
     */
    protected function buildSqlStatementBlock(string $sql, string $tableName, int $chunkIndex): string
    {
        $label = 'SQL_' . strtoupper(preg_replace('/[^a-zA-Z0-9_]/', '_', $tableName)) . '_' . $chunkIndex;
        return "        Db::statement(<<<'{$label}'\n"
            . $sql . ";\n"
            . "{$label}\n"
            . "        );\n";
    }

    /**
     * 构建表定义
     */
    protected function buildTableDefinition(string $table, string $tableName): string
    {
        $columns = Db::select("SHOW FULL COLUMNS FROM `{$table}`");
        $indexes = Db::select("SHOW INDEX FROM `{$table}`");
        $tableComment = $this->getTableComment($table);

        $escapedTableName = $this->escapeString($table);
        $content = "        // 表: {$tableName}\n";
        $content .= "        Schema::create('{$escapedTableName}', function (Blueprint \$table) {\n";

        // 生成字段
        foreach ($columns as $column) {
            $content .= "            {$this->buildFieldDefinition($column)}\n";
        }

        // 生成索引
        $content .= $this->buildIndexes($indexes);

        if ($tableComment) {
            $escapedComment = $this->escapeString($tableComment);
            $content .= "            \$table->comment('{$escapedComment}');\n";
        }

        $content .= "        });\n\n";
        return $content;
    }

    /**
     * 构建索引定义
     */
    protected function buildIndexes(array $indexes): string
    {
        $uniqueIndexes = [];
        $indexesMap = [];

        foreach ($indexes as $index) {
            if ($index->Key_name === 'PRIMARY') {
                continue;
            }
            
            $indexName = $index->Key_name;
            if ($index->Non_unique == 0) {
                $uniqueIndexes[$indexName][] = $index->Column_name;
            } else {
                $indexesMap[$indexName][] = $index->Column_name;
            }
        }

        $content = '';
        foreach ($uniqueIndexes as $indexName => $fields) {
            $content .= $this->buildIndexLine('unique', $indexName, $fields);
        }
        foreach ($indexesMap as $indexName => $fields) {
            $content .= $this->buildIndexLine('index', $indexName, $fields);
        }

        return $content;
    }

    /**
     * 构建索引行
     */
    protected function buildIndexLine(string $method, string $indexName, array $fields): string
    {
        $escapedIndexName = $this->escapeString($indexName);
        $escapedFields = array_map([$this, 'escapeString'], $fields);
        
        if (count($escapedFields) === 1) {
            return "            \$table->{$method}('{$escapedFields[0]}', '{$escapedIndexName}');\n";
        }
        
        $fieldsStr = "['" . implode("', '", $escapedFields) . "']";
        return "            \$table->{$method}({$fieldsStr}, '{$escapedIndexName}');\n";
    }

    /**
     * 转义字符串中的单引号
     */
    protected function escapeString(string $str): string
    {
        return str_replace("'", "\\'", $str);
    }

    /**
     * 标识符反引号转义
     */
    protected function escapeBacktickIdentifier(string $name): string
    {
        return '`' . str_replace('`', '``', $name) . '`';
    }

    /**
     * 获取表注释
     */
    protected function getTableComment(string $table): string
    {
        $result = Db::select(
            "SELECT TABLE_COMMENT FROM information_schema.TABLES 
             WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?",
            [env('DB_DATABASE'), $table]
        );
        
        return $result[0]->TABLE_COMMENT ?? '';
    }

    /**
     * 构建字段定义
     */
    protected function buildFieldDefinition(object $column): string
    {
        $name = $column->Field;
        $escapedName = $this->escapeString($name);
        $type = strtolower($column->Type);
        $null = $column->Null === 'YES' ? '->nullable()' : '';
        $default = $this->getDefaultValue($column);
        $commentText = $column->Comment ? $this->escapeString($column->Comment) : '';
        $comment = $commentText ? "->comment('{$commentText}')" : '';
        $autoIncrement = str_contains($type, 'auto_increment') ? '->autoIncrement()' : '';

        // 处理主键和自增
        if ($column->Key === 'PRI' && str_contains($type, 'bigint') && str_contains($type, 'unsigned') && $autoIncrement) {
            return "\$table->id()" . ($commentText ? "->comment('{$commentText}')" : '') . ";";
        }

        $fieldType = $this->parseFieldType($type, $escapedName);
        return "\$table->{$fieldType}('{$escapedName}'){$null}{$default}{$autoIncrement}{$comment};";
    }

    /**
     * 解析字段类型
     */
    protected function parseFieldType(string $type, string $name): string
    {
        // 处理常见类型
        if (str_contains($type, 'bigint') && str_contains($type, 'unsigned')) {
            return 'unsignedBigInteger';
        }
        if (str_contains($type, 'int') && str_contains($type, 'unsigned')) {
            return 'unsignedInteger';
        }
        if (str_contains($type, 'tinyint(1)')) {
            return 'boolean';
        }
        if (str_contains($type, 'int')) {
            return 'integer';
        }
        if (str_contains($type, 'decimal') || str_contains($type, 'numeric')) {
            preg_match('/\((\d+),(\d+)\)/', $type, $matches);
            $precision = $matches[1] ?? 8;
            $scale = $matches[2] ?? 2;
            return "decimal({$precision}, {$scale})";
        }
        if (str_contains($type, 'float')) {
            return 'float';
        }
        if (str_contains($type, 'double')) {
            return 'double';
        }
        if (str_contains($type, 'datetime')) {
            return 'dateTime';
        }
        if (str_contains($type, 'timestamp')) {
            return 'timestamp';
        }
        if (str_contains($type, 'date')) {
            return 'date';
        }
        if (str_contains($type, 'time')) {
            return 'time';
        }
        if (str_contains($type, 'text')) {
            return 'text';
        }
        if (str_contains($type, 'longtext')) {
            return 'longText';
        }
        if (str_contains($type, 'mediumtext')) {
            return 'mediumText';
        }
        if (str_contains($type, 'json')) {
            return 'json';
        }
        if (str_contains($type, 'enum')) {
            preg_match("/enum\((.+)\)/", $type, $matches);
            if (!empty($matches[1])) {
                // 提取枚举值
                $enumValues = preg_match_all("/'([^']+)'/", $matches[1], $valueMatches);
                if (!empty($valueMatches[1])) {
                    $valuesArray = "['" . implode("', '", $valueMatches[1]) . "']";
                    return "enum({$valuesArray})";
                }
            }
        }
        if (str_contains($type, 'varchar') || str_contains($type, 'char')) {
            preg_match('/\((\d+)\)/', $type, $matches);
            $length = (int)($matches[1] ?? 255);
            return $length === 255 ? "string('{$name}')" : "string('{$name}', {$length})";
        }

        return 'string';
    }

    /**
     * 获取默认值
     */
    protected function getDefaultValue(object $column): string
    {
        if ($column->Default === null) {
            return '';
        }

        if ($column->Default === 'CURRENT_TIMESTAMP') {
            return '->useCurrent()';
        }

        if (is_numeric($column->Default)) {
            return "->default({$column->Default})";
        }

        $escapedDefault = $this->escapeString((string)$column->Default);
        return "->default('{$escapedDefault}')";
    }

    /**
     * 格式化 SQL 值
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

