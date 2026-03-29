<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * App页面内容同步版本管理表模型
 *
 * @property int $id 主键
 * @property string $version 版本号（时间戳）
 * @property int $platform 平台：1Web 2App
 * @property string $file_path 文件路径
 * @property int $file_size 文件大小（字节）
 * @property int $record_count 记录数量
 * @property \Carbon\Carbon $generated_at 生成时间
 * @property \Carbon\Carbon $created_at 创建时间
 * @property \Carbon\Carbon $updated_at 更新时间
 */
class AppPageContentSync extends Model
{
    protected ?string $table = 'app_page_content_sync';

    protected array $fillable = [
        'version',
        'platform',
        'file_path',
        'file_size',
        'record_count',
        'generated_at',
        'created_at',
        'updated_at',
    ];

    protected array $casts = [
        'version' => 'string',
        'platform' => 'integer',
        'file_path' => 'string',
        'file_size' => 'integer',
        'record_count' => 'integer',
        'generated_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected array $hidden = [];
}

