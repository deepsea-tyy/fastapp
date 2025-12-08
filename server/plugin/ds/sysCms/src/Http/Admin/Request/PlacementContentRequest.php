<?php

declare(strict_types=1);
namespace Plugin\Ds\SysCms\Http\Admin\Request;

use App\Common\Request\Traits\ActionRulesTrait;
use Hyperf\Validation\Request\FormRequest;

class PlacementContentRequest extends FormRequest
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
            'code' => 'sometimes|nullable',
            'name' => 'sometimes|nullable',
            'object_type' => 'integer',
            'object_id' => 'integer|nullable',
            'url' => 'sometimes|nullable',
            'target' => 'integer',
            'title' => 'array|nullable',
            'cover' => 'string|nullable|max:512',
            'desc' => 'array|nullable',
            'content' => 'array|nullable',
            'start_at' => 'integer|date|nullable',
            'end_at' => 'integer|date|nullable',
            'fixed' => 'integer',
            'status' => 'integer',
            'sort' => 'integer',
            'remark' => 'sometimes|nullable',
            'views' => 'integer',
            'clicks' => 'integer',
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
            'code' => trans('placement_content.code') ?: '调用代码',
            'name' => trans('placement_content.name') ?: '内容名称',
            'object_type' => trans('placement_content.object_type') ?: '数据类型：1链接 2视频 3分享 4文章 5路径',
            'object_id' => trans('placement_content.object_id') ?: '关联数据ID（根据object_type关联不同表，object_type=4时关联article表）',
            'url' => trans('placement_content.url') ?: '链接地址（object_type=1）',
            'target' => trans('placement_content.target') ?: '链接打开方式：1当前窗口 2新窗口',
            'title' => trans('placement_content.title') ?: '标题（多语言，用于覆盖关联数据的标题）',
            'cover' => trans('placement_content.cover') ?: '封面图片URL（用于覆盖关联数据的封面）',
            'desc' => trans('placement_content.desc') ?: '描述（多语言，用于覆盖关联数据的描述）',
            'content' => trans('placement_content.content') ?: '分享内容（多语言，object_type=3分享时使用）',
            'start_at' => trans('placement_content.start_at') ?: '开始时间（时间戳）',
            'end_at' => trans('placement_content.end_at') ?: '结束时间（时间戳）',
            'fixed' => trans('placement_content.fixed') ?: '永久有效：1是 0否',
            'status' => trans('placement_content.status') ?: '状态：1显示 0隐藏',
            'sort' => trans('placement_content.sort') ?: '排序',
            'remark' => trans('placement_content.remark') ?: '备注',
            'views' => trans('placement_content.views') ?: '展示次数',
            'clicks' => trans('placement_content.clicks') ?: '点击次数',
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
