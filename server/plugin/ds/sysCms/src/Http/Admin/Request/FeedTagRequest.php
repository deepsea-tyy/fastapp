<?php

declare(strict_types=1);
namespace Plugin\Ds\SysCms\Http\Admin\Request;

use App\Common\Request\Traits\ActionRulesTrait;
use Hyperf\Validation\Request\FormRequest;

class FeedTagRequest extends FormRequest
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
            'name' => 'array',
            'icon' => 'sometimes|nullable',
            'color' => 'sometimes|nullable',
            'post_count' => 'integer',
            'follow_count' => 'integer',
            'is_hot' => 'integer',
            'status' => 'integer',
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
            'name' => trans('feed_tag.name') ?: '标签名称（多语言）',
            'icon' => trans('feed_tag.icon') ?: '标签图标',
            'color' => trans('feed_tag.color') ?: '标签颜色',
            'post_count' => trans('feed_tag.post_count') ?: '内容数量',
            'follow_count' => trans('feed_tag.follow_count') ?: '关注数',
            'is_hot' => trans('feed_tag.is_hot') ?: '是否热门',
            'status' => trans('feed_tag.status') ?: '状态：1启用 0禁用',
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
