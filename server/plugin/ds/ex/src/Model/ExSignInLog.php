<?php

declare(strict_types=1);
namespace Plugin\Ds\Ex\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * 签到记录表模型
 *
 * @property int $id
 * @property int $uid 用户ID
 * @property string $sign_date 签到日期
 * @property int $continuous_days 连续签到天数
 * @property int $total_days 累计签到天数
 * @property int $reward_type 奖励类型
 * @property float $reward_amount 奖励数量
 * @property string $reward_symbol 奖励币种
 * @property \Carbon\Carbon $created_at 创建时间
 */
class ExSignInLog extends Model
{
    protected ?string $table = 'ex_sign_in_logs';

    public bool $timestamps = false;

    protected array $fillable = [
        'uid',
        'sign_date',
        'continuous_days',
        'total_days',
        'reward_type',
        'reward_amount',
        'reward_symbol',
    ];

    protected array $casts = [
        'id' => 'integer',
        'uid' => 'integer',
        'sign_date' => 'date',
        'continuous_days' => 'integer',
        'total_days' => 'integer',
        'reward_type' => 'integer',
        'reward_amount' => 'decimal:8',
        'created_at' => 'datetime',
    ];

    protected array $hidden = [];
}
