<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id 主键
 * @property int $source_id 采集源ID
 * @property int $task_status 任务状态：0待处理 1处理中 2已完成 3失败
 * @property string $start_at 开始时间
 * @property string $end_at 结束时间
 * @property int $success_count 成功数
 * @property int $fail_count 失败数
 * @property string $error_message 错误信息
 * @property string $created_at 创建时间
 */
class FeedCrawlerTask extends Model
{
    public bool $timestamps = false;
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'feed_crawler_task';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'source_id', 'task_status', 'start_at', 'end_at', 'success_count', 'fail_count', 'error_message', 'created_at'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = ['id' => 'integer', 'source_id' => 'integer', 'task_status' => 'integer', 'success_count' => 'integer', 'fail_count' => 'integer'];
}
