<?php

declare(strict_types=1);
namespace Plugin\Ds\Ex\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * 任务表模型
 *
 * @property int $id 任务ID
 * @property int $activity_id 关联活动ID
 * @property array $title 任务标题（多语言）
 * @property array $description 任务描述（多语言）
 * @property int $type 任务类型
 * @property array $task_config 任务配置
 * @property int $reward_type 奖励类型
 * @property array $reward_config 奖励配置
 * @property int $repeat_type 重复类型
 * @property int $priority 优先级
 * @property \Carbon\Carbon $start_time 任务开始时间
 * @property \Carbon\Carbon $end_time 任务结束时间
 * @property int $status 状态
 * @property int $complete_count 完成人次
 * @property string $icon 任务图标
 * @property string $category 任务分类
 * @property \Carbon\Carbon $created_at 创建时间
 * @property \Carbon\Carbon $updated_at 更新时间
 * @property \Carbon\Carbon|null $deleted_at 删除时间
 */
class ExTask extends Model
{
    use \Hyperf\Database\Model\SoftDeletes;

    protected ?string $table = 'ex_tasks';

    protected array $fillable = [
        'activity_id',
        'title',
        'description',
        'type',
        'task_config',
        'reward_type',
        'reward_config',
        'repeat_type',
        'priority',
        'start_time',
        'end_time',
        'status',
        'icon',
        'category',
    ];

    protected array $casts = [
        'id' => 'integer',
        'activity_id' => 'integer',
        'title' => 'array',
        'description' => 'array',
        'type' => 'integer',
        'task_config' => 'array',
        'reward_type' => 'integer',
        'reward_config' => 'array',
        'repeat_type' => 'integer',
        'priority' => 'integer',
        'start_time' => 'datetime',
        'end_time' => 'datetime',
        'status' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime',
    ];

    protected array $hidden = [];
}
