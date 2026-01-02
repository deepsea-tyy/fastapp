<?php

declare(strict_types=1);
namespace Plugin\Ds\Ex\Http\Admin\Request;

use App\Common\Request\Traits\ActionRulesTrait;
use Hyperf\Validation\Request\FormRequest;

class UserRequest extends FormRequest
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
            'username' => 'sometimes|nullable',
            'email' => 'email|nullable',
            'code' => 'integer|nullable',
            'mobile' => 'regex:/^1[3456789]\d{9}$/|nullable',
            'password' => 'min:6|confirmed',
            'user_type' => 'sometimes',
            'status' => 'integer',
            'google2fa' => 'sometimes|nullable',
            'remark' => 'sometimes',
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
            'username' => trans('user.username') ?: '用户名',
            'email' => trans('user.email') ?: '用户邮箱',
            'code' => trans('user.code') ?: '手机code',
            'mobile' => trans('user.mobile') ?: '手机',
            'password' => trans('user.password') ?: '密码',
            'user_type' => trans('user.user_type') ?: '用户类型',
            'status' => trans('user.status') ?: '状态',
            'google2fa' => trans('user.google2fa') ?: 'google2fa',
            'remark' => trans('user.remark') ?: '备注',
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
