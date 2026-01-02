<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * 现货交易限制表模型
 *
 * @property int $id 主键
 * @property int $user_id 用户ID
 * @property string|null $symbol 交易对符号(null表示全局)
 * @property float|null $max_order_quantity 单笔最大数量
 * @property float|null $max_order_notional 单笔最大金额
 * @property float|null $daily_buy_limit 每日买入限额
 * @property float|null $daily_sell_limit 每日卖出限额
 * @property int $is_trading_enabled 是否允许交易 0否 1是
 * @property \Carbon\Carbon $created_at 创建时间
 * @property \Carbon\Carbon $updated_at 更新时间
 */
class SpotTradeLimit extends Model
{
    protected ?string $table = 'ex_spot_trade_limits';

    protected array $fillable = [
        'user_id',
        'symbol',
        'max_order_quantity',
        'max_order_notional',
        'daily_buy_limit',
        'daily_sell_limit',
        'is_trading_enabled',
        'created_at',
        'updated_at',
    ];

    protected array $casts = [
        'user_id' => 'integer',
        'symbol' => 'string',
        'max_order_quantity' => 'decimal:18',
        'max_order_notional' => 'decimal:18',
        'daily_buy_limit' => 'decimal:18',
        'daily_sell_limit' => 'decimal:18',
        'is_trading_enabled' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected array $hidden = [];
}

