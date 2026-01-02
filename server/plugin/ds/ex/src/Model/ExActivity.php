<?php

declare(strict_types=1);
namespace Plugin\Ds\Ex\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * 活动表模型
 *
 * @property int $id 活动ID
 * @property array $title 活动标题（多语言）
 * @property array $subtitle 活动副标题（多语言）
 * @property int $type 活动类型
 * @property int $status 状态
 * @property string $cover_image 活动封面图
 * @property string $banner_image 活动横幅图
 * @property array $description 活动详细描述
 * @property array $rules 活动规则配置
 * @property \Carbon\Carbon $start_time 活动开始时间
 * @property \Carbon\Carbon $end_time 活动结束时间
 * @property array $reward_config 奖励配置
 * @property int $participate_limit 参与人数限制
 * @property int $participated_count 已参与人数
 * @property float $budget_amount 活动预算金额
 * @property float $used_budget 已使用预算
 * @property int $sort_order 排序权重
 * @property int $is_hot 是否热门活动
 * @property int $is_recommend 是否推荐
 * @property array $tags 活动标签
 * @property string $entry_url 活动入口链接
 * @property int $created_by 创建人ID
 * @property \Carbon\Carbon $created_at 创建时间
 * @property \Carbon\Carbon $updated_at 更新时间
 * @property \Carbon\Carbon|null $deleted_at 删除时间
 */
class ExActivity extends Model
{
    use \Hyperf\Database\Model\SoftDeletes;

    protected ?string $table = 'ex_activities';

    protected array $fillable = [
        'title',
        'subtitle',
        'type',
        'status',
        'cover_image',
        'banner_image',
        'description',
        'rules',
        'start_time',
        'end_time',
        'reward_config',
        'participate_limit',
        'participated_count',
        'sort_order',
        'is_hot',
        'is_recommend',
    ];

    protected array $casts = [
        'id' => 'integer',
        'title' => 'array',
        'subtitle' => 'array',
        'type' => 'integer',
        'status' => 'integer',
        'description' => 'array',
        'rules' => 'array',
        'start_time' => 'datetime',
        'end_time' => 'datetime',
        'reward_config' => 'array',
        'participate_limit' => 'integer',
        'participated_count' => 'integer',
        'sort_order' => 'integer',
        'is_hot' => 'integer',
        'is_recommend' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime',
    ];

    protected array $hidden = [];
}
