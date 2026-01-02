<?php

declare(strict_types=1);
namespace Plugin\Ds\Ex\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * 返佣记录表模型
 *
 * @property int $id
 * @property int $invitation_id 邀请关系ID
 * @property int $inviter_uid 邀请人ID
 * @property int $invitee_uid 被邀请人ID
 * @property int $source_type 返佣来源
 * @property string $source_id 来源订单号
 * @property float $trade_amount 交易金额
 * @property float $commission_rate 返佣比例
 * @property float $commission_amount 返佣金额
 * @property string $symbol 返佣币种
 * @property int $status 状态
 * @property \Carbon\Carbon $settled_at 结算时间
 * @property int $level 返佣层级
 * @property string $remark 备注
 * @property \Carbon\Carbon $created_at 创建时间
 * @property \Carbon\Carbon $updated_at 更新时间
 */
class ExCommissionLog extends Model
{
    protected ?string $table = 'ex_commission_logs';

    protected array $fillable = [
        'inviter_uid',
        'invitee_uid',
        'source_type',
        'source_id',
        'trade_amount',
        'commission_rate',
        'commission_amount',
        'symbol',
        'status',
        'settled_at',
    ];

    protected array $casts = [
        'id' => 'integer',
        'inviter_uid' => 'integer',
        'invitee_uid' => 'integer',
        'source_type' => 'integer',
        'trade_amount' => 'decimal:8',
        'commission_rate' => 'decimal:4',
        'commission_amount' => 'decimal:8',
        'status' => 'integer',
        'settled_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected array $hidden = [];
}
