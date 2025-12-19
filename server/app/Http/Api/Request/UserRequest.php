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

#[Schema(title: '登录注册请求', description: '登录请求参数', properties: [
    new Property('username', description: 'username', type: 'string'),
    new Property('mobile', description: 'mobile', type: 'string'),
    new Property('code', description: 'mobile code', type: 'numeric'),
    new Property('mobile', description: 'mobile', type: 'string'),
    new Property('password', description: 'password', type: 'string'),
    new Property('password_confirmation', description: '确认密码', type: 'string'),
    new Property('vcode', description: '验证码', type: 'numeric'),
    new Property('openid', description: 'openid', type: 'string'),
    new Property('type', description: '类型 1账号密码,2手机验证码,3邮箱证码,11小程序,12公众号', type: 'numeric'),
    new Property('scene', description: '验证码场景：login(登录)、register(注册)、reset_password(找回密码)、bind(绑定)、change(修改)、default(默认)', type: 'string'),
    new Property('google2fa', description: 'Google2FA密钥', type: 'string'),
    new Property('google2fa_code', description: 'Google2FA验证码', type: 'string'),
    new Property('invite_code', description: '邀请码', type: 'string'),
    new Property('device_id', description: '设备唯一标识（iOS/Android/Web通用）', type: 'string'),
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
            'code' => 'numeric',
            'mobile' => 'string|max:16',
            'email' => 'string|max:64',
            'to' => 'string|max:128', // 验证码接收地址（手机号或邮箱）
            'vcode' => 'numeric',
            'type' => 'string|numeric', // 支持字符串（sms/email）和整数（登录类型）
            'scene' => 'string|in:login,register,reset_password,bind,change,default',
            'google2fa' => 'string|max:50',
            'google2fa_code' => 'nullable|numeric',
            'invite_code' => 'nullable|string|max:16',
            'device_id' => 'nullable|string|max:128', // 设备唯一标识（iOS/Android/Web通用）
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
            'email' => 'required_if:type,3',
            'scene' => 'required_if:type,2',
            'type' => 'required|numeric',
            'invite_code' => 'nullable|string|max:16',
        ];
    }

    /**
     * 登录场景验证规则
     */
    public function loginRules(): array
    {
        return [
            // username 不再必填，允许为空
            'username' => 'nullable',
            // mobile 在 type=1 时（当 username 和 email 都不存在时必填），或在 type=2 时必填
            'mobile' => 'required_without_all:username,email|required_if:type,2',
            // email 在 type=1 时（当 username 和 mobile 都不存在时必填）
            'email' => 'required_without_all:username,mobile',
            'password' => 'required_if:type,1',
            // type=2 时，手机验证码登录
            'vcode' => 'required_if:type,2',
            'scene' => 'required_if:type,2',
            'type' => 'required|numeric',
        ];
    }

    /**
     * 修改密码场景验证规则
     */
    public function changePasswordRules(): array
    {
        return [
            'old_password' => 'nullable|string|max:32',
            'password' => 'required|string|max:32|min:6',
            'password_confirmation' => 'required|string|max:32|same:password',
            'google2fa_code' => 'nullable|numeric',
            'vcode' => 'nullable|numeric',
        ];
    }

    /**
     * 发送验证码场景验证规则
     */
    public function smsRules(): array
    {
        return [
            'type' => 'required|string|in:sms,email',
            'to' => 'required|string|max:128',
            'code' => 'nullable|numeric',
            'scene' => 'nullable|string|in:login,register,reset_password,bind,change,default',
        ];
    }

    /**
     * 验证验证码场景验证规则
     */
    public function smsCheckRules(): array
    {
        return [
            'type' => 'required|string|in:sms,email',
            'to' => 'required|string|max:128',
            'vcode' => 'required|numeric',
            'scene' => 'nullable|string|in:login,register,reset_password,bind,change,default',
            'code' => 'nullable|numeric',
        ];
    }

    /**
     * 绑定Google2FA场景验证规则
     */
    public function google2faBindRules(): array
    {
        return [
            'google2fa' => 'required|string|max:50',
            'google2fa_code' => 'required|numeric',
        ];
    }

    /**
     * 解绑Google2FA场景验证规则
     */
    public function google2faUnbindRules(): array
    {
        return [
            'google2fa_code' => 'required|numeric',
        ];
    }

    /**
     * 绑定邮箱场景验证规则
     */
    public function emailBindRules(): array
    {
        return [
            'email' => 'required|email|max:64',
            'vcode' => 'required|numeric',
            'google2fa_code' => 'nullable|numeric',
        ];
    }

    /**
     * 解绑邮箱场景验证规则
     */
    public function emailUnbindRules(): array
    {
        return [
            'vcode' => 'required|numeric',
            'google2fa_code' => 'nullable|numeric',
        ];
    }

    /**
     * 绑定手机号场景验证规则
     */
    public function mobileBindRules(): array
    {
        return [
            'mobile' => 'required|numeric',
            'code' => 'required|numeric',
            'vcode' => 'required|numeric',
            'google2fa_code' => 'nullable|numeric',
        ];
    }

    /**
     * 解绑手机号场景验证规则
     */
    public function mobileUnbindRules(): array
    {
        return [
            'vcode' => 'required|numeric',
            'google2fa_code' => 'nullable|numeric',
        ];
    }

    /**
     * 禁用账户场景验证规则
     */
    public function accountDisableRules(): array
    {
        return [
            'password' => 'required|string|max:32',
            'google2fa_code' => 'nullable|numeric',
            'vcode' => 'nullable|numeric',
        ];
    }

    /**
     * 删除账户场景验证规则
     */
    public function accountDeleteRules(): array
    {
        return [
            'password' => 'required|string|max:32',
            'google2fa_code' => 'nullable|numeric',
            'vcode' => 'nullable|numeric',
        ];
    }

    /**
     * 重置密码场景验证规则
     */
    public function resetPasswordRules(): array
    {
        return [
            'step' => 'required|numeric',
            'type' => 'required|numeric|in:2,3', // 2=手机验证码，3=邮箱验证码
            'mobile' => 'required_if:type,2|string|max:16',
            'email' => 'required_if:type,3|email|max:64',
            'code' => 'required_if:type,2|numeric',
            'vcode' => 'nullable|numeric',
            'google2fa_code' => 'nullable|numeric',
            'password' => 'nullable|string|min:6|max:32',
            'password_confirmation' => 'required_with:password|string|max:32|same:password',
        ];
    }

    /**
     * 更新用户资料场景验证规则
     */
    public function profileUpdateRules(): array
    {
        return [
            'username' => 'nullable|string|max:32|regex:/^[^\s]+$/',
            'nickname' => 'nullable|string|max:32|regex:/^[^\s]+$/',
            'avatar' => 'nullable|string|max:200',
            'signed' => 'nullable|string|max:200',
            'lang' => 'nullable|string|max:8',
            'setting' => 'nullable|array',
            'setting.theme' => 'string|max:8',
            'setting.feed_msg_like' => 'numeric|in:0,1',
            'setting.feed_msg_replay' => 'numeric|in:0,1',
            'setting.feed_msg_follow' => 'numeric|in:0,1',
            'setting.feed_msg_at' => 'numeric|in:0,1',
            'setting.feed_msg_content' => 'numeric|in:0,1',
            'setting.feed_msg_frequency' => 'numeric|in:1,2,3',
            'setting.feed_msg_news' => 'numeric|in:0,1',
        ];
    }

    public function attributes(): array
    {
        return [
            'username' => trans('user.username'),
            'password' => trans('user.password'),
            'password_confirmation' => trans('user.password'),
            'code' => trans('user.code'),
            'mobile' => trans('user.mobile'),
            'email' => trans('user.email'),
            'vcode' => trans('user.vcode'),
            'to' => 'mobile/email',
            'google2fa' => trans('user.google2fa'),
            'google2fa_code' => trans('user.vcode'),
            'invite_code' => trans('user.invite_code'),
            'device_id' => 'device_id',
            'old_password' => trans('user.old_password'),
            'type' => 'login/register type',
            'scene' => trans('user.scene'),
            'nickname' => trans('user.nickname'),
        ];
    }

    public function ip(): string
    {
        return Arr::first($this->getClientIps(), static fn($ip) => $ip, '0.0.0.0');
    }
}