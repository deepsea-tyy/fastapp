<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * @property int $user_id 关注者ID
 * @property int $follow_user_id 被关注者ID
 * @property string $created_at 关注时间
 */
class FeedUserFollow extends Model
{
    public bool $incrementing = false;
    protected string $primaryKey = 'user_id';
    protected ?string $table = 'feed_user_follow';

    public bool $timestamps = false;

    protected array $fillable = ['user_id', 'follow_user_id', 'created_at'];

    protected array $casts = ['user_id' => 'integer', 'follow_user_id' => 'integer'];
}
