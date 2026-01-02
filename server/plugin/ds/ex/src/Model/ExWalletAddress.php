<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id 主键
 * @property int $user_id 用户ID
 * @property string $symbol 币种
 * @property string $network 网络类型: TRC20/ERC20/BTC/etc
 * @property string $address 钱包地址
 * @property int $address_type 地址类型 1充值 2提现
 * @property string $public_key 公钥
 * @property string $private_key 加密后的私钥
 * @property string $tag 标签/Memo(部分币种需要)
 * @property int $status 状态 1启用 2禁用
 * @property int $is_whitelist 是否白名单地址 0否 1是
 * @property string $last_used_at 最后使用时间
 * @property \Carbon\Carbon $created_at 
 * @property \Carbon\Carbon $updated_at 
 */
class ExWalletAddress extends Model
{
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'ex_wallet_addresses';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'user_id', 'symbol', 'network', 'address', 'address_type', 'public_key', 'private_key', 'tag', 'status', 'is_whitelist', 'last_used_at', 'created_at', 'updated_at'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = ['id' => 'integer', 'user_id' => 'integer', 'address_type' => 'integer', 'status' => 'integer', 'is_whitelist' => 'integer', 'created_at' => 'datetime', 'updated_at' => 'datetime'];
}
