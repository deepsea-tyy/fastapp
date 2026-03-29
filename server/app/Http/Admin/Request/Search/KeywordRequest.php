<?php

declare(strict_types=1);
namespace App\Http\Admin\Request\Search;

use App\Common\Request\Traits\ActionRulesTrait;
use Hyperf\Validation\Request\FormRequest;

class KeywordRequest extends FormRequest
{
    use ActionRulesTrait;

    public function authorize(): bool
    {
        return true;
    }

    /**
     * 通用验证规则（所有方法都会应用）
     */
    public function commonRules(): array
    {
        return [
            'keyword' => 'sometimes',
            'hit_count' => 'integer',
            'icon' => 'sometimes|nullable',
            'source' => 'integer',
            'last_searched_at' => 'date|nullable',
        ];
    }

    /**
     * 自动匹配create方法验证
     */
    public function createRules(): array
    {
        return [];
    }

    /**
     * 自动匹配save方法验证
     */
    public function saveRules(): array
    {
        return [];
    }

    /**
     * 获取验证字段的自定义名称
     */
    public function attributes(): array
    {
        return [
            'keyword' => trans('keyword.keyword') ?: '搜索关键词',
            'hit_count' => trans('keyword.hit_count') ?: '命中次数',
            'icon' => trans('keyword.icon') ?: '图标名称',
            'source' => trans('keyword.source') ?: '来源',
            'last_searched_at' => trans('keyword.last_searched_at') ?: '最后搜索时间',
        ];
    }

    /**
     * 获取验证错误的自定义消息
     */
    public function messages(): array
    {
        return [
            // 可以在这里添加自定义的错误消息
        ];
    }
}
