<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id 主键
 * @property int $user_id 用户ID
 * @property string $wallet_type 钱包类型: FUNDING/SPOT/FUTURES/MARGIN/EARN/OPTIONS
 * @property string $symbol 币种
 * @property string $available 可用余额
 * @property string $frozen 冻结余额
 * @property string $total 总余额
 * @property int $status 状态 1正常 2冻结
 * @property int $version 乐观锁版本号
 * @property \Carbon\Carbon $created_at 
 * @property \Carbon\Carbon $updated_at 
 */
class ExWalletBalance extends Model
{
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'ex_wallet_balances';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'user_id', 'wallet_type', 'symbol', 'available', 'frozen', 'total', 'status', 'version', 'created_at', 'updated_at'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = ['id' => 'integer', 'user_id' => 'integer', 'status' => 'integer', 'version' => 'integer', 'created_at' => 'datetime', 'updated_at' => 'datetime'];
}
