<?php

declare(strict_types=1);

namespace App\Model\Enums\User;

enum LoginType: int
{
    case USERNAME_PASSWORD = 1;
    case MOBILE_CODE = 2;
    case EMAIL_CODE = 3;
    case WECHAT_MINI = 11;
    case WECHAT_OPEN = 12;
}
