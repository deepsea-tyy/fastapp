<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * 信息流曝光记录模型
 *
 * @property int $id 主键
 * @property int $user_id 用户ID
 * @property int $content_id 内容ID
 * @property int $content_type 内容类型：1帖子 2文章 3公告 4新闻
 * @property int $feed_type Feed类型：1关注 2推荐
 * @property string $impressed_at 曝光时间
 */
class FeedImpression extends Model
{
    /**
     * 表名
     */
    protected ?string $table = 'feed_impression';

    /**
     * 禁用 updated_at 字段
     */
    public const UPDATED_AT = null;

    /**
     * 时间戳字段名
     */
    public const CREATED_AT = 'impressed_at';

    /**
     * 可批量赋值的属性
     */
    protected array $fillable = [
        'user_id',
        'content_id',
        'content_type',
        'feed_type',
        'impressed_at',
    ];

    /**
     * 属性类型转换
     */
    protected array $casts = [
        'id' => 'integer',
        'user_id' => 'integer',
        'content_id' => 'integer',
        'content_type' => 'integer',
        'feed_type' => 'integer',
        'impressed_at' => 'datetime',
    ];
}
