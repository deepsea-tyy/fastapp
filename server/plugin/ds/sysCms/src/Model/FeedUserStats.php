<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * 用户统计表
 * @property int $user_id 用户ID
 * @property int $following_count 关注数
 * @property int $followers_count 粉丝数
 * @property int $posts_count 帖子数
 * @property int $total_likes 获得的总点赞数
 * @property int $total_shares 获得的总分享数
 * @property int $total_comments 获得的总评论数
 * @property int $total_views 获得的总浏览数
 * @property \Carbon\Carbon $created_at
 * @property \Carbon\Carbon $updated_at
 */
class FeedUserStats extends Model
{
    protected ?string $table = 'feed_user_stats';

    protected string $primaryKey = 'user_id';

    public bool $incrementing = false;

    protected array $fillable = [
        'user_id',
        'following_count',
        'followers_count',
        'posts_count',
        'total_likes',
        'total_shares',
        'total_comments',
        'total_views',
        'created_at',
        'updated_at',
    ];

    protected array $casts = [
        'user_id' => 'integer',
        'following_count' => 'integer',
        'followers_count' => 'integer',
        'posts_count' => 'integer',
        'total_likes' => 'integer',
        'total_shares' => 'integer',
        'total_comments' => 'integer',
        'total_views' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * 获取或创建用户统计记录
     */
    public static function getOrCreate(int $userId): self
    {
        $stats = self::query()->find($userId);

        if (!$stats) {
            $stats = self::create([
                'user_id' => $userId,
                'following_count' => 0,
                'followers_count' => 0,
                'posts_count' => 0,
                'total_likes' => 0,
                'total_shares' => 0,
                'total_comments' => 0,
                'total_views' => 0,
            ]);
        }

        return $stats;
    }
}
