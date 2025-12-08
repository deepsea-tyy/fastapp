<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * App页面内容表模型
 *
 * @property int $id 主键
 * @property string $code 内容标识（唯一，如：home.welcome.title）
 * @property string $page_code 页面标识（如：home, market, spot）
 * @property string $component_code 组件标识（如：top_bar, banner, quick_entrance）
 * @property int $content_type 内容类型：1固定文本 2列表数据 3富文本 4配置项
 * @property array $data 内容数据（JSON，根据content_type存储不同类型的数据：1=多语言文本{"zh_CN":"中文","en":"English"} 2=列表数据[] 3=富文本{} 4=配置项{}）
 * @property int $platform 平台：1Web 2App 3Both
 * @property int $start_at 开始时间（时间戳）
 * @property int $end_at 结束时间（时间戳）
 * @property int $fixed 永久有效：1是 0否
 * @property int $status 状态：1启用 0禁用
 * @property int $sort 排序
 * @property string $remark 备注
 * @property int $created_by 创建者
 * @property int $updated_by 更新者
 * @property \Carbon\Carbon $created_at 创建时间
 * @property \Carbon\Carbon $updated_at 更新时间
 */
class AppPageContent extends Model
{
    protected ?string $table = 'app_page_content';

    protected array $fillable = [
        'code',
        'page_code',
        'component_code',
        'content_type',
        'data',
        'platform',
        'start_at',
        'end_at',
        'fixed',
        'status',
        'sort',
        'remark',
        'created_by',
        'updated_by',
        'created_at',
        'updated_at',
    ];

    protected array $casts = [
        'code' => 'string',
        'page_code' => 'string',
        'component_code' => 'string',
        'content_type' => 'integer',
        'data' => 'array',
        'platform' => 'integer',
        'start_at' => 'integer',
        'end_at' => 'integer',
        'fixed' => 'integer',
        'status' => 'integer',
        'sort' => 'integer',
        'remark' => 'string',
        'created_by' => 'integer',
        'updated_by' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected array $hidden = [];
}

