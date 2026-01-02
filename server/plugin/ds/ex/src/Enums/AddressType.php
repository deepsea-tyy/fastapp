<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Enums;

/**
 * 地址类型枚举
 */
enum AddressType: int
{
    case DEPOSIT = 1;    // 充值地址
    case WITHDRAW = 2;   // 提现地址

    /**
     * 获取地址类型描述
     */
    public function description(): string
    {
        return match($this) {
            self::DEPOSIT => '充值地址',
            self::WITHDRAW => '提现地址',
        };
    }
}
