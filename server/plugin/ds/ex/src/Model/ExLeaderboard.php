<?php

declare(strict_types=1);
namespace Plugin\Ds\Ex\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * 排行榜表模型
 *
 * @property int $id
 * @property int $activity_id 活动ID
 * @property int $uid 用户ID
 * @property int $ranking 排名
 * @property float $score 积分/成绩
 * @property string $score_type 成绩类型
 * @property array $detail_data 详细数据
 * @property int $reward_tier 奖励档位
 * @property int $is_claimed 是否已领取奖励
 * @property \Carbon\Carbon $snapshot_time 快照时间
 * @property \Carbon\Carbon $created_at 创建时间
 * @property \Carbon\Carbon $updated_at 更新时间
 */
class ExLeaderboard extends Model
{
    protected ?string $table = 'ex_leaderboards';

    protected array $fillable = [
        'activity_id',
        'uid',
        'ranking',
        'score',
        'score_type',
        'is_claimed',
        'snapshot_time',
    ];

    protected array $casts = [
        'id' => 'integer',
        'activity_id' => 'integer',
        'uid' => 'integer',
        'ranking' => 'integer',
        'score' => 'decimal:8',
        'is_claimed' => 'integer',
        'snapshot_time' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected array $hidden = [];
}
