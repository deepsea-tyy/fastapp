<?php

declare(strict_types=1);

namespace Plugin\Ds\Article\Http\Request;

use App\Common\Request\Traits\ActionRulesTrait;
use Hyperf\Validation\Request\FormRequest;

class CategoryRequest extends FormRequest
{
    use ActionRulesTrait;

    public function authorize(): bool
    {
        return true;
    }

    // 默认验证
    public function commonRules(): array
    {
        return [
            'name' => ['array'],
            'icon' => ['sometimes'],
            'sort' => ['integer'],
            'parent_id' => ['integer'],
            'status' => ['integer'],
            'remark' => ['sometimes'],
            'code' => ['sometimes'],
        ];
    }

    // 自动匹配create方法验证
    public function createRules(): array
    {
        return [];
    }

    // 自动匹配save方法验证
    public function saveRules(): array
    {
        return [];
    }

    public function attributes(): array
    {
        return [
            'name' => trans('category.name') ?: '名称',
            'icon' => trans('category.icon') ?: 'icon',
            'sort' => trans('category.sort') ?: '排序',
            'parent_id' => trans('category.parent_id') ?: '上级',
            'status' => trans('category.status') ?: '1显示',
            'remark' => trans('category.remark') ?: '备注',
            'code' => trans('category.code') ?: '调用代码',
        ];
    }

    /**
     * 获取验证错误的自定义消息.
     */
    public function messages(): array
    {
        return [
            // 可以在这里添加自定义的错误消息
        ];
    }
}