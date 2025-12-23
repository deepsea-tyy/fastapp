<?php

declare(strict_types=1);
namespace App\Model\Search;

use Hyperf\DbConnection\Model\Model;

/**
 * 搜索关键词记录表模型
 *
 * @property string $keyword 搜索关键词
 * @property int $hit_count 命中次数
 * @property string $icon 图标名称
 * @property string $color 图标颜色(十六进制)
 * @property int $source 来源:1=用户搜索,2=热门推荐,3=系统推荐
 * @property int $sort 排序(数字越大越靠前)
 * @property \Carbon\Carbon $last_searched_at 最后搜索时间
 * @property \Carbon\Carbon $created_at 创建时间
 * @property \Carbon\Carbon $updated_at 更新时间
 */
class Keyword extends Model
{
    protected ?string $table = 'keyword';

    protected array $fillable = [
        'keyword',
        'hit_count',
        'icon',
        'color',
        'source',
        'sort',
        'last_searched_at',
        'created_at',
        'updated_at',
    ];

    protected array $casts = [
        'keyword' => 'string',
        'hit_count' => 'integer',
        'icon' => 'string',
        'color' => 'string',
        'source' => 'integer',
        'sort' => 'integer',
        'last_searched_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];
    protected array $hidden = [];
}
