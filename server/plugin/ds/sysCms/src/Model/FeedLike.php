<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id 主键
 * @property int $user_id 点赞用户ID
 * @property int $target_type 目标类型：1帖子 2文章 3公告 4新闻 5评论
 * @property int $target_id 目标ID
 * @property string $created_at 点赞时间
 */
class FeedLike extends Model
{
    public bool $timestamps = false;
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'feed_like';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'user_id', 'target_type', 'target_id', 'created_at'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = ['id' => 'integer', 'user_id' => 'integer', 'target_type' => 'integer', 'target_id' => 'integer'];
}
