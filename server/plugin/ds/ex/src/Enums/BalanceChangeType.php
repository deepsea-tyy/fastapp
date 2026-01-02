<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Enums;

/**
 * 余额变动类型枚举
 */
enum BalanceChangeType: string
{
    //业务类型
    case DEPOSIT = 'DEPOSIT';               // 充值
    case WITHDRAW = 'WITHDRAW';             // 提现
    case TRANSFER = 'TRANSFER';             // 账户内
    case USER_TRANSFER = 'USER_TRANSFER';   // 账户外
    case ORDER_FREEZE = 'ORDER_FREEZE';     // 下单冻结
    case ORDER_UNFREEZE = 'ORDER_UNFREEZE'; // 撤单解冻
    case FEE = 'FEE';                       // 手续费
    case REBATE = 'REBATE';                 // 返佣
    case INTEREST = 'INTEREST';             // 利息

    //方向
    case IN = 'IN';       // 入账
    case OUT = 'OUT';     // 出账

    /**
     * 获取变动类型描述
     */
    public function description(): string
    {
        return match ($this) {
            self::DEPOSIT => '充值',
            self::WITHDRAW => '提现',
            self::TRANSFER => '账户内',
            self::USER_TRANSFER => '账户外',
            self::ORDER_FREEZE => '下单冻结',
            self::ORDER_UNFREEZE => '撤单解冻',
            self::FEE => '手续费',
            self::REBATE => '返佣',
            self::INTEREST => '利息收益',
            self::IN => '入账',
            self::OUT => '出账',
        };
    }
}
