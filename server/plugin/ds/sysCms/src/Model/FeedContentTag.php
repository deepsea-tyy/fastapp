<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * @property int $target_type 目标类型：1帖子 2文章 3公告 4新闻
 * @property int $target_id 目标ID
 * @property int $tag_id 标签ID
 * @property string $created_at 创建时间
 */
class FeedContentTag extends Model
{
    public bool $incrementing = false;
    protected string $primaryKey = 'target_type';
    public bool $timestamps = false;
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'feed_content_tag';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['target_type', 'target_id', 'tag_id', 'created_at'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = ['target_type' => 'integer', 'target_id' => 'integer', 'tag_id' => 'integer'];
}
