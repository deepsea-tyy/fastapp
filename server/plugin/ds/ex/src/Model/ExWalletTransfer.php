<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id 主键
 * @property int $user_id 用户ID
 * @property string $from_wallet_type 源钱包类型
 * @property string $to_wallet_type 目标钱包类型
 * @property string $symbol 币种
 * @property string $amount 划转金额
 * @property int $status 状态 1成功 2失败 3处理中
 * @property \Carbon\Carbon $created_at 
 * @property \Carbon\Carbon $updated_at 
 */
class ExWalletTransfer extends Model
{
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'ex_wallet_transfers';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'user_id', 'from_wallet_type', 'to_wallet_type', 'symbol', 'amount', 'status', 'created_at', 'updated_at'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = ['id' => 'integer', 'user_id' => 'integer', 'status' => 'integer', 'created_at' => 'datetime', 'updated_at' => 'datetime'];
}
