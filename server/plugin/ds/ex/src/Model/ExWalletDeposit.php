<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id 主键
 * @property int $user_id 用户ID
 * @property int $address_id 充值地址ID
 * @property string $symbol 币种
 * @property string $network 网络类型
 * @property string $from_address 来源地址
 * @property string $to_address 充值地址
 * @property string $amount 充值金额
 * @property string $txid 交易哈希
 * @property int $confirmations 确认数
 * @property int $required_confirmations 需要确认数
 * @property int $status 状态 1待确认 2已完成 3失败
 * @property int $credited 是否已入账 0否 1是
 * @property string $credited_at 入账时间
 * @property \Carbon\Carbon $created_at 
 * @property \Carbon\Carbon $updated_at 
 */
class ExWalletDeposit extends Model
{
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'ex_wallet_deposits';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'user_id', 'address_id', 'symbol', 'network', 'from_address', 'to_address', 'amount', 'txid', 'confirmations', 'required_confirmations', 'status', 'credited', 'credited_at', 'created_at', 'updated_at'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = ['id' => 'integer', 'user_id' => 'integer', 'address_id' => 'integer', 'confirmations' => 'integer', 'required_confirmations' => 'integer', 'status' => 'integer', 'credited' => 'integer', 'created_at' => 'datetime', 'updated_at' => 'datetime'];
}
