<?php

declare(strict_types=1);

namespace App\Http\Api\Request\Example;

use App\Common\Request\Traits\ActionRulesTrait;
use Hyperf\Validation\Request\FormRequest;

/**
 * 数组验证示例（包含一维和二维数组）
 *
 * 请求数据示例：
 * {
 *   // 一维数组示例
 *   "tags": ["php", "laravel", "hyperf"],
 *   "ids": [1, 2, 3, 4, 5],
 *   "emails": ["user1@example.com", "user2@example.com"],
 *
 *   // 二维数组示例
 *   "users": [
 *     {"name": "张三", "email": "zhangsan@example.com", "age": 25},
 *     {"name": "李四", "email": "lisi@example.com", "age": 30}
 *   ],
 *   "items": [
 *     {"id": 1, "quantity": 2, "price": 99.99},
 *     {"id": 2, "quantity": 3, "price": 199.99}
 *   ],
 *
 *   // 字典数组示例（关联数组，key-value 对）
 *   "config": {
 *     "app_name": "My App",
 *     "timeout": 30,
 *     "debug": true
 *   },
 *   "metadata": {
 *     "color": "#FF0000",
 *     "size": "large",
 *     "weight": 100
 *   }
 * }
 */
class ArrayValidationRequest extends FormRequest
{
    use ActionRulesTrait;

    public function authorize(): bool
    {
        return true;
    }

    public function commonRules(): array
    {
        return [
            // ============ 一维数组验证 ============

            // 示例1: 验证字符串数组
            'tags' => ['required', 'array', 'min:1', 'max:10'],
            'tags.*' => ['required', 'string', 'max:50'],

            // 示例2: 验证整数数组
            'ids' => ['sometimes', 'array'],
            'ids.*' => ['required', 'integer', 'min:1'],

            // 示例3: 验证邮箱数组
            'emails' => ['sometimes', 'array'],
            'emails.*' => ['required', 'email', 'distinct'], // distinct 确保数组中无重复

            // 示例4: 验证枚举值数组
            'statuses' => ['sometimes', 'array'],
            'statuses.*' => ['required', 'in:pending,approved,rejected'],

            // 示例5: 验证数字范围数组
            'scores' => ['sometimes', 'array'],
            'scores.*' => ['required', 'numeric', 'between:0,100'],

            // ============ 二维数组验证 ============

            // 示例1: 验证用户列表（对象数组）
            'users' => ['required', 'array', 'min:1'],
            'users.*' => ['required', 'array'],
            'users.*.name' => ['required', 'string', 'max:50'],
            'users.*.email' => ['required', 'email'],
            'users.*.age' => ['required', 'integer', 'min:1', 'max:120'],

            // 示例2: 验证商品列表（购物车场景）
            'items' => ['sometimes', 'array'],
            'items.*' => ['required', 'array'],
            'items.*.id' => ['required', 'integer', 'exists:products,id'],
            'items.*.quantity' => ['required', 'integer', 'min:1', 'max:999'],
            'items.*.price' => ['required', 'numeric', 'min:0'],

            // 示例3: 验证分类和标签（嵌套数组）
            'categories' => ['sometimes', 'array'],
            'categories.*' => ['required', 'array'],
            'categories.*.id' => ['required', 'integer'],
            'categories.*.name' => ['required', 'string', 'max:50'],
            'categories.*.tags' => ['sometimes', 'array'],
            'categories.*.tags.*' => ['required', 'string', 'max:30'],

            // ============ 字典数组验证（关联数组）============

            // 示例1: 验证配置项（固定键名）
            'config' => ['required', 'array'],
            'config.app_name' => ['required', 'string', 'max:100'],
            'config.timeout' => ['required', 'integer', 'min:1', 'max:300'],
            'config.debug' => ['required', 'boolean'],

            // 示例2: 验证元数据（部分键可选）
            'metadata' => ['sometimes', 'array'],
            'metadata.color' => ['sometimes', 'string', 'regex:/^#[0-9A-Fa-f]{6}$/'], // 十六进制颜色
            'metadata.size' => ['sometimes', 'string', 'in:small,medium,large'],
            'metadata.weight' => ['sometimes', 'numeric', 'min:0'],

            // 示例3: 验证动态键名的字典（任意键名）
            'attributes' => ['sometimes', 'array'],
            'attributes.*' => ['required', 'string', 'max:200'], // 所有键的值都必须是字符串

            // 示例4: 验证多语言内容（特定语言键）
            'translations' => ['sometimes', 'array'],
            'translations.zh_CN' => ['required', 'string', 'max:500'],
            'translations.en_US' => ['required', 'string', 'max:500'],
            'translations.ja_JP' => ['sometimes', 'string', 'max:500'],
        ];
    }

    public function attributes(): array
    {
        return [
            // 一维数组
            'tags' => '标签',
            'tags.*' => '标签项',
            'ids' => 'ID列表',
            'ids.*' => 'ID',
            'emails' => '邮箱列表',
            'emails.*' => '邮箱',
            'statuses' => '状态列表',
            'statuses.*' => '状态',
            'scores' => '分数列表',
            'scores.*' => '分数',

            // 二维数组
            'users' => '用户列表',
            'users.*' => '用户信息',
            'users.*.name' => '用户姓名',
            'users.*.email' => '用户邮箱',
            'users.*.age' => '用户年龄',

            'items' => '商品列表',
            'items.*' => '商品信息',
            'items.*.id' => '商品ID',
            'items.*.quantity' => '商品数量',
            'items.*.price' => '商品价格',

            'categories' => '分类列表',
            'categories.*' => '分类信息',
            'categories.*.tags' => '分类标签',

            // 字典数组
            'config' => '配置项',
            'config.app_name' => '应用名称',
            'config.timeout' => '超时时间',
            'config.debug' => '调试模式',

            'metadata' => '元数据',
            'metadata.color' => '颜色',
            'metadata.size' => '尺寸',
            'metadata.weight' => '权重',

            'attributes' => '属性',
            'attributes.*' => '属性值',

            'translations' => '翻译内容',
            'translations.zh_CN' => '中文翻译',
            'translations.en_US' => '英文翻译',
            'translations.ja_JP' => '日文翻译',
        ];
    }

    public function messages(): array
    {
        return [
            'tags.*.max' => '标签长度不能超过 :max 个字符',
            'emails.*.distinct' => '邮箱列表中存在重复项',
            'items.*.id.exists' => '商品不存在',
            'metadata.color.regex' => '颜色格式必须为十六进制（如：#FF0000）',
            'config.timeout.between' => '超时时间必须在 :min 到 :max 秒之间',
        ];
    }
}
