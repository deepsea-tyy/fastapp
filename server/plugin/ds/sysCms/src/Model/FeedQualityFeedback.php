<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id 主键
 * @property int $user_id 反馈用户ID
 * @property int $target_type 目标类型：1帖子 2文章 3公告 4新闻
 * @property int $target_id 目标ID
 * @property int $quality_type 质量类型：1对投资没有帮助 2内容质量差
 * @property string $created_at 反馈时间
 */
class FeedQualityFeedback extends Model
{
    public const UPDATED_AT = null;
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'feed_quality_feedback';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'user_id', 'target_type', 'target_id', 'quality_type', 'created_at'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = ['id' => 'integer', 'user_id' => 'integer', 'target_type' => 'integer', 'target_id' => 'integer', 'quality_type' => 'integer'];
}
