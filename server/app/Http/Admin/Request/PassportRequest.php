<?php

declare(strict_types=1);


namespace App\Http\Admin\Request;

use App\Common\Request\Traits\ActionRulesTrait;
use App\Common\Request\Traits\ClientIpRequestTrait;
use App\Common\Request\Traits\ClientOsTrait;
use App\Common\Request\Traits\NoAuthorizeTrait;
use Hyperf\Collection\Arr;
use Hyperf\Swagger\Annotation\Property;
use Hyperf\Swagger\Annotation\Schema;
use Hyperf\Validation\Request\FormRequest;

#[Schema(title: '登录请求', description: '登录请求参数', properties: [
    new Property('username', description: '用户名', type: 'string'),
    new Property('password', description: '密码', type: 'string'),
    new Property('type', description: '验证码类型：captcha(图形验证码) 或 google2fa_code(Google2FA)', type: 'string'),
    new Property('code', description: '图形验证码', type: 'string'),
    new Property('google2fa_code', description: 'Google2FA验证码', type: 'string'),
    new Property('google2fa', description: 'Google2FA密钥', type: 'string'),
])]
class PassportRequest extends FormRequest
{
    use ActionRulesTrait;
    use ClientIpRequestTrait;
    use ClientOsTrait;
    use NoAuthorizeTrait;

    /**
     * 通用验证规则（所有方法都会应用）
     */
    public function commonRules(): array
    {
        return [
            'username' => 'nullable|string|exists:user,username',
            'password' => 'nullable|string',
            'vcode' => 'nullable|string|max:6',
            'google2fa_code' => 'nullable|string|max:6',
            'google2fa' => 'nullable|string|max:50',
            'code' => 'nullable|string',
        ];
    }

    /**
     * 登录场景验证规则
     */
    public function loginRules(): array
    {
        return [
            'username' => 'required|string|exists:user,username',
            'password' => 'required|string',
        ];
    }

    /**
     * 绑定Google2FA场景验证规则
     */
    public function google2faBindRules(): array
    {
        return [
            'google2fa' => 'required|string|max:50',
            'google2fa_code' => 'required|string|max:6',
        ];
    }

    /**
     * 解绑Google2FA场景验证规则
     */
    public function google2faUnbindRules(): array
    {
        return [
            'google2fa_code' => 'required|string|max:6',
        ];
    }

    public function attributes(): array
    {
        return [
            'username' => trans('user.username'),
            'password' => trans('user.password'),
            'vcode' => trans('user.vcode'),
            'google2fa_code' => trans('user.vcode'),
            'google2fa' => trans('user.google2fa'),
        ];
    }

    public function ip(): string
    {
        return Arr::first($this->getClientIps(), static fn($ip) => $ip, '0.0.0.0');
    }
}
