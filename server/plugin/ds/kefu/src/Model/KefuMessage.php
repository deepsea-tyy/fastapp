<?php

declare(strict_types=1);

namespace Plugin\Ds\Kefu\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id ID
 * @property int $conversation_id 会话ID
 * @property int $sender_id 发送者ID
 * @property int $sender_type 发送者类型：1-用户，2-客服
 * @property string $content 消息内容
 * @property int $message_type 消息类型：1-文本，2-图片，3-文件
 * @property string $file_url 文件URL（图片或文件类型时使用）
 * @property int $is_read 是否已读：0-未读，1-已读
 * @property \Carbon\Carbon $read_at 阅读时间
 * @property \Carbon\Carbon $created_at 
 * @property \Carbon\Carbon $updated_at 
 */
class KefuMessage extends Model
{
    /**
     * ID
     */
    public const FIELD_ID = 'id';
    /**
     * 会话ID
     */
    public const FIELD_CONVERSATION_ID = 'conversation_id';
    /**
     * 发送者ID
     */
    public const FIELD_SENDER_ID = 'sender_id';
    /**
     * 发送者类型：1-用户，2-客服
     */
    public const FIELD_SENDER_TYPE = 'sender_type';
    /**
     * 消息内容
     */
    public const FIELD_CONTENT = 'content';
    /**
     * 消息类型：1-文本，2-图片，3-文件
     */
    public const FIELD_MESSAGE_TYPE = 'message_type';
    /**
     * 文件URL（图片或文件类型时使用）
     */
    public const FIELD_FILE_URL = 'file_url';
    /**
     * 是否已读：0-未读，1-已读
     */
    public const FIELD_IS_READ = 'is_read';
    /**
     * 阅读时间
     */
    public const FIELD_READ_AT = 'read_at';
    /**
     * 创建时间
     */
    public const FIELD_CREATED_AT = 'created_at';
    /**
     * 更新时间
     */
    public const FIELD_UPDATED_AT = 'updated_at';
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'kefu_message';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'conversation_id', 'sender_id', 'sender_type', 'content', 'message_type', 'file_url', 'is_read', 'read_at', 'created_at', 'updated_at'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = [
        'id' => 'integer',
        'conversation_id' => 'integer',
        'sender_id' => 'integer',
        'sender_type' => 'integer',
        'message_type' => 'integer',
        'is_read' => 'integer',
        'read_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];
}
