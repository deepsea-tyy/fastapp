<?php

declare(strict_types=1);
namespace Plugin\Ds\Ex\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * 用户邀请关系表模型
 *
 * @property int $id
 * @property int $inviter_uid 邀请人ID
 * @property int $invitee_uid 被邀请人ID
 * @property string $invitation_code 邀请码
 * @property int $status 状态
 * @property \Carbon\Carbon $register_time 注册时间
 * @property \Carbon\Carbon $kyc_time 完成实名时间
 * @property \Carbon\Carbon $first_trade_time 首次交易时间
 * @property float $total_trade_amount 累计交易额
 * @property float $total_commission 累计返佣金额
 * @property int $level 邀请层级
 * @property int $parent_invitation_id 上级邀请记录ID
 * @property \Carbon\Carbon $created_at 创建时间
 * @property \Carbon\Carbon $updated_at 更新时间
 */
class ExUserInvitation extends Model
{
    protected ?string $table = 'ex_user_invitations';

    protected array $fillable = [
        'inviter_uid',
        'invitee_uid',
        'invitation_code',
        'status',
        'register_time',
        'kyc_time',
        'first_trade_time',
        'total_trade_amount',
        'total_commission',
        'level',
    ];

    protected array $casts = [
        'id' => 'integer',
        'inviter_uid' => 'integer',
        'invitee_uid' => 'integer',
        'status' => 'integer',
        'register_time' => 'datetime',
        'kyc_time' => 'datetime',
        'first_trade_time' => 'datetime',
        'total_trade_amount' => 'decimal:8',
        'total_commission' => 'decimal:8',
        'level' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected array $hidden = [];
}
