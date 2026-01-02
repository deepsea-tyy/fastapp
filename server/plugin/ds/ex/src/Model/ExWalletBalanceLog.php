<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id 主键
 * @property int $user_id 用户ID
 * @property string $wallet_type 钱包类型
 * @property string $symbol 币种
 * @property string $change_type 变动类型
 * @property string $amount 变动金额(正数为增加,负数为减少)
 * @property string $available_before 变动前可用
 * @property string $available_after 变动后可用
 * @property string $frozen_before 变动前冻结
 * @property string $frozen_after 变动后冻结
 * @property string $ref_id 关联业务ID
 * @property string $ref_type 业务类型
 * @property string $remark 备注
 * @property \Carbon\Carbon $created_at 创建时间
 */
class ExWalletBalanceLog extends Model
{
    public const UPDATED_AT = null;
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'ex_wallet_balance_logs';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'user_id', 'wallet_type', 'symbol', 'change_type', 'amount', 'available_before', 'available_after', 'frozen_before', 'frozen_after', 'ref_id', 'ref_type', 'remark', 'created_at'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = ['id' => 'integer', 'user_id' => 'integer', 'created_at' => 'datetime'];
}
