<?php

declare(strict_types=1);

namespace App\Model\Enums\User;

enum LoginType: int
{
    case USERNAME_PASSWORD = 1;
    case MOBILE_CODE = 2;
    case WECHAT_MINI = 3;
    case WECHAT_OPEN = 4;
}
