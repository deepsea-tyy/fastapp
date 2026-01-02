<?php

declare(strict_types=1);
namespace Plugin\Ds\Ex\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * 用户任务记录表模型
 *
 * @property int $id
 * @property int $uid 用户ID
 * @property int $task_id 任务ID
 * @property int $activity_id 活动ID
 * @property int $status 状态
 * @property int $progress 当前进度
 * @property int $target 目标进度
 * @property array $progress_data 进度详细数据
 * @property \Carbon\Carbon $completed_at 完成时间
 * @property \Carbon\Carbon $claimed_at 领取奖励时间
 * @property array $reward_data 奖励数据
 * @property \Carbon\Carbon $expire_at 过期时间
 * @property string $date 任务日期
 * @property \Carbon\Carbon $created_at 创建时间
 * @property \Carbon\Carbon $updated_at 更新时间
 */
class ExUserTask extends Model
{
    protected ?string $table = 'ex_user_tasks';

    protected array $fillable = [
        'uid',
        'task_id',
        'activity_id',
        'status',
        'progress',
        'target',
        'progress_data',
        'completed_at',
        'claimed_at',
        'date',
    ];

    protected array $casts = [
        'id' => 'integer',
        'uid' => 'integer',
        'task_id' => 'integer',
        'activity_id' => 'integer',
        'status' => 'integer',
        'progress' => 'integer',
        'target' => 'integer',
        'progress_data' => 'array',
        'completed_at' => 'datetime',
        'claimed_at' => 'datetime',
        'date' => 'date',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected array $hidden = [];
}
