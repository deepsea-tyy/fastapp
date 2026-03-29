<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id 主键
 * @property string $name 采集源名称
 * @property string $code 采集源代码
 * @property int $source_type 来源类型：1RSS 2API 3网页爬虫
 * @property string $source_url 来源地址
 * @property int $category_id 默认分类ID
 * @property string $config 采集配置
 * @property int $auto_publish 自动发布：0否 1是
 * @property int $fetch_interval 采集间隔（分钟）
 * @property string $last_fetch_at 最后采集时间
 * @property int $status 状态：1启用 0禁用
 * @property \Carbon\Carbon $created_at 
 * @property \Carbon\Carbon $updated_at 
 */
class FeedCrawlerSource extends Model
{
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'feed_crawler_source';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'name', 'code', 'source_type', 'source_url', 'category_id', 'config', 'auto_publish', 'fetch_interval', 'last_fetch_at', 'status', 'created_at', 'updated_at'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = [
        'id' => 'integer',
        'source_type' => 'integer',
        'category_id' => 'integer',
        'config' => 'array',
        'auto_publish' => 'integer',
        'fetch_interval' => 'integer',
        'status' => 'integer',
        'last_fetch_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];
}
