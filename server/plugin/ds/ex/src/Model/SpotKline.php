<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * 现货K线数据模型
 *
 * @property int $id 主键
 * @property string $symbol 交易对符号（如BTCUSDT）
 * @property string $interval 时间间隔 1m/5m/15m/1h/4h/1d/1w/1M
 * @property \Carbon\Carbon $open_time 开盘时间
 * @property float $open_price 开盘价
 * @property float $high_price 最高价
 * @property float $low_price 最低价
 * @property float $close_price 收盘价
 * @property float $volume 成交量
 * @property \Carbon\Carbon $close_time 收盘时间
 * @property float $quote_volume 成交额
 * @property int $trade_count 成交笔数
 * @property float $taker_buy_volume 主动买入量
 * @property float $taker_buy_quote_volume 主动买入额
 * @property \Carbon\Carbon $created_at 创建时间
 * @property \Carbon\Carbon $updated_at 更新时间
 */
class SpotKline extends Model
{
    protected ?string $table = 'ex_spot_klines';

    protected array $fillable = [
        'symbol',
        'interval',
        'open_time',
        'open_price',
        'high_price',
        'low_price',
        'close_price',
        'volume',
        'close_time',
        'quote_volume',
        'trade_count',
        'taker_buy_volume',
        'taker_buy_quote_volume',
    ];

    protected array $casts = [
        'symbol' => 'string',
        'interval' => 'string',
        'open_time' => 'datetime',
        'open_price' => 'decimal:18',
        'high_price' => 'decimal:18',
        'low_price' => 'decimal:18',
        'close_price' => 'decimal:18',
        'volume' => 'decimal:18',
        'close_time' => 'datetime',
        'quote_volume' => 'decimal:18',
        'trade_count' => 'integer',
        'taker_buy_volume' => 'decimal:18',
        'taker_buy_quote_volume' => 'decimal:18',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected array $hidden = [];
}

