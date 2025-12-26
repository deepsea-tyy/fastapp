<?php

declare(strict_types=1);
namespace Plugin\Ds\SysKefu\Http\Admin\Request;

use App\Common\Request\Traits\ActionRulesTrait;
use Hyperf\Validation\Request\FormRequest;

class KefuAutoReplyRequest extends FormRequest
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
            'title' => 'sometimes',
            'trigger_type' => 'integer',
            'keywords' => 'sometimes',
            'reply_type' => 'integer',
            'reply_content' => 'sometimes',
            'lang' => 'sometimes',
            'priority' => 'integer',
            'status' => 'integer',
            'hit_count' => 'integer',
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
            'title' => trans('kefu_auto_reply.title') ?: '规则名称',
            'trigger_type' => trans('kefu_auto_reply.trigger_type') ?: '触发类型：1=关键词精确匹配，2=关键词模糊匹配，3=正则匹配',
            'keywords' => trans('kefu_auto_reply.keywords') ?: '关键词列表（JSON数组，如：）',
            'reply_type' => trans('kefu_auto_reply.reply_type') ?: '回复类型：1=纯文本，2=图片，3=文件，4=多条消息',
            'reply_content' => trans('kefu_auto_reply.reply_content') ?: '回复内容（JSON格式，支持多语言）',
            'lang' => trans('kefu_auto_reply.lang') ?: '语言：zh_CN=简体中文，en=英文',
            'priority' => trans('kefu_auto_reply.priority') ?: '优先级（数值越大优先级越高，相同优先级按ID排序）',
            'status' => trans('kefu_auto_reply.status') ?: '状态：0=禁用，1=启用',
            'hit_count' => trans('kefu_auto_reply.hit_count') ?: '命中次数（统计用）',
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
