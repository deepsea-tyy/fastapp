<?php

declare(strict_types=1);
namespace App\Http\Admin\Request\Search;

use App\Common\Request\Traits\ActionRulesTrait;
use Hyperf\Validation\Request\FormRequest;

class IndexsRequest extends FormRequest
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
            'target_type' => 'sometimes',
            'target_id' => 'integer',
            'title' => 'sometimes',
            'keyword' => 'array|nullable',
            'tags' => 'array|nullable',
            'weight' => 'integer',
            'last_at' => 'date|nullable',
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
            'target_type' => trans('indexs.target_type') ?: '内容类型',
            'target_id' => trans('indexs.target_id') ?: '内容ID',
            'title' => trans('indexs.title') ?: '标题',
            'keyword' => trans('indexs.keyword') ?: '关键词数组',
            'tags' => trans('indexs.tags') ?: '标签数组',
            'weight' => trans('indexs.weight') ?: '权重',
            'last_at' => trans('indexs.last_at') ?: '发布时间',
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
