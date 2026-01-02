<?php

declare(strict_types=1);
namespace Plugin\Ds\Ex\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * 用户活动参与表模型
 *
 * @property int $id
 * @property int $uid 用户ID
 * @property int $activity_id 活动ID
 * @property int $status 状态
 * @property \Carbon\Carbon $join_time 参与时间
 * @property \Carbon\Carbon $complete_time 完成时间
 * @property \Carbon\Carbon $claimed_time 领奖时间
 * @property array $progress_data 进度数据
 * @property int $ranking 排名
 * @property float $score 积分/成绩
 * @property \Carbon\Carbon $created_at 创建时间
 * @property \Carbon\Carbon $updated_at 更新时间
 */
class ExUserActivity extends Model
{
    protected ?string $table = 'ex_user_activities';

    protected array $fillable = [
        'uid',
        'activity_id',
        'status',
        'join_time',
        'complete_time',
        'claimed_time',
        'progress_data',
        'ranking',
        'score',
    ];

    protected array $casts = [
        'id' => 'integer',
        'uid' => 'integer',
        'activity_id' => 'integer',
        'status' => 'integer',
        'join_time' => 'datetime',
        'complete_time' => 'datetime',
        'claimed_time' => 'datetime',
        'progress_data' => 'array',
        'ranking' => 'integer',
        'score' => 'decimal:2',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected array $hidden = [];
}
