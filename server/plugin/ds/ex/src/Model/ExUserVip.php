<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * 用户VIP信息表模型
 *
 * @property int $id 主键ID
 * @property int $user_id 用户ID
 * @property int $level 当前VIP等级：0=普通用户，取持有者计划和交易型的最高等级
 * @property int $holder_level 持有者计划等级（根据资产实时计算）
 * @property int $trading_level 交易型VIP等级（缓存）
 * @property int $primary_type 主要VIP获得方式：1=持有者计划,2=交易型VIP,3=手动赠送
 * @property \Carbon\Carbon|null $expired_at VIP到期时间，NULL表示永久VIP
 * @property \Carbon\Carbon|null $protection_until 降级保护截止时间
 * @property float $trading_volume_30d_usdt 30天交易量缓存，定时任务更新
 * @property \Carbon\Carbon|null $trading_volume_cached_at 交易量缓存时间
 * @property \Carbon\Carbon|null $last_calculated_at 最后一次计算VIP等级的时间
 * @property \Carbon\Carbon $created_at 创建时间
 * @property \Carbon\Carbon $updated_at 更新时间
 */
class ExUserVip extends Model
{
    protected ?string $table = 'ex_user_vip';

    protected array $fillable = [
        'user_id',
        'level',
        'holder_level',
        'trading_level',
        'primary_type',
        'expired_at',
        'protection_until',
        'trading_volume_30d_usdt',
        'trading_volume_cached_at',
        'last_calculated_at',
    ];

    protected array $casts = [
        'id' => 'integer',
        'user_id' => 'integer',
        'level' => 'integer',
        'holder_level' => 'integer',
        'trading_level' => 'integer',
        'primary_type' => 'integer',
        'expired_at' => 'datetime',
        'protection_until' => 'datetime',
        'trading_volume_30d_usdt' => 'decimal:2',
        'trading_volume_cached_at' => 'datetime',
        'last_calculated_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected array $hidden = [];

    /**
     * 关联VIP配置
     */
    public function vipConfig()
    {
        return $this->belongsTo(ExVip::class, 'level', 'level');
    }

    /**
     * 判断是否在降级保护期
     */
    public function isInProtectionPeriod(): bool
    {
        if (!$this->protection_until) {
            return false;
        }
        return $this->protection_until->isFuture();
    }

    /**
     * 判断VIP是否已过期
     */
    public function isExpired(): bool
    {
        if (!$this->expired_at) {
            return false;
        }
        return $this->expired_at->isPast();
    }

    /**
     * 判断是否为永久VIP
     */
    public function isPermanent(): bool
    {
        return $this->expired_at === null;
    }
}
