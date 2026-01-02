<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * 现货订单表模型
 *
 * @property int $id 主键
 * @property string $order_id 订单ID(唯一)
 * @property int $user_id 用户ID
 * @property int $symbol 交易对ID
 * @property string|null $client_order_id 客户端订单ID
 * @property string $side 方向 BUY/SELL
 * @property string $type 订单类型 LIMIT/MARKET/STOP_LOSS/STOP_LOSS_LIMIT/TAKE_PROFIT/TAKE_PROFIT_LIMIT
 * @property string $time_in_force 有效方式 GTC/IOC/FOK/GTX
 * @property float $price 委托价格
 * @property float $quantity 委托数量
 * @property float $quote_quantity 委托金额(市价买入用)
 * @property float $stop_price 触发价格
 * @property float $iceberg_quantity 冰山订单显示数量
 * @property float $executed_quantity 已成交数量
 * @property float $executed_quote_quantity 已成交金额
 * @property float $avg_price 成交均价
 * @property float $commission 手续费
 * @property string|null $commission_asset 手续费币种
 * @property string $status 订单状态 NEW/PARTIALLY_FILLED/FILLED/CANCELED/REJECTED/EXPIRED
 * @property string|null $reject_reason 拒绝原因
 * @property int $is_working 是否在订单簿中 0否 1是
 * @property \Carbon\Carbon|null $working_time 进入订单簿时间
 * @property \Carbon\Carbon|null $filled_at 完成时间
 * @property \Carbon\Carbon $created_at 创建时间
 * @property \Carbon\Carbon $updated_at 更新时间
 */
class SpotOrder extends Model
{
    protected ?string $table = 'ex_spot_orders';

    protected array $fillable = [
        'order_id',
        'user_id',
        'symbol',
        'client_order_id',
        'side',
        'type',
        'time_in_force',
        'price',
        'quantity',
        'quote_quantity',
        'stop_price',
        'iceberg_quantity',
        'executed_quantity',
        'executed_quote_quantity',
        'avg_price',
        'commission',
        'commission_asset',
        'status',
        'reject_reason',
        'is_working',
        'working_time',
        'filled_at',
        'created_at',
        'updated_at',
    ];

    protected array $casts = [
        'user_id' => 'integer',
        'symbol' => 'integer',
        'price' => 'decimal:18',
        'quantity' => 'decimal:18',
        'quote_quantity' => 'decimal:18',
        'stop_price' => 'decimal:18',
        'iceberg_quantity' => 'decimal:18',
        'executed_quantity' => 'decimal:18',
        'executed_quote_quantity' => 'decimal:18',
        'avg_price' => 'decimal:18',
        'commission' => 'decimal:18',
        'is_working' => 'integer',
        'working_time' => 'datetime',
        'filled_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected array $hidden = [];

    // 订单状态常量
    public const STATUS_NEW = 'NEW';
    public const STATUS_PARTIALLY_FILLED = 'PARTIALLY_FILLED';
    public const STATUS_FILLED = 'FILLED';
    public const STATUS_CANCELED = 'CANCELED';
    public const STATUS_REJECTED = 'REJECTED';
    public const STATUS_EXPIRED = 'EXPIRED';

    // 订单方向常量
    public const SIDE_BUY = 'BUY';
    public const SIDE_SELL = 'SELL';

    // 订单类型常量
    public const TYPE_LIMIT = 'LIMIT';
    public const TYPE_MARKET = 'MARKET';
    public const TYPE_STOP_LOSS = 'STOP_LOSS';
    public const TYPE_STOP_LOSS_LIMIT = 'STOP_LOSS_LIMIT';
    public const TYPE_TAKE_PROFIT = 'TAKE_PROFIT';
    public const TYPE_TAKE_PROFIT_LIMIT = 'TAKE_PROFIT_LIMIT';

    // 有效方式常量
    public const TIME_IN_FORCE_GTC = 'GTC'; // Good Till Cancel
    public const TIME_IN_FORCE_IOC = 'IOC'; // Immediate or Cancel
    public const TIME_IN_FORCE_FOK = 'FOK'; // Fill or Kill
    public const TIME_IN_FORCE_GTX = 'GTX'; // Good Till Crossing

    /**
     * 关联交易对
     */
    public function marketPair()
    {
        return $this->hasOne(MarketPair::class, 'id', 'symbol');
    }
}

