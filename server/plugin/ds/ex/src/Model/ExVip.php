<?php

declare(strict_types=1);
namespace Plugin\Ds\Ex\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * VIP等级配置表模型
 *
 * @property int $id 主键ID
 * @property int $level VIP等级：0=普通用户,1-9=VIP1-VIP9
 * @property array $name 多语言名称
 * @property array $description 多语言描述
 * @property string $icon VIP图标URL
 * @property string $color VIP主题颜色
 * @property float $trading_volume_usdt 交易型VIP：30天交易量要求（USDT）
 * @property float $holder_wallet_asset_usd 持有者计划：钱包资产要求（USD）
 * @property float $holder_platform_token 持有者计划：平台币持有量要求
 * @property float $withdraw_limit_24h_usdt 24小时提现额度（USDT）
 * @property int $protection_days 降级保护天数
 * @property int $sort 排序
 * @property int $status 状态：1=启用,2=禁用
 * @property array $fee_rates 费率配置
 * @property array $privileges VIP特权配置
 * @property \Carbon\Carbon $created_at 创建时间
 * @property \Carbon\Carbon $updated_at 更新时间
 * @property \Carbon\Carbon|null $deleted_at 删除时间
 */
class ExVip extends Model
{
    use \Hyperf\Database\Model\SoftDeletes;

    protected ?string $table = 'ex_vip';

    protected array $fillable = [
        'level',
        'name',
        'description',
        'icon',
        'color',
        'trading_volume_usdt',
        'holder_wallet_asset_usd',
        'holder_platform_token',
        'withdraw_limit_24h_usdt',
        'protection_days',
        'sort',
        'status',
        'fee_rates',
        'privileges',
    ];

    protected array $casts = [
        'id' => 'integer',
        'level' => 'integer',
        'name' => 'array',
        'description' => 'array',
        'icon' => 'string',
        'color' => 'string',
        'trading_volume_usdt' => 'decimal:2',
        'holder_wallet_asset_usd' => 'decimal:2',
        'holder_platform_token' => 'decimal:8',
        'withdraw_limit_24h_usdt' => 'decimal:2',
        'protection_days' => 'integer',
        'sort' => 'integer',
        'status' => 'integer',
        'fee_rates' => 'array',
        'privileges' => 'array',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime',
    ];

    protected array $hidden = [];
}
