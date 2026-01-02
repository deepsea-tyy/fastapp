<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Enums;

/**
 * 钱包类型枚举
 */
enum WalletType: string
{
    case FUNDING = 'FUNDING';   // 资金账户
    case SPOT = 'SPOT';         // 现货账户
    case FUTURES = 'FUTURES';   // 合约账户
    case MARGIN = 'MARGIN';     // 杠杆账户
    case EARN = 'EARN';         // 理财账户
    case OPTIONS = 'OPTIONS';   // 期权账户

    /**
     * 获取所有可用的钱包类型
     */
    public static function all(): array
    {
        return [
            self::FUNDING->value,
            self::SPOT->value,
            self::FUTURES->value,
            self::MARGIN->value,
            self::EARN->value,
            self::OPTIONS->value,
        ];
    }

    /**
     * 获取钱包类型描述
     */
    public function description(): string
    {
        return match($this) {
            self::FUNDING => '资金账户',
            self::SPOT => '现货账户',
            self::FUTURES => '合约账户',
            self::MARGIN => '杠杆账户',
            self::EARN => '理财账户',
            self::OPTIONS => '期权账户',
        };
    }
}
