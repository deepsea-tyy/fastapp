<?php
/**
 * FastApp.
 * 10/16/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Common\Event;
use App\Model\User;

final class UserLoginEvent
{
    public function __construct(
        private readonly User $user,
        private readonly string $ip,
        private readonly string $os,
        private readonly string $device,
    ) {}

    public function getUser(): object
    {
        return $this->user;
    }

    public function getIp(): string
    {
        return $this->ip;
    }

    public function getDevice(): string
    {
        return $this->device;
    }

    public function getOs(): string
    {
        return $this->os;
    }
}