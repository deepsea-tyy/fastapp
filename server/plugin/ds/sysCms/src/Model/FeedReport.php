<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id 主键
 * @property int $user_id 举报用户ID
 * @property int $target_type 目标类型：1帖子 2文章 3公告 4新闻 5评论
 * @property int $target_id 目标ID
 * @property int $report_type 举报原因：1垃圾广告 2色情低俗 3违法违规 4侮辱谩骂 5其他
 * @property string $content 举报说明
 * @property array $images 举报图片
 * @property int $handle_status 处理状态：0待处理 1已处理 2已忽略
 * @property string $handled_at 处理时间
 * @property \Carbon\Carbon $created_at
 * @property \Carbon\Carbon $updated_at
 */
class FeedReport extends Model
{
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'feed_report';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'user_id', 'target_type', 'target_id', 'report_type', 'content', 'images', 'handle_status', 'handled_at', 'created_at', 'updated_at'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = [
        'id' => 'integer',
        'user_id' => 'integer',
        'target_type' => 'integer',
        'target_id' => 'integer',
        'report_type' => 'integer',
        'images' => 'array',
        'handle_status' => 'integer',
        'handled_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];
}
