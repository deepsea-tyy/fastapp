<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id 主键
 * @property int $user_id 分享用户ID
 * @property int $target_type 目标类型：1帖子 2文章 3公告 4新闻
 * @property int $target_id 目标ID
 * @property int $share_type 分享类型：1复制链接 2分享平台 3站内引用
 * @property string $platform 分享平台
 * @property string $created_at 分享时间
 */
class FeedShare extends Model
{
    public bool $timestamps = false;
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'feed_share';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'user_id', 'target_type', 'target_id', 'share_type', 'platform', 'created_at'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = ['id' => 'integer', 'user_id' => 'integer', 'target_type' => 'integer', 'target_id' => 'integer', 'share_type' => 'integer'];
}
