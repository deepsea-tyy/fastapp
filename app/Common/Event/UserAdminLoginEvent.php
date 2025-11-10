<?php
/**
 * FastApp.
 * 10/16/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Common\Event;
final class UserAdminLoginEvent
{
    public function __construct(
        private readonly object $user,
        private readonly string $ip,
        private readonly string $os,
        private readonly string $browser,
        private readonly bool   $isLogin = true,
    ) {}

    public function getUser(): object
    {
        return $this->user;
    }

    public function isLogin(): bool
    {
        return $this->isLogin;
    }

    public function getIp(): string
    {
        return $this->ip;
    }

    public function getBrowser(): string
    {
        return $this->browser;
    }

    public function getOs(): string
    {
        return $this->os;
    }
}