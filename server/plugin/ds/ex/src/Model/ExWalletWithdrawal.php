<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id 主键
 * @property int $user_id 用户ID
 * @property string $symbol 币种
 * @property string $network 网络类型
 * @property string $to_address 提现地址
 * @property string $tag 标签/Memo
 * @property string $amount 提现金额
 * @property string $fee 手续费
 * @property string $actual_amount 实际到账金额
 * @property string $txid 交易哈希
 * @property int $status 状态 1待审核 2审核通过 3处理中 4已完成 5已拒绝 6已取消
 * @property int $audit_status 审核状态 1待审核 2通过 3拒绝
 * @property string $audit_remark 审核备注
 * @property int $audited_by 审核人ID
 * @property string $audited_at 审核时间
 * @property string $completed_at 完成时间
 * @property \Carbon\Carbon $created_at 
 * @property \Carbon\Carbon $updated_at 
 */
class ExWalletWithdrawal extends Model
{
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'ex_wallet_withdrawals';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'user_id', 'symbol', 'network', 'to_address', 'tag', 'amount', 'fee', 'actual_amount', 'txid', 'status', 'audit_status', 'audit_remark', 'audited_by', 'audited_at', 'completed_at', 'created_at', 'updated_at'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = ['id' => 'integer', 'user_id' => 'integer', 'status' => 'integer', 'audit_status' => 'integer', 'audited_by' => 'integer', 'created_at' => 'datetime', 'updated_at' => 'datetime'];
}
