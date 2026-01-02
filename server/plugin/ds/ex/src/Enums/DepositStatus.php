<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Enums;

/**
 * 充值状态枚举
 */
enum DepositStatus: int
{
    case PENDING = 1;      // 待确认
    case COMPLETED = 2;    // 已完成
    case FAILED = 3;       // 失败

    /**
     * 获取状态描述
     */
    public function description(): string
    {
        return match($this) {
            self::PENDING => '待确认',
            self::COMPLETED => '已完成',
            self::FAILED => '失败',
        };
    }

    /**
     * 获取API返回的状态名称
     */
    public function apiStatus(): string
    {
        return match($this) {
            self::PENDING => 'PENDING',
            self::COMPLETED => 'COMPLETED',
            self::FAILED => 'FAILED',
        };
    }
}
