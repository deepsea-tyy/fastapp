<?php

declare(strict_types=1);
namespace Plugin\Ds\MessageNotify\Http\Admin\Request;

use App\Common\Request\Traits\ActionRulesTrait;
use Hyperf\Validation\Request\FormRequest;

class MessageNotifyRequest extends FormRequest
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
            'title' => ['array'],
            'content' => ['array'],
            'type' => ['integer'],
            'user_id' => ['integer'],
            'notify_type' => ['integer'],
            'link' => ['string'],
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
            'title' => trans('message_notify.title') ?: '通知标题',
            'content' => trans('message_notify.content') ?: '通知内容',
            'type' => trans('message_notify.type') ?: '通知类型',
            'user_id' => trans('message_notify.user_id') ?: '用户ID全局通知为null',
            'notify_type' => trans('message_notify.notify_type') ?: '通知分类',
            'link' => trans('message_notify.link') ?: '跳转链接',
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