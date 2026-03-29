<?php

declare(strict_types=1);
namespace Plugin\Ds\SysCms\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * 投放位置表模型
 *
 * @property string $code 调用代码（唯一标识符，如：home_banner）
 * @property string $name 位置名称
 * @property int $status 状态：1启用 0禁用
 * @property int $created_by 创建者
 * @property int $updated_by 更新者
 * @property \Carbon\Carbon $created_at 创建时间
 * @property \Carbon\Carbon $updated_at 更新时间
 */
class PlacementPosition extends Model
{
    protected ?string $table = 'placement_position';

    protected array $fillable = [
        'code',
        'name',
        'status',
        'created_by',
        'updated_by',
        'created_at',
        'updated_at',
    ];

    protected array $casts = [
        'code' => 'string',
        'name' => 'string',
        'status' => 'integer',
        'created_by' => 'integer',
        'updated_by' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];
    protected array $hidden = [];
}
