<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Enums;

/**
 * 提现状态枚举
 */
enum WithdrawalStatus: int
{
    case PENDING_AUDIT = 1;      // 待审核
    case AUDIT_PASSED = 2;       // 审核通过
    case PROCESSING = 3;         // 处理中
    case COMPLETED = 4;          // 已完成
    case REJECTED = 5;           // 已拒绝
    case CANCELLED = 6;          // 已取消

    /**
     * 获取状态描述
     */
    public function description(): string
    {
        return match($this) {
            self::PENDING_AUDIT => '待审核',
            self::AUDIT_PASSED => '审核通过',
            self::PROCESSING => '处理中',
            self::COMPLETED => '已完成',
            self::REJECTED => '已拒绝',
            self::CANCELLED => '已取消',
        };
    }

    /**
     * 获取API返回的状态名称
     */
    public function apiStatus(): string
    {
        return match($this) {
            self::PENDING_AUDIT => 'PENDING_AUDIT',
            self::AUDIT_PASSED => 'AUDIT_PASSED',
            self::PROCESSING => 'PROCESSING',
            self::COMPLETED => 'COMPLETED',
            self::REJECTED => 'REJECTED',
            self::CANCELLED => 'CANCELLED',
        };
    }
}
