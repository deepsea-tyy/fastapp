<?php

declare(strict_types=1);


namespace Plugin\Ds\Article\Model;

use Carbon\Carbon;
use Hyperf\Database\Model\Relations\HasMany;
use Hyperf\DbConnection\Model\Model;

/**
 * 分类表模型.
 *
 * @property array $name 名称
 * @property string $icon icon
 * @property int $sort 排序
 * @property int $parent_id 上级
 * @property int $status 1显示
 * @property string $remark 备注
 * @property string $code 调用代码
 * @property int $created_by 创建者
 * @property int $updated_by 更新者
 * @property Carbon $created_at 创建时间
 * @property Carbon $updated_at 更新时间
 */
final class Category extends Model
{
    /**
     * 数据表名称.
     */
    protected ?string $table = 'category';

    /**
     * 允许批量赋值的属性.
     */
    protected array $fillable = [
        'name',
        'icon',
        'sort',
        'parent_id',
        'status',
        'remark',
        'code',
        'created_by',
        'updated_by',
        'created_at',
        'updated_at',
    ];

    /**
     * 数据转换设置.
     */
    protected array $casts = [
        'name' => 'array',
        'icon' => 'string',
        'sort' => 'integer',
        'parent_id' => 'integer',
        'status' => 'integer',
        'remark' => 'string',
        'code' => 'string',
        'created_by' => 'integer',
        'updated_by' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * 隐藏的属性.
     */
    protected array $hidden = [];


    public function children(): HasMany
    {
        return $this->hasMany(Category::class, 'parent_id', 'id');
    }
}