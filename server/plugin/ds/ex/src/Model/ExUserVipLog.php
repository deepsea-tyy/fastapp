<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * VIP升级记录表模型
 *
 * @property int $id 主键ID
 * @property int $user_id 用户ID
 * @property int $from_level 原VIP等级
 * @property int $to_level 新VIP等级
 * @property int $trigger_type 升级触发方式：1=持有者计划,2=交易型VIP,3=手动调整
 * @property string $action_type 操作类型：UPGRADE=升级,DOWNGRADE=降级,MANUAL_ADJUST=手动调整
 * @property string|null $downgrade_reason 降级原因
 * @property array|null $upgrade_data 升级时的数据快照
 * @property string|null $remark 备注说明
 * @property int|null $operator_id 操作人ID
 * @property string|null $operator_type 操作人类型：SYSTEM=系统,ADMIN=管理员
 * @property string|null $ip 操作IP地址
 * @property \Carbon\Carbon $created_at 创建时间
 */
class ExUserVipLog extends Model
{
    public const UPDATED_AT = null;

    // 触发类型常量
    public const TRIGGER_TYPE_HOLDER = 1;     // 持有者计划
    public const TRIGGER_TYPE_TRADING = 2;    // 交易型VIP
    public const TRIGGER_TYPE_MANUAL = 3;     // 手动调整

    // 操作类型常量
    public const ACTION_UPGRADE = 'UPGRADE';
    public const ACTION_DOWNGRADE = 'DOWNGRADE';
    public const ACTION_MANUAL_ADJUST = 'MANUAL_ADJUST';

    // 操作人类型常量
    public const OPERATOR_TYPE_SYSTEM = 'SYSTEM';
    public const OPERATOR_TYPE_ADMIN = 'ADMIN';

    // 降级原因常量
    public const DOWNGRADE_REASON_ASSET_DECREASED = 'ASSET_DECREASED';      // 资产减少
    public const DOWNGRADE_REASON_VOLUME_INSUFFICIENT = 'VOLUME_INSUFFICIENT'; // 交易量不足
    public const DOWNGRADE_REASON_EXPIRED = 'EXPIRED';                      // 到期
    public const DOWNGRADE_REASON_PROTECTION_END = 'PROTECTION_END';        // 保护期结束

    protected ?string $table = 'ex_user_vip_log';

    protected array $fillable = [
        'user_id',
        'from_level',
        'to_level',
        'trigger_type',
        'action_type',
        'downgrade_reason',
        'upgrade_data',
        'remark',
        'operator_id',
        'operator_type',
        'ip',
    ];

    protected array $casts = [
        'id' => 'integer',
        'user_id' => 'integer',
        'from_level' => 'integer',
        'to_level' => 'integer',
        'trigger_type' => 'integer',
        'action_type' => 'string',
        'downgrade_reason' => 'string',
        'upgrade_data' => 'array',
        'remark' => 'string',
        'operator_id' => 'integer',
        'operator_type' => 'string',
        'ip' => 'string',
        'created_at' => 'datetime',
    ];

    protected array $hidden = [];

    /**
     * 判断是否为升级
     */
    public function isUpgrade(): bool
    {
        return $this->to_level > $this->from_level;
    }

    /**
     * 判断是否为降级
     */
    public function isDowngrade(): bool
    {
        return $this->to_level < $this->from_level;
    }

    /**
     * 判断是否为系统操作
     */
    public function isSystemOperation(): bool
    {
        return $this->operator_type === self::OPERATOR_TYPE_SYSTEM;
    }

    /**
     * 判断是否为管理员操作
     */
    public function isAdminOperation(): bool
    {
        return $this->operator_type === self::OPERATOR_TYPE_ADMIN;
    }
}
