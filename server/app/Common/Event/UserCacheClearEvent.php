<?php
/**
 * FastApp.
 * 11/5/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Common\Event;

use App\Model\User;

class UserCacheClearEvent
{
    public function __construct(public int $userId)
    {
    }
}