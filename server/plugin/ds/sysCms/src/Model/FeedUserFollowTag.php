<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * @property int $user_id 用户ID
 * @property int $tag_id 标签ID
 * @property string $created_at 关注时间
 */
class FeedUserFollowTag extends Model
{
    public bool $incrementing = false;
    protected string $primaryKey = 'user_id';
    public bool $timestamps = false;
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'feed_user_follow_tag';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['user_id', 'tag_id', 'created_at'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = ['user_id' => 'integer', 'tag_id' => 'integer'];
}
