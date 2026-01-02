<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Model;

use Hyperf\Database\Model\Relations\HasOne;
use Hyperf\DbConnection\Model\Model;

/**
 * 交易对数据表模型
 *
 * @property string $symbol 交易对符号（如：BTCUSDT, BTCETH）
 * @property string $base_currency_symbol 基础货币符号（关联currencies表的symbol）
 * @property string $quote_currency_symbol 计价货币符号（关联currencies表的symbol）
 * @property string $market_type 市场类型（spot:现货, futures:合约, option:期权）
 * @property string $settlement_currency_symbol 结算货币符号（合约结算币种，如USDT本位、币本位）
 * @property string $option_type 期权类型（call:看涨, put:看跌，仅期权）
 * @property string $exercise_style 行权方式（european:欧式, american:美式，仅期权）
 * @property float $strike_price 行权价格（仅期权）
 * @property \Carbon\Carbon $expiry_date 到期时间（仅期权）
 * @property string $underlying_asset_symbol 标的资产符号（仅期权，关联currencies表的symbol）
 * @property int $price_precision 价格精度（小数位数）
 * @property int $quantity_precision 数量精度（小数位数）
 * @property float $min_quantity 最小交易数量
 * @property float $max_quantity 最大交易数量
 * @property float $min_amount 最小交易金额（计价货币）
 * @property float $max_amount 最大交易金额（计价货币）
 * @property float $tick_size 价格步长（价格变动最小单位）
 * @property float $step_size 数量步长（数量变动最小单位）
 * @property float $maker_fee_rate Maker手续费率
 * @property float $taker_fee_rate Taker手续费率
 * @property int $leverage_enabled 是否支持杠杆（0:不支持, 1:支持）
 * @property int $max_leverage 最大杠杆倍数（如：10表示10倍杠杆）
 * @property float $maintenance_margin_rate 维持保证金率（合约）
 * @property int $funding_rate_interval 资金费率结算间隔（秒，合约，通常28800秒即8小时）
 * @property float $current_funding_rate 当前资金费率（合约，计算公式：溢价指数 + clamp(利率 - 溢价指数, 上限, 下限)）
 * @property float $premium_index 溢价指数（合约，用于计算资金费率，通常基于标记价格与现货价格差）
 * @property float $interest_rate 利率（合约，基础利率，通常0.01%即0.0001）
 * @property float $funding_rate_cap 资金费率上限（合约，通常0.05%即0.0005）
 * @property float $funding_rate_floor 资金费率下限（合约，通常-0.05%即-0.0005）
 * @property \Carbon\Carbon $next_funding_time 下次资金费率结算时间（合约）
 * @property float $mark_price 标记价格（合约，用于计算未实现盈亏）
 * @property float $contract_multiplier 合约乘数（合约，交割合约使用）
 * @property \Carbon\Carbon $delivery_date 交割日期（合约，交割合约使用，永续合约为NULL）
 * @property float $price_deviation_threshold 价格偏离保护阈值（百分比，如0.05表示5%，超过此阈值将暂停交易）
 * @property int $status 状态（0:禁用, 1:启用）
 * @property int $is_hot 是否热门（0:否, 1:是）
 * @property int $is_recommended 是否推荐（0:否, 1:是）
 * @property string $category 交易对分类（如：main, innovation, defi等）
 * @property int $sort 排序
 * @property \Carbon\Carbon $created_at 创建时间
 * @property \Carbon\Carbon $updated_at 更新时间
 */
class MarketPair extends Model
{
    protected ?string $table = 'market_pair';

    protected array $fillable = [
        'symbol',
        'base_currency_symbol',
        'quote_currency_symbol',
        'market_type',
        'settlement_currency_symbol',
        'option_type',
        'exercise_style',
        'strike_price',
        'expiry_date',
        'underlying_asset_symbol',
        'price_precision',
        'quantity_precision',
        'min_quantity',
        'max_quantity',
        'min_amount',
        'max_amount',
        'tick_size',
        'step_size',
        'maker_fee_rate',
        'taker_fee_rate',
        'leverage_enabled',
        'max_leverage',
        'maintenance_margin_rate',
        'funding_rate_interval',
        'current_funding_rate',
        'premium_index',
        'interest_rate',
        'funding_rate_cap',
        'funding_rate_floor',
        'next_funding_time',
        'mark_price',
        'contract_multiplier',
        'delivery_date',
        'price_deviation_threshold',
        'status',
        'is_hot',
        'is_recommended',
        'category',
        'sort',
        'created_at',
        'updated_at',
    ];

    protected array $casts = [
        'strike_price' => 'decimal:2',
        'expiry_date' => 'datetime',
        'price_precision' => 'integer',
        'quantity_precision' => 'integer',
        'min_quantity' => 'decimal:2',
        'max_quantity' => 'decimal:2',
        'min_amount' => 'decimal:2',
        'max_amount' => 'decimal:2',
        'tick_size' => 'decimal:2',
        'step_size' => 'decimal:2',
        'maker_fee_rate' => 'decimal:2',
        'taker_fee_rate' => 'decimal:2',
        'leverage_enabled' => 'integer',
        'max_leverage' => 'integer',
        'maintenance_margin_rate' => 'decimal:2',
        'funding_rate_interval' => 'integer',
        'current_funding_rate' => 'decimal:2',
        'premium_index' => 'decimal:2',
        'interest_rate' => 'decimal:2',
        'funding_rate_cap' => 'decimal:2',
        'funding_rate_floor' => 'decimal:2',
        'next_funding_time' => 'datetime',
        'mark_price' => 'decimal:2',
        'contract_multiplier' => 'decimal:2',
        'delivery_date' => 'datetime',
        'price_deviation_threshold' => 'decimal:2',
        'status' => 'integer',
        'is_hot' => 'integer',
        'is_recommended' => 'integer',
        'sort' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];
    protected array $hidden = [];

    public function baseCurrency(): HasOne
    {
        return $this->hasOne(Currency::class, 'symbol', 'base_currency_symbol');
    }

    public function quoteCurrency(): HasOne
    {
        return $this->hasOne(Currency::class, 'symbol', 'quote_currency_symbol');
    }

    public function settlementCurrency(): HasOne
    {
        return $this->hasOne(Currency::class, 'symbol', 'settlement_currency_symbol');
    }

    public function underlyingAsset(): HasOne
    {
        return $this->hasOne(Currency::class, 'symbol', 'underlying_asset_symbol');
    }
}
