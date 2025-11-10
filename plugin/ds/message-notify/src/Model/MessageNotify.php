<?php

declare(strict_types=1);

namespace Plugin\Ds\MessageNotify\Model;

use Carbon\Carbon;
use Hyperf\DbConnection\Model\Model;

/**
 * 消息通知表模型.
 *
 * @property array $title 通知标题
 * @property array $content 通知内容
 * @property int $type 通知类型:1-全局,2-个人
 * @property int $user_id 用户ID 全局通知为0
 * @property int $notify_type 通知分类:1-系统通知,2-业务通知,3-其他
 * @property string $link 跳转链接
 * @property int $created_by 创建者
 * @property int $updated_by 更新者
 * @property Carbon $created_at 创建时间
 * @property Carbon $updated_at 更新时间
 */
class MessageNotify extends Model
{
    protected ?string $table = 'message_notify';

    protected array $fillable = [
        'title',
        'content',
        'type',
        'user_id',
        'notify_type',
        'link',
        'created_by',
        'updated_by',
        'created_at',
        'updated_at',
    ];

    protected array $casts = [
        'title' => 'array',
        'content' => 'array',
        'type' => 'integer',
        'user_id' => 'integer',
        'notify_type' => 'integer',
        'link' => 'string',
        'created_by' => 'integer',
        'updated_by' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected array $hidden = [];
}