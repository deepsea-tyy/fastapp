<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * 行情Ticker数据表模型
 *
 * @property int $id ID
 * @property string $symbol 交易对符号（如：BTC/USDT）
 * @property string $market_type 市场类型（spot:现货, futures:合约, options:期权）
 * @property string $last_price 最新价格
 * @property string $open_price 24小时开盘价
 * @property string $high_price 24小时最高价
 * @property string $low_price 24小时最低价
 * @property string $volume 24小时成交量
 * @property string $amount 24小时成交额（计价货币）
 * @property string $quote_volume 24小时成交额（报价货币）
 * @property string $change_percent 24小时涨跌幅（百分比，如5.25表示5.25%）
 * @property string $change_amount 24小时涨跌额
 * @property string $bid_price 最佳买一价
 * @property string $bid_quantity 最佳买一量
 * @property string $ask_price 最佳卖一价
 * @property string $ask_quantity 最佳卖一量
 * @property string $funding_rate 当前资金费率（合约）
 * @property string $open_interest 持仓量（合约）
 * @property string $mark_price 标记价格（合约）
 * @property string $index_price 指数价格（合约）
 * @property \Carbon\Carbon $next_funding_time 下次资金费率结算时间（合约）
 * @property string $option_type 期权类型（call:看涨, put:看跌）
 * @property string $strike_price 行权价格（期权）
 * @property \Carbon\Carbon $expiry_date 到期时间（期权）
 * @property string $implied_volatility 隐含波动率（期权）
 * @property string $delta Delta（期权）
 * @property string $gamma Gamma（期权）
 * @property string $theta Theta（期权）
 * @property string $vega Vega（期权）
 * @property int $count 24小时成交笔数
 * @property int $timestamp 更新时间戳（毫秒）
 */
class MarketTicker extends Model
{
    protected ?string $table = 'market_ticker';
    public bool $timestamps = false;

    protected array $fillable = [
        'symbol',
        'market_type',
        'last_price',
        'open_price',
        'high_price',
        'low_price',
        'volume',
        'amount',
        'quote_volume',
        'change_percent',
        'change_amount',
        'bid_price',
        'bid_quantity',
        'ask_price',
        'ask_quantity',
        'funding_rate',
        'open_interest',
        'mark_price',
        'index_price',
        'next_funding_time',
        'option_type',
        'strike_price',
        'expiry_date',
        'implied_volatility',
        'delta',
        'gamma',
        'theta',
        'vega',
        'count',
        'timestamp',
    ];

    protected array $casts = [
        'id' => 'integer',
        'last_price' => 'decimal:8',
        'open_price' => 'decimal:8',
        'high_price' => 'decimal:8',
        'low_price' => 'decimal:8',
        'volume' => 'decimal:8',
        'amount' => 'decimal:8',
        'quote_volume' => 'decimal:8',
        'change_percent' => 'decimal:4',
        'change_amount' => 'decimal:8',
        'bid_price' => 'decimal:8',
        'bid_quantity' => 'decimal:8',
        'ask_price' => 'decimal:8',
        'ask_quantity' => 'decimal:8',
        'funding_rate' => 'decimal:8',
        'open_interest' => 'decimal:8',
        'mark_price' => 'decimal:8',
        'index_price' => 'decimal:8',
        'next_funding_time' => 'datetime',
        'strike_price' => 'decimal:8',
        'expiry_date' => 'datetime',
        'implied_volatility' => 'decimal:4',
        'delta' => 'decimal:6',
        'gamma' => 'decimal:6',
        'theta' => 'decimal:6',
        'vega' => 'decimal:6',
        'count' => 'integer',
        'timestamp' => 'integer',
    ];

    protected array $hidden = [];
}
