<?php

declare(strict_types=1);


namespace App\Command\Generator;

use Hyperf\Command\Annotation\AsCommand;
use Hyperf\Command\Command;
use Hyperf\Context\ApplicationContext;
use Hyperf\DbConnection\Db;
use Hyperf\Stringable\Str;
use Hyperf\View\Render;
use Nette\Utils\FileSystem;
use Symfony\Component\Finder\SplFileInfo;

class GenerateCodeCommand extends Command
{
    /**
     * 表单字段列表（不参与表单生成）
     */
    private const SKIP_FORM_FIELDS = ['id', 'created_at', 'updated_at', 'deleted_at', 'created_by', 'updated_by'];

    /**
     * 表格字段列表（不参与表格显示）
     */
    private const SKIP_TABLE_FIELDS = ['created_at', 'updated_at', 'created_by', 'updated_by', 'remark'];

    /**
     * 翻译字段列表（使用全局翻译 crud.field）
     */
    private const TRANS_FIELD = ['status', 'remark', 'sort', 'createdBy', 'updatedBy', 'createdAt', 'updatedAt',];

    /**
     * 大文本类型列表（不参与列表显示）
     */
    private const LARGE_TEXT_TYPES = ['text', 'mediumtext', 'longtext', 'blob', 'mediumblob', 'longblob', 'json', 'jsonb'];

    /**
     * 可排序的数据库类型
     */
    private const SORTABLE_TYPES = ['int', 'tinyint', 'smallint', 'bigint', 'decimal', 'float', 'double', 'datetime', 'date', 'timestamp'];

    /**
     * 菜单权限操作列表
     */
    private const MENU_ACTIONS = [
        ['action' => 'list', 'title' => 'List', 'i18n' => 'crud.list', 'hidden' => false],
        ['action' => 'create', 'title' => 'Add', 'i18n' => 'crud.add', 'hidden' => true],
        ['action' => 'save', 'title' => 'Edit', 'i18n' => 'crud.edit', 'hidden' => true],
        ['action' => 'delete', 'title' => 'Delete', 'i18n' => 'crud.delete', 'hidden' => true],
    ];

    /**
     * 命令执行.
     */
    #[AsCommand(
        signature: 'ds:generate-crud {--table=} {--module=} {--force=} {--pid=} {--sql=} {--plugin=} {--target=}',
        description: '根据数据库表生成CRUD代码',
        aliases: ['ds:crud'],
    )]
    public function handle(): int
    {
        $tableName = $this->input->getOption('table');
        $fullTableName = env('DB_PREFIX') . $tableName;
        $force = (bool)$this->input->getOption('force') ?? false;
        $plugin = $this->input->getOption('plugin') ?? '';
        $target = $this->input->getOption('target') ?? 'admin';

        $tmpPath = BASE_PATH . '/storage/view/ds-curd';
        if (!is_dir($tmpPath)) {
            $filesystem = new \Hyperf\Support\Filesystem\Filesystem();
            $files = $filesystem->files(BASE_PATH . '/app/Command/Generator/stub');
            foreach ($files as $file) {
                Filesystem::copy($file->getRealPath(), $tmpPath . '/' . str_replace('stub', 'php', $file->getFilename()));
            }
            $files = $filesystem->files(BASE_PATH . '/app/Command/Generator/stub/frontend');
            foreach ($files as $file) {
                Filesystem::copy($file->getRealPath(), $tmpPath . '/frontend/' . str_replace('stub', 'php', $file->getFilename()));
            }
        }

        try {
            // 获取表结构
            $columns = Db::select("SHOW FULL COLUMNS FROM `{$fullTableName}`");

            // 生成表信息
            $tableInfo = $this->generateTableInfo($tableName);

            // 生成表单信息(名称、组件、字段、注释，类型、排序等信息)
            $formFields = $this->generateFormFields($columns, $tableInfo);

            // 生成代码生成器数据
            $codeGenerator = $this->generateCodeGeneratorData($tableInfo, $formFields);
            $codeGenerator = $this->handleCodeGeneratorByJson($codeGenerator, $force);
            // 设置过滤字段列表：tableFl用于表格，formFl用于表单
            $codeGenerator['tableFl'] = self::SKIP_TABLE_FIELDS;
            $codeGenerator['formFl'] = self::SKIP_FORM_FIELDS;
            // 设置翻译字段列表（使用全局翻译 crud.field）
            $codeGenerator['transFl'] = self::TRANS_FIELD;

            // 设置插件信息和目标类型
            $codeGenerator['plugin'] = $plugin;
            $codeGenerator['target'] = $target;

            // 生成后端代码
            $this->generateModel($codeGenerator, $force);
            $this->generateRequest($codeGenerator, $force);
            $this->generateService($codeGenerator, $force);
            $this->generateController($codeGenerator, $force);
            $this->generateRepository($codeGenerator, $force);

            // 根据target参数决定是否生成前端代码
            if ($target !== 'api') {
                // 生成前端模板
                $this->generateForm($codeGenerator, $force);
                $this->generateFormItems($codeGenerator, $force);
                $this->generateTableColumns($codeGenerator, $force);
                $this->generateSearchItems($codeGenerator, $force);
                $this->generateIndex($codeGenerator, $force);
                $this->generateApi($codeGenerator, $force);

                // 生成语言包
                $this->generateLocales($codeGenerator, $force);
                // 生成菜单sql文件
                $this->generateSql($codeGenerator, $force);
            }
            $this->line('CRUD代码生成完成!');
            return self::SUCCESS;
        } catch (\Exception $e) {
            $this->error('代码生成失败: ' . $e->getMessage());
            return self::FAILURE;
        }
    }

    protected function handleCodeGeneratorByJson(array $codeGenerator, bool $force): array
    {
        // 判断json文件是否存在
        $jsonFilePath = BASE_PATH . '/runtime/json/' . $codeGenerator['table']['camelCase'] . '.json';
        if (!file_exists($jsonFilePath) || $force) $this->generateJson($codeGenerator, $force);
        return $codeGenerator;
    }

    protected function generateJson(array $codeGenerator, bool $force): bool
    {
        $jsonDir = BASE_PATH . '/runtime/json/';
        $jsonFilePath = $jsonDir . $codeGenerator['table']['camelCase'] . '.json';

        if (file_exists($jsonFilePath) && !$force) {
            $this->line("json文件 {$jsonFilePath} 已存在，跳过生成");
            return false;
        }

        $this->createDirectory($jsonDir);

        // 提取搜索字段
        $searchFields = [];
        // 提取表格字段
        $tableFields = ['id']; // 默认包含id字段
        // 提取排序字段
        $sortFields = [];
        // 提取表单字段
        $formFields = [];

        foreach ($codeGenerator['formFields'] as $field) {
            // 处理搜索字段
            if ($field['is_query']) {
                $searchFields[] = $field['field'];
            }

            // 处理表格字段
            if ($field['is_list']) {
                $tableFields[] = $field['field'];
            }

            // 处理排序字段
            if ($field['sortable']) {
                $sortFields[] = $field['field'];
            }

            $labelMsg = $field['label'];
            if (str_contains($labelMsg, ':')) {
                $parts = explode(':', $labelMsg, 2);
                $labelMsg = trim($parts[0]);
            }

            // 处理表单字段
            if ($field['is_form']) {
                $formField = [
                    'prop' => $field['field'],
                    'label' => $labelMsg,
                    'render' => $this->getRenderComponent($field['component'], $field['component_config']),
                    'requestRule' => $field['required'] ? ['required'] : ['sometimes'],
                ];

                // 添加requestRule字段
                if (isset($field['requestRules']) && \is_array($field['requestRules'])) {
                    $formField['requestRule'] = $field['requestRules'];
                }

                // 添加renderProps字段
                $renderPropsObj = [];

                // 添加placeholder

                $renderPropsObj['placeholder'] = 't(\'form.' . ($field['component'] === 'el-input' ? 'pleaseInput' : 'pleaseSelect') . '\', { msg: \'' . $labelMsg . '\' })';

                // 根据组件类型设置不同的属性
                if ($field['component'] === 'el-input-number') {
                    $renderPropsObj['min'] = 0;
                    $renderPropsObj['precision'] = 2;
                } elseif (str_contains($field['field'], 'description') || str_contains($field['field'], 'remark') || $field['component'] === 'el-editor') {
                    $renderPropsObj['type'] = 'textarea';
                    $renderPropsObj['rows'] = 3;
                } elseif ($field['component'] === 'ma-upload-file') {
                    $renderPropsObj['title'] = '文件上传';
                    $renderPropsObj['fileSize'] = 10 * 1024 * 1024;
                    $renderPropsObj['fileType'] = ['doc', 'xls', 'ppt', 'txt', 'pdf'];
                    $renderPropsObj['limit'] = 1;
                    $renderPropsObj['multiple'] = false;
                } elseif (($field['component'] === 'el-select' || $field['component'] === 'el-switch') && !empty($field['component_config'])) {
                    $renderPropsObj = array_merge($renderPropsObj, $field['component_config']);
                }

                $formField['renderProps'] = $renderPropsObj;
                $formFields[] = $formField;
            }
        }

        // 构建JSON数据
        $jsonData = [
            'searchFields' => $searchFields,
            'tableFields' => $tableFields,
            'sortFields' => $sortFields,
            'formFields' => $formFields,
        ];

        $jsonContent = json_encode($jsonData, \JSON_PRETTY_PRINT | \JSON_UNESCAPED_UNICODE);
        file_put_contents($jsonFilePath, $jsonContent);

        $this->info("已生成json文件: {$jsonFilePath}");
        return true;
    }

    /**
     * 获取表单渲染组件.
     */
    protected function getRenderComponent(string $componentType, array $config = []): string
    {
        return match ($componentType) {
            'el-input' => '<el-input />',
            'el-input-number' => '<el-input-number />',
            'el-select' => '<el-select />',
            'el-date-picker' => '<el-date-picker />',
            'el-switch' => '<el-switch />',
            'el-radio' => '<el-radio />',
            'el-checkbox' => '<el-checkbox />',
            'ma-upload-image' => '<ma-upload-image />',
            'ma-upload-file' => '<ma-upload-file />',
            'ma-dict-select' => '<ma-dict-select />',
            'NmTinyMCE' => '<NmTinyMCE height={300}/>',
            default => '<el-input />'
        };
    }

    /**
     * 生成表信息.
     * @param string $tableName
     *                          ${className}
     */
    protected function generateTableInfo(string $tableName): array
    {
        // 获取表主键
        $fullTableName = env('DB_PREFIX') . $tableName;
        $res = Db::select("SHOW KEYS FROM {$fullTableName} WHERE Key_name = 'PRIMARY'");
        $primaryKey = $res[0]->Column_name;

        // 获取表注释
        $tableComment = Db::selectOne('
                select table_comment
                FROM information_schema.tables
                WHERE table_schema = ?
                AND table_name = ?
            ', [env('DB_DATABASE'), $fullTableName])->TABLE_COMMENT ?? $tableName;

        $camelCaseName = Str::camel($tableName);
        // 生成表信息
        return [
            'pid' => (int)$this->input->getOption('pid') ?? 0,
            'name' => $tableName,
            'comment' => $tableComment,
            'camelCase' => $camelCaseName,
            'pascalCase' => ucfirst($camelCaseName),
            'primaryKey' => $primaryKey,
        ];
    }

    /**
     * 生成表单字段.
     */
    protected function generateFormFields(array $columns, array $tableInfo): array
    {
        $formFields = [];
        $fieldSuffixMap = GenRuleMap::getFieldSuffixMap();
        $fieldPrefixMap = GenRuleMap::getFieldPrefixMap();
        $fieldContainsMap = GenRuleMap::getFieldContainsMap();

        foreach ($columns as $column) {
            $field = $column->Field;

            // 跳过主键
            if ($field === 'id') {
                continue;
            }

            // 确定组件类型
            $componentType = $this->determineComponentType($field, $fieldSuffixMap, $fieldPrefixMap, $fieldContainsMap);

            // 判断是否为列表字段
            $isList = $this->isListField($column->Type, $field);

            // 组件配置和查询条件
            [$isQuery, $componentConfig] = $this->getComponentConfig($field, $column, $componentType);

            // 判断是否表单字段
            $isForm = $this->isFormField($field);

            // 简化数据库类型
            $dbType = $this->simplifyDbType($column->Type);

            // 读取字段注释，获取注释中[]中的内容
            $filedComment = $column->Comment;
            preg_match('/\[(.*?)\]/', $filedComment, $matches);
            $required = false;
            if (!empty($matches[1])) {
                $rules = explode(',', $matches[1]);
                $trimRules = array_map(static function ($item) {
                    return trim($item);
                }, $rules);
                $required = \in_array('required', $trimRules, true);
                $isQuery = $isQuery ?: \in_array('search', $trimRules, true);
                if (\in_array('hidden', $trimRules, true)) {
                    $isList = false;
                    $isQuery = false;
                }
                $filedComment = str_replace($matches[0], '', $filedComment);
            }

            // 创建renderProps
            $renderPropsObj = [];

//            $msg = $filedComment ?: $this->formatFieldName($field);
            $module = $this->input->getOption('module');
            $modelName = $tableInfo['pascalCase'];
            $msg = "t('$module.{$modelName}Fields.$field')";
            // 添加placeholder
            $placeholder = 't(\'form.' . ($componentType === 'el-input' ? 'pleaseInput' : 'pleaseSelect') . '\', { msg: ' . $msg . ' })';
            $renderPropsObj['placeholder'] = $placeholder;

            // 根据组件类型设置不同的属性
            if ($componentType === 'el-input-number') {
                $renderPropsObj['min'] = 0;
                $renderPropsObj['precision'] = 2;
            } elseif (str_contains($field, 'description') || str_contains($field, 'remark') || $componentType === 'el-editor') {
                $renderPropsObj['type'] = 'textarea';
                $renderPropsObj['rows'] = 3;
            } elseif ($componentType === 'ma-upload-file') {
                $renderPropsObj['title'] = '文件上传';
                $renderPropsObj['fileSize'] = 10 * 1024 * 1024;
                $renderPropsObj['fileType'] = ['doc', 'xls', 'ppt', 'txt', 'pdf'];
                $renderPropsObj['limit'] = 1;
                $renderPropsObj['multiple'] = false;
            } elseif (($componentType === 'el-select' || $componentType === 'el-switch') && !empty($componentConfig)) {
                $renderPropsObj = array_merge($renderPropsObj, $componentConfig);
            }

            // 判断字段是否可以为null
            $nullable = isset($column->Null) && strtoupper($column->Null) === 'YES';

            $formFields[] = [
                'field' => $field,
                'is_list' => $isList,
                'is_query' => $isQuery,
                'is_form' => $isForm,
                'label' => $filedComment ?: $this->formatFieldName($field),
                'component' => $componentType,
                'component_config' => $componentConfig,
                'renderProps' => $renderPropsObj,
                'required' => $required,
                'default' => $column->Default,
                'comment' => $filedComment,
                'dbType' => $dbType,
                'sortable' => \in_array($dbType, self::SORTABLE_TYPES, true),
                'nullable' => $nullable,
                'requestRules' => $this->generateRequestRules($field, $dbType, $componentType, $required),
            ];
        }

        return $formFields;
    }

    /**
     * 判断是否为列表字段.
     */
    protected function isListField(string $dbType, string $field): bool
    {
        return !\in_array($dbType, self::LARGE_TEXT_TYPES, true)
            && !str_contains($field, 'description')
            && !str_contains($field, 'content')
            && !str_contains($field, 'password')
            && !str_contains($field, 'deleted_at');
    }

    /**
     * 判断是否为表单字段.
     */
    protected function isFormField(string $field): bool
    {
        foreach (self::SKIP_FORM_FIELDS as $systemField) {
            if (str_contains($field, $systemField)) {
                return false;
            }
        }
        return true;
    }

    /**
     * 确定字段对应的组件类型.
     */
    protected function determineComponentType(string $field, array $fieldSuffixMap, array $fieldPrefixMap, array $fieldContainsMap): string
    {
        $componentType = 'el-input'; // 默认组件类型

        // 匹配字段后缀
        foreach ($fieldSuffixMap as $suffix => $component) {
            if ($suffix !== 'default' && str_ends_with($field, $suffix)) {
                return $component;
            }
        }

        // 匹配字段前缀
        foreach ($fieldPrefixMap as $prefix => $component) {
            if (str_starts_with($field, $prefix)) {
                return $component;
            }
        }

        // 匹配字段包含特定字符串
        foreach ($fieldContainsMap as $contains => $component) {
            if (str_contains($field, $contains)) {
                return $component;
            }
        }

        return $componentType;
    }

    /**
     * 获取组件配置和查询条件.
     */
    protected function getComponentConfig(string $field, object $column, string $componentType): array
    {
        $componentConfig = [];
        $isQuery = false;

        // 根据字段名确定是否可查询
        if (in_array($field, ['mobile', 'username', 'email', 'status', 'type', 'category_id', 'parent_id'])) {
            $isQuery = true;
        }

        // 解析注释中的枚举值
        if (str_contains($column->Comment, ':') && str_contains($column->Comment, '=')) {
            $comment = explode(':', $column->Comment);
            $comment = trim($comment[1]);
            $comment = explode(',', $comment);
            if (\count($comment) > 1) {
                $componentData = array_map(static function ($item) {
                    $item = explode('=', $item);
                    return ['label' => trim($item[1] ?? ''), 'value' => (int)trim($item[0] ?? '')];
                }, $comment);
                if ($componentType === 'el-switch' || $componentType === 'el-select' || $componentType === 'el-radio') {
                    $isQuery = true;
                    $componentConfig = [
                        'clearable' => true,
                        'data' => $componentData,
                    ];
                }
            }
        }

        // 日期选择器配置
        if ($componentType === 'el-date-picker' && !\in_array($field, ['updated_at', 'deleted_at'], true)) {
            $isQuery = true;
            $componentConfig = [
                'clearable' => true,
                'type' => 'daterange',
                'valueFormat' => 'YYYY-MM-DD',
            ];
        }

        return [$isQuery, $componentConfig];
    }

    /**
     * 简化数据库类型.
     */
    protected function simplifyDbType(string $dbType): string
    {
        return match (true) {
            str_contains($dbType, 'int') => 'int',
            str_contains($dbType, 'decimal') => 'decimal',
            str_contains($dbType, 'bigint') => 'bigint',
            str_contains($dbType, 'varchar') => 'varchar',
            default => $dbType,
        };
    }

    /**
     * 生成代码生成器数据.
     */
    protected function generateCodeGeneratorData(array $tableInfo, array $formFields): array
    {
        return [
            'table' => $tableInfo,
            'module' => $this->input->getOption('module'),
            'formFields' => $formFields,
            'date' => date('Y-m-d H:i:s'),
            'year' => date('Y'),
        ];
    }

    /**
     * 生成模型代码
     */
    protected function generateModel(array $codeGenerator, bool $force = false): bool
    {
        return $this->generateFile($codeGenerator, $force, 'model', '.php');
    }

    /**
     * 生成request验证器.
     */
    protected function generateRequest(array $codeGenerator, bool $force): bool
    {
        return $this->generateFile($codeGenerator, $force, 'request', '.php');
    }

    /**
     * 生成service代码
     */
    protected function generateService(array $codeGenerator, bool $force): bool
    {
        return $this->generateFile($codeGenerator, $force, 'service', '.php');
    }

    /**
     * 生成控制器代码
     */
    protected function generateController(array $codeGenerator, bool $force): bool
    {
        return $this->generateFile($codeGenerator, $force, 'controller', '.php');
    }

    /**
     * 生成repository代码
     */
    protected function generateRepository(array $codeGenerator, bool $force): bool
    {
        return $this->generateFile($codeGenerator, $force, 'repository', '.php');
    }

    /**
     * 生成表单代码
     */
    protected function generateForm(array $codeGenerator, bool $force): bool
    {
        return $this->generateFile($codeGenerator, $force, 'form-vue');
    }

    /**
     * 生成formItems代码
     */
    protected function generateFormItems(array $codeGenerator, bool $force): bool
    {
        return $this->generateFile($codeGenerator, $force, 'getFormItems-tsx');
    }

    /**
     * 生成tableColumns代码
     */
    protected function generateTableColumns(array $codeGenerator, bool $force): bool
    {
        return $this->generateFile($codeGenerator, $force, 'getTableColumns-tsx');
    }

    /**
     * 生成searchItems代码
     */
    protected function generateSearchItems(array $codeGenerator, bool $force): bool
    {
        return $this->generateFile($codeGenerator, $force, 'getSearchItems-tsx');
    }

    /**
     * 生成index代码
     */
    protected function generateIndex(array $codeGenerator, bool $force): bool
    {
        return $this->generateFile($codeGenerator, $force, 'index-vue');
    }

    /**
     * 生成API接口代码
     */
    protected function generateApi(array $codeGenerator, bool $force): bool
    {
        return $this->generateFile($codeGenerator, $force, 'api-ts');
    }

    /**
     * 生成SQL文件
     * 默认只生成SQL文件，不自动执行。如需自动执行，请使用 --sql 选项
     */
    protected function generateSql(array $codeGenerator, bool $force): bool
    {
        $modelName = $codeGenerator['table']['pascalCase'];

        // SQL模板路径
        $sqlTemplatePath = GenRuleMap::getTemplateDirMap()['sql'];

        $sqlDir = BASE_PATH . '/runtime/sql/';
        $sqlFilePath = $sqlDir . $modelName . 'Menu.sql';

        // 判断文件是否存在
        if (file_exists($sqlFilePath) && !$force) {
            $this->error("sql文件 {$sqlFilePath} 已存在，跳过生成");
            return false;
        }

        // 判断目录是否存在
        if (!is_dir($sqlDir)) {
            mkdir($sqlDir, 0o755, true);
        }

        // 渲染SQL模板内容
        $file = $this->renderTemplate($sqlTemplatePath, [
            'codeGenerator' => $codeGenerator,
        ], 'sql');

        // 获取SQL内容
        $sqlContent = $file->getContents();

        // 生成纯SQL文件，用于手动导入
        file_put_contents($sqlFilePath, $sqlContent);

        $this->info("已生成SQL文件: {$sqlFilePath}");

        // 只有当明确指定 --sql 选项时才自动执行SQL
        // 注意：自动执行SQL功能仅支持非插件模式，插件模式请手动执行生成的SQL文件
        if ($this->input->getOption('sql')) {
            $plugin = $codeGenerator['plugin'] ?? '';
            if (!empty($plugin)) {
                $this->warn("插件模式不支持自动执行SQL，请手动执行生成的SQL文件: {$sqlFilePath}");
            } else {
                $this->executeSql($codeGenerator);
                $this->info("已自动执行SQL，菜单数据已插入数据库");
            }
        } else {
            $this->line("提示: 如需自动执行SQL，请使用 --sql 选项");
        }

        return true;
    }

    /**
     * 执行SQL，将菜单数据插入数据库
     * 注意：此方法仅支持非插件模式，插件模式请手动执行生成的SQL文件
     */
    protected function executeSql(array $codeGenerator): bool
    {
        $table = $codeGenerator['table'] ?? [];
        $moduleName = $codeGenerator['module'] ?? '';
        $packageName = mb_strtolower($moduleName);
        $modelName = $table['pascalCase'] ?? '';
        $camelCaseName = $table['camelCase'] ?? '';
        $snakeModelName = Str::snake($modelName);
        $menuName = str_replace('表', '', $table['comment'] ?: $modelName);
        $pid = $table['pid'] ?? 0;
        $time = date('Y-m-d H:i:s');

        $lastMenuId = Db::table('menu')->insertGetId([
            'name' => $camelCaseName,
            'path' => '/' . $packageName . '/' . $camelCaseName,
            'component' => $packageName . '/views/' . $camelCaseName . '/index',
            'redirect' => '',
            'created_by' => 0,
            'updated_by' => 0,
            'remark' => '',
            'meta' => '{"title":"' . $menuName . '","i18n":"' . $packageName . '.' . $modelName . '","icon":"mdi:menu","type":"M","hidden":false,"componentPath":"modules\/","componentSuffix":".vue","breadcrumbEnable":true,"copyright":true,"cache":true,"affix":false}',
            'parent_id' => $pid,
            'updated_at' => $time,
            'created_at' => $time,
        ]);

        // 生成权限菜单数据
        $permissionMenus = [];
        foreach (self::MENU_ACTIONS as $menu) {
            $permissionMenus[] = [
                'name' => "{$packageName}:{$snakeModelName}:{$menu['action']}",
                'meta' => json_encode([
                    'title' => $menu['title'],
                    'i18n' => $menu['i18n'],
                    'icon' => '',
                    'type' => 'B',
                    'hidden' => $menu['hidden'],
                    'componentPath' => "modules/{$packageName}/{$camelCaseName}/",
                    'componentSuffix' => '.vue',
                    'breadcrumbEnable' => true,
                    'cache' => true,
                    'affix' => false,
                ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES),
                'parent_id' => $lastMenuId,
                'updated_at' => $time,
                'created_at' => $time,
            ];
        }

        Db::table('menu')->insert($permissionMenus);

        return true;
    }

    /**
     * 分割SQL文件内容为单独的查询语句.
     *
     * @param string $sql SQL文件内容
     * @return array 查询语句数组
     */
    protected function splitSqlQueries(string $sql): array
    {
        // 移除SQL注释（-- 开头的行注释）
        $sql = preg_replace('/--.*$/m', '', $sql);

        // 移除多行注释 /* ... */
        $sql = preg_replace('/\/\*.*?\*\//s', '', $sql);

        // 规范化换行符
        $sql = str_replace(["\r\n", "\r"], "\n", $sql);
        $sql = trim($sql);

        // 使用更简单的方法：按分号分割，然后检查每个部分是否在字符串内
        $parts = explode(';', $sql);
        $queries = [];
        $currentQuery = '';

        foreach ($parts as $part) {
            $currentQuery .= $part;

            // 检查当前查询是否有未闭合的字符串
            if ($this->isQueryComplete($currentQuery)) {
                $trimmedQuery = trim($currentQuery);
                if (!empty($trimmedQuery)) {
                    $queries[] = $trimmedQuery;
                }
                $currentQuery = '';
            } else {
                // 如果字符串未闭合，添加分号继续
                $currentQuery .= ';';
            }
        }

        // 处理最后一个查询（如果没有分号结尾）
        $currentQuery = trim($currentQuery);
        if (!empty($currentQuery)) {
            $queries[] = $currentQuery;
        }

        return $queries;
    }

    /**
     * 检查SQL查询是否完整（所有字符串都已闭合）.
     */
    protected function isQueryComplete(string $query): bool
    {
        $inSingleQuote = false;
        $inDoubleQuote = false;
        $length = mb_strlen($query);

        for ($i = 0; $i < $length; ++$i) {
            $char = $query[$i];

            // 处理转义字符
            if ($char === '\\' && $i + 1 < $length) {
                ++$i; // 跳过下一个字符
                continue;
            }

            // 处理单引号
            if ($char === "'" && !$inDoubleQuote) {
                $inSingleQuote = !$inSingleQuote;
            }

            // 处理双引号
            if ($char === '"' && !$inSingleQuote) {
                $inDoubleQuote = !$inDoubleQuote;
            }
        }

        // 如果没有未闭合的字符串，则查询完整
        return !$inSingleQuote && !$inDoubleQuote;
    }

    /**
     * 生成语言包.
     */
    protected function generateLocales(array $codeGenerator, bool $force): bool
    {
        $moduleName = $this->input->getOption('module');
        $plugin = $this->input->getOption('plugin');
        $modelName = $codeGenerator['table']['pascalCase'];
        $snakeModelName = Str::snake($modelName);
        $menuName = str_replace('表', '', $codeGenerator['table']['comment'] ?: $modelName);

        // 设置语言包目录
        if ($plugin) $localesDir = BASE_PATH . '/plugin/' . $plugin . '/web/locales';
        else $localesDir = BASE_PATH . '/web/src/modules/' . $moduleName . '/locales';

        // 创建locales目录
        if (!is_dir($localesDir)) {
            $this->createDirectory($localesDir);
        }


        // 定义语言包文件
        $localeFiles = [
            'zh_CN[简体中文].yaml' => [
                $moduleName => [
                    $modelName => $menuName,
                    $modelName . 'Fields' => $this->formatLang($codeGenerator['formFields'], 'zh_CN', $codeGenerator['tableFl']),
                ],
            ],
            'en[English].yaml' => [
                $moduleName => [
                    $modelName => $modelName,
                    $modelName . 'Fields' => $this->formatLang($codeGenerator['formFields'], 'en', $codeGenerator['tableFl']),
                ],
            ],
            'zh_TW[繁體中文].yaml' => [
                $moduleName => [
                    $modelName => $this->translateToTraditional($menuName),
                    $modelName . 'Fields' => $this->formatLang($codeGenerator['formFields'], 'zh_TW', $codeGenerator['tableFl']),
                ],
            ],
        ];
        // 生成语言包文件
        foreach ($localeFiles as $filename => $content) {
            $filePath = $localesDir . '/' . $filename;

            // 如果文件已存在，则合并内容而不是覆盖
            if (file_exists($filePath)) {
                $this->line("语言包文件 {$filePath} 已存在，正在合并内容...");
                $existingContent = file_get_contents($filePath);
                $newContent = $this->mergeYamlContent($existingContent, $content);
                file_put_contents($filePath, $newContent);
                $this->info("已更新语言包文件: {$filePath}");
            } else {
                // 文件不存在，直接创建
                $yamlContent = $this->arrayToYaml($content);
                file_put_contents($filePath, $yamlContent);
                $this->info("已生成语言包文件: {$filePath}");
            }
        }

        return true;
    }

    protected function formatLang(array $field, string $lang, array $fl): array
    {
        $data = [];
        foreach ($field as $value) {
            if (in_array($value['field'], $fl, true)) {
                continue;
            }

            $data[$value['field']] = match ($lang) {
                'zh_CN', 'zh_TW' => $value['label'],
                'en' => Str::studly($value['field']),
                default => $value['label'],
            };
        }
        return $data;
    }

    /**
     * 将简体中文翻译为繁体中文(简单处理).
     */
    protected function translateToTraditional(string $text): string
    {
        // 简体转繁体的基本字符映射
        $simplified = ['个', '专', '业', '丝', '丢', '两', '严', '丧', '乐', '乡', '书', '买', '乱', '争', '于', '亚', '亲', '产', '们', '仅', '仿', '伟', '传', '伤', '伦', '伪', '体', '余', '佣', '侦', '侧', '俩', '保', '信', '俭', '倾', '债', '值', '倾', '假', '偿', '侄', '导'];
        $traditional = ['個', '專', '業', '絲', '丟', '兩', '嚴', '喪', '樂', '鄉', '書', '買', '亂', '爭', '於', '亞', '親', '產', '們', '僅', '仿', '偉', '傳', '傷', '倫', '偽', '體', '餘', '傭', '偵', '側', '倆', '保', '信', '儉', '傾', '債', '值', '傾', '假', '償', '姪', '導'];

        return str_replace($simplified, $traditional, $text);
    }

    /**
     * 合并YAML内容.
     */
    protected function mergeYamlContent(string $existingContent, array $newArray): string
    {
        // 将现有YAML转换为数组
        $existingArray = $this->yamlToArray($existingContent);

        // 递归合并数组
        $mergedArray = $this->arrayMergeRecursive($existingArray, $newArray);

        // 将合并后的数组转换回YAML
        return $this->arrayToYaml($mergedArray);
    }

    /**
     * 简单的YAML转数组.
     */
    protected function yamlToArray(string $yaml): array
    {
        $result = [];
        $lines = explode("\n", $yaml);
        $currentPath = [];
        $indentLevel = 0;

        foreach ($lines as $line) {
            if (empty(trim($line))) {
                continue;
            }

            // 计算缩进级别
            $currentIndent = mb_strlen($line) - mb_strlen(ltrim($line));
            $currentIndent = floor($currentIndent / 2);

            // 调整当前路径
            if ($currentIndent < $indentLevel) {
                $diff = $indentLevel - $currentIndent;
                for ($i = 0; $i < $diff; ++$i) {
                    array_pop($currentPath);
                }
            }
            $indentLevel = $currentIndent;

            // 解析行
            $line = trim($line);
            if (str_contains($line, ':')) {
                [$key, $value] = array_pad(explode(':', $line, 2), 2, '');
                $key = trim($key);
                $value = trim($value);

                if (empty($value)) {
                    // 这是一个父节点
                    $currentPath[] = $key;
                } else {
                    // 这是一个叶子节点
                    $path = $currentPath;
                    $path[] = $key;

                    // 设置值
                    $this->setNestedValue($result, $path, $value);
                }
            }
        }

        return $result;
    }

    /**
     * 设置嵌套数组的值
     *
     * @param mixed $value
     */
    protected function setNestedValue(array &$array, array $path, $value): void
    {
        $key = array_shift($path);

        if (empty($path)) {
            $array[$key] = $value;
        } else {
            if (!isset($array[$key]) || !\is_array($array[$key])) {
                $array[$key] = [];
            }
            $this->setNestedValue($array[$key], $path, $value);
        }
    }

    /**
     * 递归合并数组.
     */
    protected function arrayMergeRecursive(array $array1, array $array2): array
    {
        foreach ($array2 as $key => $value) {
            if (\is_array($value) && isset($array1[$key]) && \is_array($array1[$key])) {
                $array1[$key] = $this->arrayMergeRecursive($array1[$key], $value);
            } else {
                $array1[$key] = $value;
            }
        }

        return $array1;
    }

    /**
     * 用于生成各种文件的通用方法.
     *
     * @param array $codeGenerator 代码生成器数据
     * @param bool $force 是否强制生成
     * @param string $fileType 文件类型
     * @param string $fileNameSuffix 文件后缀名(可选)
     */
    protected function generateFile(array $codeGenerator, bool $force, string $fileType, string $fileNameSuffix = ''): bool
    {
        $modelName = $codeGenerator['table']['pascalCase'];
        $moduleName = $this->input->getOption('module');

        // 获取插件参数和目标类型
        $plugin = $codeGenerator['plugin'] ?? '';
        $target = $codeGenerator['target'] ?? 'admin';

        // 获取输出目录
        $outputDir = GenRuleMap::getOutputDirMap($moduleName, $modelName, $plugin, $target)[$fileType];

        // 使用formatFileName获取文件名
        $fileName = GenRuleMap::formatFileName($codeGenerator['table']['name'], $fileType);

        // 如果提供了文件后缀，添加到文件名中
        if (!empty($fileNameSuffix)) {
            $fileNameParts = pathinfo($fileName);
            $fileName = $fileNameParts['filename'] . $fileNameSuffix;
        }

        $filePath = $outputDir . "/{$fileName}";

        // 检查文件是否存在
        if (file_exists($filePath) && !$force) {
            $this->error("{$fileType}文件 {$filePath} 已存在，跳过生成");
            return false;
        }

        // 获取模板路径
        $templatePath = GenRuleMap::getTemplateDirMap()[$fileType];

        // 渲染模板内容
        $file = $this->renderTemplate($templatePath, [
            'codeGenerator' => $codeGenerator,
        ], $fileType);

        // 确保目录存在
        $this->createDirectory(\dirname($filePath));

        // 写入文件
        file_put_contents($filePath, $file->getContents());

        $this->info("已生成{$fileType}文件: {$filePath}");
        return true;
    }

    /**
     * 渲染模板
     */
    protected function renderTemplate(string $templatePath, array $data, string $type): SplFileInfo
    {
        if (!file_exists($templatePath)) {
            throw new \Exception("模板文件 {$templatePath} 不存在");
        }

        // 只创建一个临时文件
        $tempFile = tempnam(sys_get_temp_dir(), 'Ds_crud_');

        try {
            $container = ApplicationContext::getContainer();
            $render = $container->get(Render::class);

            $templateName = str_replace(['.blade.stub', '.php'], '', basename($templatePath));
            $frontend = mb_strpos($templatePath, 'frontend') !== false ? 'frontend.' : '';
            $viewName = 'ds-curd.' . $frontend . $templateName;

            $content = $render->getContents($viewName, $data);

            file_put_contents($tempFile, $content);
            $tableName = $data['codeGenerator']['table']['name'];
            $moduleName = $this->input->getOption('module');
            $plugin = $data['codeGenerator']['plugin'] ?? '';
            $target = $data['codeGenerator']['target'] ?? 'admin';
            $formatRelativePath = GenRuleMap::getOutputDirMap($moduleName, $tableName, $plugin, $target)[$type];
            $formatFileName = GenRuleMap::formatFileName($tableName, $type);

            // 注册一个shutdown函数来删除临时文件
            register_shutdown_function(static function () use ($tempFile) {
                if (file_exists($tempFile)) {
                    @unlink($tempFile);
                }
            });

            return new SplFileInfo($tempFile, $formatRelativePath, $formatFileName);
        } catch (\Throwable $e) {
            // 删除临时文件
            if (file_exists($tempFile)) {
                @unlink($tempFile);
            }
            throw new \Exception('渲染模板失败: ' . $e->getMessage());
        }
    }

    /**
     * 创建目录.
     */
    protected function createDirectory(string $dir): void
    {
        if (!is_dir($dir)) {
            mkdir($dir, 0o755, true);
        }
    }

    /**
     * 下划线转小驼峰.
     */
    protected function snakeToCamel(string $value): string
    {
        return lcfirst(str_replace(' ', '', ucwords(str_replace('_', ' ', $value))));
    }

    /**
     * 转换为短横线分隔命名.
     */
    protected function kebabCase(string $value): string
    {
        return str_replace('_', '-', $value);
    }

    /**
     * 格式化字段名称.
     */
    protected function formatFieldName(string $field): string
    {
        return match ($field) {
            'created_at' => '创建时间',
            'updated_at' => '更新时间',
            'deleted_at' => '删除时间',
            default => ucfirst(str_replace('_', ' ', $field)),
        };
    }

    /**
     * 将数组转换为YAML格式.
     */
    protected function arrayToYaml(array $array, int $level = 0): string
    {
        $yaml = '';
        $indent = str_repeat('  ', $level);

        foreach ($array as $key => $value) {
            if (\is_array($value)) {
                $yaml .= $indent . $key . ":\n";
                $yaml .= $this->arrayToYaml($value, $level + 1);
            } else {
                $yaml .= $indent . $key . ': ' . $value . "\n";
            }
        }

        return $yaml;
    }

    /**
     * 生成请求验证规则.
     */
    protected function generateRequestRules(string $fieldName, string $dbType, string $componentType, bool $required): array
    {
        // 基础规则
        $rules = $required ? ['required'] : ['sometimes'];

        // 根据字段类型添加验证规则
        if (str_contains($dbType, 'int')) {
            $rules[] = 'integer';
        } elseif (str_contains($dbType, 'decimal') || str_contains($dbType, 'float') || str_contains($dbType, 'double')) {
            $rules[] = 'numeric';
        } elseif (str_contains($dbType, 'date') || str_contains($dbType, 'time')) {
            $rules[] = 'date';
        } elseif (str_contains($dbType, 'json')) {
            $rules[] = 'array';
        }

        // 基于字段名称添加验证规则
        $this->addFieldNameRules($rules, $fieldName);

        // 基于组件类型添加验证规则
        if ($componentType === 'el-input-number') {
            if (!\in_array('numeric', $rules, true) && !\in_array('integer', $rules, true)) {
                $rules[] = 'numeric';
            }
        } elseif ($componentType === 'el-date-picker') {
            if (!\in_array('date', $rules, true)) {
                $rules[] = 'date';
            }
        }
        // 如果验证规则不为空，删除sometimes
        if (\in_array('sometimes', $rules, true) && \count($rules) > 1) {
            $rules = array_values(array_diff($rules, ['sometimes']));
        }

        // 移除重复规则
        return array_unique($rules);
    }

    /**
     * 根据字段名称添加验证规则.
     */
    protected function addFieldNameRules(array &$rules, string $fieldName): void
    {
        if (str_contains($fieldName, 'email')) {
            $rules[] = 'email';
            return;
        }

        if ($fieldName === 'password' || $fieldName === 'pass' || str_ends_with($fieldName, '_password')) {
            $rules[] = 'min:6';
            if ($fieldName === 'password' && !str_contains($fieldName, 'confirm')) {
                $rules[] = 'confirmed';
            }
            return;
        }

        if ($fieldName === 'phone' || $fieldName === 'mobile' || str_ends_with($fieldName, '_phone') || str_ends_with($fieldName, '_mobile')) {
            $rules[] = 'regex:/^1[3456789]\d{9}$/';
            return;
        }

        if ($fieldName === 'ip') {
            $rules[] = 'ip';
            return;
        }

        if ($fieldName === 'age' || str_ends_with($fieldName, '_age')) {
            $rules[] = 'numeric';
            $rules[] = 'min:0';
            $rules[] = 'max:150';
            return;
        }

        if ($fieldName === 'year' || str_ends_with($fieldName, '_year')) {
            $rules[] = 'digits:4';
            return;
        }

        if ($fieldName === 'postal') {
            $rules[] = 'regex:/^\d{6}$/';
            return;
        }

        if (\in_array($fieldName, ['price', 'money', 'amount'], true)) {
            $rules[] = 'numeric';
            $rules[] = 'min:0';
            return;
        }

        if (str_ends_with($fieldName, '_at')) {
            $rules[] = 'date';
            return;
        }

        if (str_ends_with($fieldName, '_status') || $fieldName === 'status') {
            $rules[] = 'integer';
            return;
        }

        if (\in_array($fieldName, ['score', 'rate', 'percent'], true)) {
            $rules[] = 'numeric';
            $rules[] = 'min:0';
            $rules[] = 'max:100';
        }
    }
}
