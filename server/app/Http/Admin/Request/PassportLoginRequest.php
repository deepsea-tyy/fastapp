<?php

declare(strict_types=1);


namespace App\Http\Admin\Request;

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
])]
class PassportLoginRequest extends FormRequest
{
    use ClientIpRequestTrait;
    use ClientOsTrait;
    use NoAuthorizeTrait;

    public function rules(): array
    {
        return [
            'username' => 'required|string|exists:user,username',
            'password' => 'required|string',
            'vcode' => 'nullable|string|max:6',
            'google2fa_code' => 'nullable|string|max:6',
        ];
    }

    public function attributes(): array
    {
        return [
            'username' => trans('user.username'),
            'password' => trans('user.password'),
            'vcode' => trans('user.vcode'),
            'google2fa_code' => trans('user.vcode'),
        ];
    }

    public function ip(): string
    {
        return Arr::first($this->getClientIps(), static fn($ip) => $ip, '0.0.0.0');
    }
}
