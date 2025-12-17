<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id 主键
 * @property string $name 标签名称（多语言）
 * @property string $icon 标签图标
 * @property string $color 标签颜色
 * @property int $post_count 内容数量
 * @property int $follow_count 关注数
 * @property int $is_hot 是否热门
 * @property int $status 状态：1启用 0禁用
 * @property \Carbon\Carbon $created_at 
 * @property \Carbon\Carbon $updated_at 
 */
class FeedTag extends Model
{
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'feed_tag';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'name', 'icon', 'color', 'post_count', 'follow_count', 'is_hot', 'status', 'created_at', 'updated_at'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = [
        'id' => 'integer',
        'name' => 'array',
        'post_count' => 'integer',
        'follow_count' => 'integer',
        'is_hot' => 'integer',
        'status' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];
}
