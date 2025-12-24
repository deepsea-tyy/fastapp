<?php

declare(strict_types=1);

namespace App\Model\Search;

use Hyperf\DbConnection\Model\Model;
use Hyperf\Database\Model\SoftDeletes;

/**
 * 搜索索引表模型
 *
 * @property int $id
 * @property string $target_type 内容类型
 * @property int $target_id 内容ID
 * @property string $title 标题
 * @property string $content 内容摘要
 * @property string $author 作者
 * @property array $tags 标签
 * @property array $extra 扩展字段
 * @property int $weight 权重
 * @property int $view_count 浏览量
 * @property int $status 状态
 * @property \Carbon\Carbon $published_at 发布时间
 * @property \Carbon\Carbon $created_at
 * @property \Carbon\Carbon $updated_at
 * @property \Carbon\Carbon $deleted_at
 */
class SearchIndex extends Model
{
    use SoftDeletes;

    protected ?string $table = 'search_index';

    protected array $fillable = [
        'target_type',
        'target_id',
        'title',
        'content',
        'author',
        'tags',
        'extra',
        'weight',
        'view_count',
        'status',
        'published_at',
    ];

    protected array $casts = [
        'target_id' => 'integer',
        'tags' => 'array',
        'extra' => 'array',
        'weight' => 'integer',
        'view_count' => 'integer',
        'status' => 'integer',
        'published_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime',
    ];

    protected function asJson(mixed $value): false|string
    {
        return json_encode($value, JSON_UNESCAPED_UNICODE);
    }
}
