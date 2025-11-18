<?php

declare(strict_types=1);

namespace App\Http\Admin\Request\Example;

use App\Common\Request\Traits\ActionRulesTrait;
use Hyperf\Validation\Request\FormRequest;

/**
 * 二维数组验证示例
 * 
 * 请求数据示例：
 * {
 *   "matrix": [[1, 2, 3], [4, 5, 6]],
 *   "users": [
 *     {"name": "张三", "email": "zhangsan@example.com", "age": 25},
 *     {"name": "李四", "email": "lisi@example.com", "age": 30}
 *   ],
 *   "items": [
 *     {"id": 1, "quantity": 2, "price": 99.99},
 *     {"id": 2, "quantity": 3, "price": 199.99}
 *   ]
 * }
 */
class TwoDimensionalArrayRequest extends FormRequest
{
    use ActionRulesTrait;

    public function authorize(): bool
    {
        return true;
    }

    public function commonRules(): array
    {
        return [
            // 示例1: 验证二维数字数组（矩阵）
            // 数据格式: [[1,2,3], [4,5,6]]
            'matrix' => ['sometimes', 'array'],
            'matrix.*' => ['required', 'array'],              // 第一层：每个元素必须是数组
            'matrix.*.*' => ['required', 'integer'],           // 第二层：每个元素的每个元素必须是整数

            // 示例2: 验证对象数组（最常见的二维数组场景）
            // 数据格式: [{"name":"张三", "email":"xxx"}, {"name":"李四", "email":"yyy"}]
            'users' => ['required', 'array', 'min:1'],
            'users.*' => ['required', 'array'],                // 每个元素必须是数组/对象
            'users.*.name' => ['required', 'string', 'max:50'], // 验证嵌套字段
            'users.*.email' => ['required', 'email'],
            'users.*.age' => ['required', 'integer', 'min:1', 'max:120'],

            // 示例3: 验证关联数组的嵌套数组
            // 数据格式: {"item1": [1,2,3], "item2": [4,5,6]}
            'tags' => ['sometimes', 'array'],
            'tags.*' => ['required', 'array'],                 // 每个值必须是数组
            'tags.*.*' => ['required', 'string', 'max:50'],    // 每个数组中的元素必须是字符串

            // 示例4: 验证购物车商品（实际业务场景）
            'items' => ['required', 'array', 'min:1'],
            'items.*' => ['required', 'array'],
            'items.*.id' => ['required', 'integer', 'exists:products,id'],
            'items.*.quantity' => ['required', 'integer', 'min:1', 'max:999'],
            'items.*.price' => ['required', 'numeric', 'min:0'],
            'items.*.options' => ['sometimes', 'array'],       // 可选的嵌套数组
            'items.*.options.*' => ['required', 'string'],      // 选项数组中的每个元素

            // 示例5: 验证分类和标签的嵌套结构
            'categories' => ['sometimes', 'array'],
            'categories.*' => ['required', 'array'],
            'categories.*.id' => ['required', 'integer'],
            'categories.*.name' => ['required', 'string'],
            'categories.*.tags' => ['sometimes', 'array'],      // 嵌套的标签数组
            'categories.*.tags.*' => ['required', 'string'],    // 标签数组中的每个元素

            // 示例6: 验证表格数据（行列结构）
            'table_data' => ['sometimes', 'array'],
            'table_data.*' => ['required', 'array'],
            'table_data.*.row' => ['required', 'integer'],     // 行号
            'table_data.*.columns' => ['required', 'array'],   // 列数据
            'table_data.*.columns.*' => ['required', 'string'], // 每列的值
        ];
    }

    public function createRules(): array
    {
        return [
            'users' => ['required', 'array', 'min:1'],
            'users.*.email' => ['unique:users,email'],         // 创建时验证邮箱唯一性
        ];
    }

    public function updateRules(): array
    {
        return [
            'users' => ['sometimes', 'array'],
        ];
    }

    public function attributes(): array
    {
        return [
            'matrix' => '矩阵数据',
            'matrix.*' => '矩阵行',
            'matrix.*.*' => '矩阵元素',
            
            'users' => '用户列表',
            'users.*' => '用户信息',
            'users.*.name' => '用户姓名',
            'users.*.email' => '用户邮箱',
            'users.*.age' => '用户年龄',
            
            'tags' => '标签',
            'tags.*' => '标签组',
            'tags.*.*' => '标签项',
            
            'items' => '商品列表',
            'items.*' => '商品信息',
            'items.*.id' => '商品ID',
            'items.*.quantity' => '商品数量',
            'items.*.price' => '商品价格',
            'items.*.options' => '商品选项',
            'items.*.options.*' => '选项值',
            
            'categories' => '分类列表',
            'categories.*.tags' => '分类标签',
            
            'table_data' => '表格数据',
            'table_data.*.columns' => '列数据',
        ];
    }

    public function messages(): array
    {
        return [
            'users.*.email.required' => '用户邮箱不能为空',
            'users.*.email.email' => '用户邮箱格式不正确',
            'users.*.email.unique' => '用户邮箱已存在',
            'items.*.id.exists' => '商品不存在',
        ];
    }
}
