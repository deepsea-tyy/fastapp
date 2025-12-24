<?php

declare(strict_types=1);

namespace App\Model\Search;

use Hyperf\DbConnection\Model\Model;

/**
 * 搜索索引表模型
 *
 * @property int $id
 * @property string $target_type 内容类型
 * @property int $target_id 内容ID
 * @property string $title 标题
 * @property array $tags 标签
 * @property array $keyword 搜索词
 * @property int $weight 权重
 * @property \Carbon\Carbon $last_at 发布时间
 */
class SearchIndex extends Model
{
    protected ?string $table = 'search_index';

    public bool $timestamps = false;

    protected array $fillable = [
        'target_type',
        'target_id',
        'title',
        'content',
        'tags',
        'keyword',
        'weight',
        'last_at',
    ];

    protected array $casts = [
        'target_id' => 'integer',
        'tags' => 'array',
        'keyword' => 'array',
        'last_at' => 'datetime',
    ];

    protected function asJson(mixed $value): false|string
    {
        return json_encode($value, JSON_UNESCAPED_UNICODE);
    }
}
