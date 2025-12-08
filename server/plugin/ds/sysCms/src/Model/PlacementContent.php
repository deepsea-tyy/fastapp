<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Model;

use Hyperf\Database\Model\Relations\BelongsToMany;
use Hyperf\DbConnection\Model\Model;

/**
 * 投放内容表模型
 *
 * @property string $code 调用代码
 * @property string $name 内容名称
 * @property int $object_type 数据类型：1链接 2视频 3分享 4文章 5路径
 * @property int $object_id 关联数据ID（根据object_type关联不同表，object_type=4时关联article表）
 * @property string $url 链接地址（object_type=1）
 * @property int $target 链接打开方式：1当前窗口 2新窗口
 * @property array $title 标题（多语言，用于覆盖关联数据的标题）
 * @property string $cover 封面图片URL（用于覆盖关联数据的封面）
 * @property array $desc 描述（多语言，用于覆盖关联数据的描述）
 * @property array $content 分享内容（多语言，object_type=3分享时使用）
 * @property int $start_at 开始时间（时间戳）
 * @property int $end_at 结束时间（时间戳）
 * @property int $fixed 永久有效：1是 0否
 * @property int $status 状态：1显示 0隐藏
 * @property int $sort 排序
 * @property string $remark 备注
 * @property int $views 展示次数
 * @property int $clicks 点击次数
 * @property int $created_by 创建者
 * @property int $updated_by 更新者
 * @property \Carbon\Carbon $created_at 创建时间
 * @property \Carbon\Carbon $updated_at 更新时间
 */
class PlacementContent extends Model
{
    protected ?string $table = 'placement_content';

    protected array $fillable = [
        'code',
        'name',
        'object_type',
        'object_id',
        'url',
        'target',
        'title',
        'cover',
        'desc',
        'content',
        'start_at',
        'end_at',
        'fixed',
        'status',
        'sort',
        'remark',
        'views',
        'clicks',
        'created_by',
        'updated_by',
        'created_at',
        'updated_at',
    ];

    protected array $casts = [
        'code' => 'string',
        'name' => 'string',
        'object_type' => 'integer',
        'object_id' => 'integer',
        'url' => 'string',
        'target' => 'integer',
        'title' => 'array',
        'desc' => 'array',
        'content' => 'array',
        'start_at' => 'integer',
        'end_at' => 'integer',
        'fixed' => 'integer',
        'status' => 'integer',
        'sort' => 'integer',
        'remark' => 'string',
        'views' => 'integer',
        'clicks' => 'integer',
        'created_by' => 'integer',
        'updated_by' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];
    protected array $hidden = [];

    /**
     * 获取该内容关联的所有投放位置（多对多关系）
     * 
     * 关系说明：
     * - PlacementContent 通过中间表 placement_position_content 与 PlacementPosition 建立多对多关系
     * - 一个投放内容可以投放到多个位置
     * - 一个投放位置可以包含多个内容
     * 
     * @return BelongsToMany
     */
    public function positions(): BelongsToMany
    {
        return $this->belongsToMany(
            PlacementPosition::class,           // 关联的目标模型：投放位置
            'placement_position_content',        // 中间表名
            'content_id',                        // 中间表中指向当前模型的外键
            'position_id',                       // 中间表中指向目标模型的外键
            'id',                                // 当前模型的主键
            'id'                                 // 目标模型的主键
        );
    }
}
