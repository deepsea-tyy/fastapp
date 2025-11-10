<?php
/**
 * FastApp.
 * 10/16/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Http\Api\Request;


use App\Common\Request\Traits\ActionRulesTrait;
use App\Common\Request\Traits\ClientIpRequestTrait;
use App\Common\Request\Traits\ClientOsTrait;
use App\Common\Request\Traits\NoAuthorizeTrait;
use Hyperf\Collection\Arr;
use Hyperf\Swagger\Annotation\Property;
use Hyperf\Swagger\Annotation\Schema;
use Hyperf\Validation\Request\FormRequest;

#[Schema(title: '注册请求', description: '登录请求参数', properties: [
    new Property('username', description: 'username', type: 'string'),
    new Property('password', description: 'password', type: 'string'),
    new Property('password_confirmation', description: '确认密码', type: 'string'),
    new Property('code', description: 'sms', type: 'string'),
    new Property('openid', description: 'openid', type: 'string'),
    new Property('type', description: '类型 1账号密码2手机验证码3小程序4公众号', type: 'integer'),
    new Property('scene', description: '验证码场景：login(登录)、register(注册)、reset_password(找回密码)、bind(绑定)、change(修改)、default(默认)', type: 'string'),
    new Property('secret', description: 'Google2FA密钥', type: 'string'),
    new Property('invite_code', description: '邀请码', type: 'string'),
])]
class UserRequest extends FormRequest
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
            'username' => 'string|max:16',
            'password' => 'string|max:32',
            'password_confirmation' => 'string|max:32',
            'mobile' => 'string|max:16',
            'code' => 'string|max:32',
            'type' => 'integer',
            'scene' => 'string|in:login,register,reset_password,bind,change,default',
            'secret' => 'string|max:50',
            'invite_code' => 'nullable|string|max:16',
        ];
    }

    /**
     * 注册场景验证规则
     */
    public function registerRules(): array
    {
        return [
            'username' => 'required_if:type,1',
            'password' => 'required_if:type,1|confirmed',
            'password_confirmation' => 'required_if:type,1',
            'mobile' => 'required_if:type,2',
            'scene' => 'required_if:type,2',
            'type' => 'required|integer',
            'invite_code' => 'nullable|string|max:16',
        ];
    }

    /**
     * 登录场景验证规则
     */
    public function loginRules(): array
    {
        return [
            'username' => 'required_if:type,1',
            'password' => 'required_if:type,1',
            'mobile' => 'required_if:type,2',
            'code' => 'required_if:type,2',
            'scene' => 'required_if:type,2',
            'type' => 'required|integer',
        ];
    }

    /**
     * 发送验证码场景验证规则
     */
    public function smsRules(): array
    {
        return [
            'mobile' => 'required|string|max:16',
            'scene' => 'required|string|in:login,register,reset_password,bind,change,default',
        ];
    }

    /**
     * 绑定Google2FA场景验证规则
     */
    public function google2faBindRules(): array
    {
        return [
            'secret' => 'required|string|max:50',
            'code' => 'required|string|max:32',
        ];
    }

    /**
     * 验证Google2FA场景验证规则
     */
    public function google2faVerifyRules(): array
    {
        return [
            'code' => 'required|string|max:32',
        ];
    }

    /**
     * 解绑Google2FA场景验证规则
     */
    public function google2faUnbindRules(): array
    {
        return [
            'code' => 'required|string|max:32',
        ];
    }

    public function attributes(): array
    {
        return [
            'username' => trans('user.username'),
            'password' => trans('user.password'),
            'password_confirmation' => trans('user.password'),
            'mobile' => trans('user.mobile'),
            'code' => trans('user.code'),
            'type' => trans('user.type'),
            'scene' => trans('user.scene', [], 'zh_CN') ?: '验证码场景',
            'secret' => 'Google2FA密钥',
            'invite_code' => '邀请码',
        ];
    }

    public function ip(): string
    {
        return Arr::first($this->getClientIps(), static fn($ip) => $ip, '0.0.0.0');
    }
}