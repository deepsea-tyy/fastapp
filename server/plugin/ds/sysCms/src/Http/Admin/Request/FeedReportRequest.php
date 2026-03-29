<?php

declare(strict_types=1);
namespace Plugin\Ds\SysCms\Http\Admin\Request;

use App\Common\Request\Traits\ActionRulesTrait;
use Hyperf\Validation\Request\FormRequest;

class FeedReportRequest extends FormRequest
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
            'user_id' => 'integer',
            'target_type' => 'integer',
            'target_id' => 'integer',
            'report_type' => 'integer',
            'content' => 'sometimes|nullable',
            'handle_status' => 'integer',
            'handled_at' => 'date|nullable',
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
            'user_id' => trans('feed_report.user_id') ?: '举报用户ID',
            'target_type' => trans('feed_report.target_type') ?: '目标类型：1帖子 2文章 3评论',
            'target_id' => trans('feed_report.target_id') ?: '目标ID',
            'report_type' => trans('feed_report.report_type') ?: '举报原因：1垃圾广告 2色情低俗 3违法违规 4侮辱谩骂 5其他',
            'content' => trans('feed_report.content') ?: '举报说明',
            'handle_status' => trans('feed_report.handle_status') ?: '处理状态：0待处理 1已处理 2已忽略',
            'handled_at' => trans('feed_report.handled_at') ?: '处理时间',
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
