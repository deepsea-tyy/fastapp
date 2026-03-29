<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * @property int $user_id 用户ID
 * @property int $feed_type 信息流类型：1帖子 2公告 3新闻
 * @property \Carbon\Carbon $last_read_at 最后阅读时间
 */
class FeedUserReadPosition extends Model
{
    public bool $incrementing = false;
    protected string $primaryKey = 'user_id';
    public const CREATED_AT = null;
    public const UPDATED_AT = 'last_read_at';
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'feed_user_read_position';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['user_id', 'feed_type', 'last_read_at'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = ['user_id' => 'integer', 'feed_type' => 'integer', 'last_read_at' => 'datetime'];
}
