<?php

declare(strict_types=1);

namespace Plugin\Ds\SysKefu\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id 规则ID
 * @property string $title 规则名称
 * @property int $trigger_type 触发类型：1=关键词精确匹配，2=关键词模糊匹配，3=正则匹配
 * @property array $keywords 关键词列表（JSON数组）
 * @property int $reply_type 回复类型：1=纯文本，2=图片，3=文件，4=多条消息
 * @property array $reply_content 回复内容（JSON格式）
 * @property string $lang 语言
 * @property int $priority 优先级
 * @property int $status 状态：0=禁用，1=启用
 * @property int $hit_count 命中次数
 * @property \Carbon\Carbon $created_at
 * @property \Carbon\Carbon $updated_at
 * @property int $created_by 创建者
 * @property int $updated_by 更新者
 */
class KefuAutoReply extends Model
{
    /**
     * 触发类型：精确匹配
     */
    public const TRIGGER_TYPE_EXACT = 1;

    /**
     * 触发类型：模糊匹配
     */
    public const TRIGGER_TYPE_FUZZY = 2;

    /**
     * 触发类型：正则匹配
     */
    public const TRIGGER_TYPE_REGEX = 3;

    /**
     * 回复类型：纯文本
     */
    public const REPLY_TYPE_TEXT = 1;

    /**
     * 回复类型：图片
     */
    public const REPLY_TYPE_IMAGE = 2;

    /**
     * 回复类型：文件
     */
    public const REPLY_TYPE_FILE = 3;

    /**
     * 回复类型：多条消息
     */
    public const REPLY_TYPE_MULTIPLE = 4;

    /**
     * 状态：禁用
     */
    public const STATUS_DISABLED = 0;

    /**
     * 状态：启用
     */
    public const STATUS_ENABLED = 1;

    /**
     * The table associated with the model.
     */
    protected ?string $table = 'kefu_auto_reply';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = [
        'id',
        'title',
        'trigger_type',
        'keywords',
        'reply_type',
        'reply_content',
        'lang',
        'priority',
        'status',
        'hit_count',
        'created_at',
        'updated_at',
        'created_by',
        'updated_by',
    ];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = [
        'id' => 'integer',
        'keywords' => 'array',
        'reply_content' => 'array',
        'trigger_type' => 'integer',
        'reply_type' => 'integer',
        'priority' => 'integer',
        'status' => 'integer',
        'hit_count' => 'integer',
        'created_by' => 'integer',
        'updated_by' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];
}
