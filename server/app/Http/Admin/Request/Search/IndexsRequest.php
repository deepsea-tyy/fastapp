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
            'author' => 'sometimes|nullable',
            'tags' => 'array|nullable',
            'extra' => 'array|nullable',
            'weight' => 'integer',
            'view_count' => 'integer',
            'like_count' => 'integer',
            'status' => 'integer',
            'published_at' => 'date|nullable',
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
            'author' => trans('indexs.author') ?: '作者/发布者',
            'tags' => trans('indexs.tags') ?: '标签数组',
            'extra' => trans('indexs.extra') ?: '扩展字段JSON',
            'weight' => trans('indexs.weight') ?: '权重',
            'view_count' => trans('indexs.view_count') ?: '浏览量',
            'like_count' => trans('indexs.like_count') ?: '点赞数',
            'status' => trans('indexs.status') ?: '状态',
            'published_at' => trans('indexs.published_at') ?: '发布时间',
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
