<?php

declare(strict_types=1);
namespace Plugin\Ds\Ex\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * 奖励发放记录表模型
 *
 * @property int $id
 * @property int $uid 用户ID
 * @property int $source_type 来源类型
 * @property int $source_id 来源ID
 * @property int $reward_type 奖励类型
 * @property string $reward_name 奖励名称
 * @property float $reward_amount 奖励数量
 * @property string $symbol 币种
 * @property array $reward_config 奖励配置详情
 * @property int $status 状态
 * @property \Carbon\Carbon $issued_at 发放时间
 * @property \Carbon\Carbon $expired_at 过期时间
 * @property string $remark 备注
 * @property \Carbon\Carbon $created_at 创建时间
 * @property \Carbon\Carbon $updated_at 更新时间
 */
class ExRewardLog extends Model
{
    protected ?string $table = 'ex_reward_logs';

    protected array $fillable = [
        'uid',
        'source_type',
        'source_id',
        'reward_type',
        'reward_name',
        'reward_amount',
        'symbol',
        'reward_config',
        'status',
        'issued_at',
        'remark',
    ];

    protected array $casts = [
        'id' => 'integer',
        'uid' => 'integer',
        'source_type' => 'integer',
        'source_id' => 'integer',
        'reward_type' => 'integer',
        'reward_amount' => 'decimal:8',
        'reward_config' => 'array',
        'status' => 'integer',
        'issued_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected array $hidden = [];
}
