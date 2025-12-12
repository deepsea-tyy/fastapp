<?php
/**
 * FastApp.
 * 10/16/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Common\Event;

use App\Model\User;

/**
 * 用户登录事件
 *
 * 用于记录用户登录信息，包括：
 * - 用户对象
 * - IP地址
 * - 操作系统
 * - 浏览器/User-Agent
 * - 设备唯一标识（iOS/Android/Web通用，可选）
 * - 类型 1:登录,2:注册,3:重置密码,4:绑定手机,5:绑定邮箱,6:解绑手机,7:解绑邮箱,8:禁用账户,9:删除账户,10:绑定2fa,11:解绑2fa
 */
final class UserAccountEvent
{
    public function __construct(
        private readonly User   $user,
        private readonly string $ip,
        private readonly string $os,
        private readonly string $browser,
        private readonly string $deviceId = '',
        private readonly int    $type = 1,
    )
    {
    }

    public function getUser(): object
    {
        return $this->user;
    }

    public function getIp(): string
    {
        return $this->ip;
    }

    /**
     * 获取操作系统
     *
     * @return string 操作系统
     */
    public function getOs(): string
    {
        return $this->os;
    }

    /**
     * 获取浏览器/User-Agent
     *
     * @return string 浏览器/User-Agent
     */
    public function getBrowser(): string
    {
        return $this->browser;
    }

    /**
     * 获取设备唯一标识
     *
     * @return string 设备唯一标识（iOS/Android/Web通用）
     */
    public function getDeviceId(): string
    {
        return $this->deviceId;
    }

    public function getType(): string
    {
        return $this->type;
    }
}