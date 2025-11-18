<?php

declare(strict_types=1);

namespace Plugin\Ds\MessageNotify\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id ID
 * @property int $notify_type 通知分类
 * @property int $notify_id 已读最大ID
 * @property int $user_id 用户ID
 */
class MessageNotifyRead extends Model
{
    public bool $timestamps = false;
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'message_notify_read';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['notify_type', 'notify_id', 'user_id'];

    /**
     * 防止批量赋值的字段
     */
    protected array $guarded = ['id'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = ['id' => 'integer', 'notify_type' => 'integer', 'notify_id' => 'integer', 'user_id' => 'integer'];
}
