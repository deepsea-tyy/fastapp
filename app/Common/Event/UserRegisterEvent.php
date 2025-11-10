<?php
/**
 * FastApp.
 * 11/5/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Common\Event;

use App\Model\User;

class UserRegisterEvent
{
    public function __construct(protected User $user)
    {
    }

    public function getUser(): object
    {
        return $this->user;
    }
}