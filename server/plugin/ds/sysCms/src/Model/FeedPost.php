<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Model;

use App\Model\UserProfile;
use Hyperf\Database\Model\Relations\HasOne;
use Hyperf\Database\Model\SoftDeletes;
use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id 主键
 * @property int $user_id 发布用户ID
 * @property int $type 帖子类型：1短贴 2标题贴
 * @property int $content_type 内容类型：1纯文本 2图文 3视频 4链接
 * @property string $title 标题（可选）
 * @property string $content 内容
 * @property array $images 图片列表（JSON数组）
 * @property array $videos 视频列表（JSON数组）
 * @property string $link_url 外链地址
 * @property array $link_meta 链接元数据（标题、描述、封面等）
 * @property int $quoted_type 引用类型：1短贴 2标题贴
 * @property int $quoted_id 引用的内容ID
 * @property int $audit_status 审核状态：0待审核 1已通过 2已拒绝
 * @property string $audited_at 审核时间
 * @property int $is_top 是否置顶：0否 1是
 * @property int $is_hot 是否热门：0否 1是
 * @property int $status 状态：1显示 0隐藏
 * @property int $view_count 浏览次数
 * @property int $like_count 点赞数
 * @property int $comment_count 评论数
 * @property int $share_count 分享数
 * @property int $collect_count 收藏数
 * @property int $quote_count 引用数
 * @property string $ip 发布IP
 * @property string $device_type 设备类型：ios, android, web
 * @property \Carbon\Carbon $created_at
 * @property \Carbon\Carbon $updated_at
 * @property string $deleted_at 软删除
 */
class FeedPost extends Model
{
    use SoftDeletes;

    // 帖子类型常量
    public const TYPE_FEED = 1;    // 短贴
    public const TYPE_ARTICLE = 2; // 标题贴

    /**
     * The table associated with the model.
     */
    protected ?string $table = 'feed_post';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'user_id', 'type', 'content_type', 'title', 'content', 'images', 'videos', 'link_url', 'link_meta', 'quoted_type', 'quoted_id', 'audit_status', 'audited_at', 'is_top', 'is_hot', 'status', 'view_count', 'like_count', 'comment_count', 'share_count', 'collect_count', 'quote_count', 'ip', 'device_type', 'created_at', 'updated_at', 'deleted_at'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = [
        'id' => 'integer',
        'user_id' => 'integer',
        'type' => 'integer',
        'content_type' => 'integer',
        'quoted_type' => 'integer',
        'quoted_id' => 'integer',
        'audit_status' => 'integer',
        'is_top' => 'integer',
        'is_hot' => 'integer',
        'status' => 'integer',
        'view_count' => 'integer',
        'like_count' => 'integer',
        'comment_count' => 'integer',
        'share_count' => 'integer',
        'collect_count' => 'integer',
        'quote_count' => 'integer',
        'images' => 'array',
        'videos' => 'array',
        'link_meta' => 'array',
        'audited_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    public function profile(): HasOne
    {
        return $this->hasOne(UserProfile::class, 'user_id', 'user_id');
    }
}
