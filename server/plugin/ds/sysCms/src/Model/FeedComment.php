<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Model;

use App\Model\UserProfile;
use Hyperf\Database\Model\Relations\HasMany;
use Hyperf\Database\Model\Relations\HasOne;
use Hyperf\Database\Model\SoftDeletes;
use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id 主键
 * @property int $target_type 目标类型：1帖子 2文章 3公告 4新闻
 * @property int $target_id 目标ID
 * @property int $user_id 评论用户ID
 * @property int $parent_id 父评论ID（0为顶级评论）
 * @property int $root_id 根评论ID（用于楼中楼）
 * @property int $reply_to_user_id 回复的用户ID
 * @property string $content 评论内容
 * @property string $images 图片列表（JSON数组）
 * @property int $like_count 点赞数
 * @property int $reply_count 回复数
 * @property int $status 状态：1显示 0隐藏
 * @property \Carbon\Carbon $created_at
 * @property \Carbon\Carbon $updated_at
 * @property string $deleted_at 软删除
 */
class FeedComment extends Model
{
    use SoftDeletes;

    /**
     * The table associated with the model.
     */
    protected ?string $table = 'feed_comment';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'target_type', 'target_id', 'user_id', 'parent_id', 'root_id', 'reply_to_user_id', 'content', 'images', 'like_count', 'reply_count', 'status', 'created_at', 'updated_at', 'deleted_at'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = [
        'id' => 'integer',
        'target_type' => 'integer',
        'target_id' => 'integer',
        'user_id' => 'integer',
        'parent_id' => 'integer',
        'root_id' => 'integer',
        'reply_to_user_id' => 'integer',
        'like_count' => 'integer',
        'reply_count' => 'integer',
        'status' => 'integer',
        'images' => 'array',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    public function children(): HasMany
    {
        return $this->hasMany(FeedComment::class, 'root_id', 'id');
    }

    public function profile(): HasOne
    {
        return $this->hasOne(UserProfile::class, 'user_id', 'user_id');
    }
}
