<?php

declare(strict_types=1);


namespace Plugin\Ds\SystemConfig\Model;

use Carbon\Carbon;
use Hyperf\Database\Model\Relations\HasMany;
use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id 主键
 * @property string $name 配置组名称
 * @property string $code 配置组标识
 * @property string $icon 配置组图标
 * @property int $created_by 创建者
 * @property int $updated_by 更新者
 * @property Carbon $created_at 创建时间
 * @property Carbon $updated_at 更新时间
 * @property string $remark 备注
 */
class ConfigGroup extends Model
{
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'system_config_group';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'name', 'code', 'icon', 'created_by', 'updated_by', 'created_at', 'updated_at', 'remark'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = ['id' => 'integer', 'name' => 'array', 'created_by' => 'integer', 'updated_by' => 'integer', 'created_at' => 'datetime', 'updated_at' => 'datetime'];

    // 一对多关系，一个配置组可以有多个配置项
    public function info(): HasMany
    {
        return $this->hasMany(Config::class, 'group_code', 'code');
    }
}
