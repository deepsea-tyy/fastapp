<?php
declare(strict_types=1);

namespace App\Command\Generator;

use Hyperf\Stringable\Str;

class GenRuleMap
{
    /**
     * 获取字段后缀到Element Plus组件的映射关系
     *
     * @return array 字段后缀与组件的对应关系
     */
    public static function getFieldSuffixMap(): array
    {
        return [
            // 状态类字段，使用开关组件
            '_enabled' => 'el-switch',
            '_disabled' => 'el-switch',
            '_is_' => 'el-switch',
            // 图片、文件字段
            '_image' => 'ma-upload-image',
            '_cover' => 'ma-upload-image',
            '_img' => 'ma-upload-image',
            '_photo' => 'ma-upload-image',
            '_avatar' => 'ma-upload-image',
            '_logo' => 'ma-upload-image',
            '_file' => 'ma-upload-file',
            '_attachment' => 'ma-upload-file',
            // 日期时间字段
            '_time' => 'el-date-picker',
            '_date' => 'el-date-picker',
            '_datetime' => 'el-date-picker',
            '_at' => 'el-date-picker',
            // 富文本字段
            '_content' => 'el-editor',
            '_body' => 'el-editor',
            '_text' => 'el-editor',
            '_html' => 'el-editor',
            // 数字相关字段
            '_price' => 'el-input-number',
            '_amount' => 'el-input-number',
            '_qty' => 'el-input-number',
            '_count' => 'el-input-number',
            '_number' => 'el-input-number',
            '_num' => 'el-input-number',
            // 选择器
            '_type' => 'el-select',
            '_category' => 'el-select',
            '_level' => 'el-select',
            '_role' => 'el-select',
            '_permission' => 'el-select',
            '_status' => 'el-select',
            '_state' => 'el-select',
            '_flag' => 'el-select',
            // 颜色选择器
            '_color' => 'el-color-picker',
            // 评分
            '_rate' => 'el-rate',
            '_rating' => 'el-rate',
            // 关联类
            '_id' => 'el-select',
            // 默认为输入框
            'default' => 'el-input'
        ];
    }

    /**
     * 获取字段前缀到Element Plus组件的映射关系
     *
     * @return array 字段前缀与组件的对应关系
     */
    public static function getFieldPrefixMap(): array
    {
        return [
            'is_' => 'el-switch',
            'has_' => 'el-switch',
            'can_' => 'el-switch',
        ];
    }

    /**
     * 获取字段包含特定字符串到Element Plus组件的映射关系
     *
     * @return array 字段包含特定字符串与组件的对应关系
     */
    public static function getFieldContainsMap(): array
    {
        return [
            'password' => 'el-input',  // 密码输入框类型会在生成器中处理
            'email' => 'el-input',     // 邮箱验证会在生成器中处理
            'phone' => 'el-input',     // 电话验证会在生成器中处理
            'mobile' => 'el-input',    // 手机验证会在生成器中处理
            'url' => 'el-input',       // URL验证会在生成器中处理
            'color' => 'el-color-picker',

            'attr' => 'el-select',
            'type' => 'el-select',
            'category' => 'el-select',
            'level' => 'el-select',
            'role' => 'el-select',
            'permission' => 'el-select',
            'status' => 'el-select',
            'state' => 'el-select',
            'flag' => 'el-select',

            'logo' => 'ma-upload-image',
            'avatar' => 'ma-upload-image',
            'image' => 'ma-upload-image',
            'img' => 'ma-upload-image',
            'cover' => 'ma-upload-image',
            'icon' => 'ma-upload-image',
            'photo' => 'ma-upload-image',

            'file' => 'ma-upload-file',
            'attachment' => 'ma-upload-file',

            'content' => 'el-editor',
            'body' => 'el-editor',
            'text' => 'el-editor',
            'html' => 'el-editor',
        ];
    }

    /**
     * 获取输出目录
     */
    public static function getOutputDirMap(string $module, string $tableName, string $plugin = '', string $target = 'admin'): array
    {
        $camelCaseName = Str::camel($tableName);

        // 插件模式下的路径
        if (!empty($plugin)) {
            $pluginParts = explode('/', $plugin);
            $pluginPath = implode('/', array_map('strtolower', $pluginParts));
            $base = BASE_PATH . '/plugin/' . $pluginPath;
            return [
                'api-ts' => $base . '/web/api',
                'form-vue' => $base . '/web/views/' . $camelCaseName,
                'index-vue' => $base . '/web/views/' . $camelCaseName,
                'getFormItems-tsx' => $base . '/web/views/' . $camelCaseName . '/data',
                'getTableColumns-tsx' => $base . '/web/views/' . $camelCaseName . '/data',
                'getSearchItems-tsx' => $base . '/web/views/' . $camelCaseName . '/data',
                'model' => $base . '/src/Model',
                'repository' => $base . '/src/Repository',
                'controller' => $target === 'api'
                    ? $base . '/src/Http/Api/Controller'
                    : $base . '/src/Http/Admin/Controller',
                'request' => $target === 'api'
                    ? $base . '/src/Http/Api/Request'
                    : $base . '/src/Http/Admin/Request',
                'service' => $target === 'api'
                    ? $base . '/src/Http/Api/Service'
                    : $base . '/src/Http/Admin/Service',
                'middleware' => $target === 'api'
                    ? $base . '/src/Http/Api/Middleware'
                    : $base . '/src/Http/Admin/Middleware',
                'sql' => $base . '/Database/Migrations',
            ];
        }

        // 默认模式
        return [
            'api-ts' => BASE_PATH . '/web/src/modules/' . $module . '/api',
            'form-vue' => BASE_PATH . '/web/src/modules/' . $module . '/views/' . $camelCaseName,
            'index-vue' => BASE_PATH . '/web/src/modules/' . $module . '/views/' . $camelCaseName,
            'getFormItems-tsx' => BASE_PATH . '/web/src/modules/' . $module . '/views/' . $camelCaseName . '/data',
            'getTableColumns-tsx' => BASE_PATH . '/web/src/modules/' . $module . '/views/' . $camelCaseName . '/data',
            'getSearchItems-tsx' => BASE_PATH . '/web/src/modules/' . $module . '/views/' . $camelCaseName . '/data',
            'model' => BASE_PATH . '/app/Model/' . Str::studly($module),
            'repository' => BASE_PATH . '/app/Repository/' . Str::studly($module),
            'controller' => $target === 'api'
                ? BASE_PATH . '/app/Http/Api/Controller/' . Str::studly($module)
                : BASE_PATH . '/app/Http/Admin/Controller/' . Str::studly($module),
            'request' => $target === 'api'
                ? BASE_PATH . '/app/Http/Api/Request/' . Str::studly($module)
                : BASE_PATH . '/app/Http/Admin/Request/' . Str::studly($module),
            'service' => $target === 'api'
                ? BASE_PATH . '/app/Http/Api/Service/' . Str::studly($module)
                : BASE_PATH . '/app/Http/Admin/Service/' . Str::studly($module),
            'middleware' => $target === 'api'
                ? BASE_PATH . '/app/Http/Api/Middleware'
                : BASE_PATH . '/app/Http/Admin/Middleware',
            'sql' => BASE_PATH . '/databases/seeders',
        ];
    }

    /**
     * 获取模板文件目录映射关系
     *
     * @return array 输出文件类型与模板文件的映射关系
     */
    public static function getTemplateDirMap(): array
    {
        $templateDir = __DIR__ . '/stub';
        return [
            'api-ts' => $templateDir . '/frontend/api-ts.blade.stub',
            'form-vue' => $templateDir . '/frontend/form-vue.blade.stub',
            'index-vue' => $templateDir . '/frontend/index-vue.blade.stub',
            'getFormItems-tsx' => $templateDir . '/frontend/getFormItems-tsx.blade.stub',
            'getTableColumns-tsx' => $templateDir . '/frontend/getTableColumns-tsx.blade.stub',
            'getSearchItems-tsx' => $templateDir . '/frontend/getSearchItems-tsx.blade.stub',
            'controller' => $templateDir . '/controller.blade.stub',
            'model' => $templateDir . '/model.blade.stub',
            'request' => $templateDir . '/request.blade.stub',
            'service' => $templateDir . '/service.blade.stub',
            'repository' => $templateDir . '/repository.blade.stub',
            'sql' => $templateDir . '/sql.blade.stub',
        ];
    }

    public static function formatFileName(string $tableName, string $type): string
    {
        $tableName = Str::studly($tableName);
        $camelCaseName = Str::camel($tableName);
        $fileNameMap = [
            'api-ts' => $camelCaseName . '.ts',
            'form-vue' => 'form.vue',
            'index-vue' => 'index.vue',
            'getFormItems-tsx' => 'getFormItems.tsx',
            'getTableColumns-tsx' => 'getTableColumns.tsx',
            'getSearchItems-tsx' => 'getSearchItems.tsx',
            'controller' => $tableName . 'Controller.stub',
            'model' => $tableName . '.stub',
            'request' => $tableName . 'Request.stub',
            'service' => $tableName . 'Service.stub',
            'middleware' => $tableName . 'Middleware.stub',
            'repository' => $tableName . 'Repository.stub',
            'sql' => $tableName . '_menu.sql',
        ];
        return $fileNameMap[$type];
    }
}
