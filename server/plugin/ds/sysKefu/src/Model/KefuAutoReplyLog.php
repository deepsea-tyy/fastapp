<?php

declare(strict_types=1);

namespace Plugin\Ds\SysKefu\Model;

use Hyperf\Database\Model\Relations\BelongsTo;
use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id 日志ID
 * @property int $conversation_id 会话ID
 * @property int $user_id 用户ID
 * @property int $kefu_id 客服ID
 * @property int $rule_id 命中的规则ID
 * @property string $user_message 用户消息
 * @property array $reply_content 回复内容
 * @property string $lang 回复语言
 * @property \Carbon\Carbon $created_at
 * @property \Carbon\Carbon $updated_at
 */
class KefuAutoReplyLog extends Model
{
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'kefu_auto_reply_log';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = [
        'id',
        'conversation_id',
        'user_id',
        'kefu_id',
        'rule_id',
        'user_message',
        'reply_content',
        'lang',
        'created_at',
        'updated_at',
    ];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = [
        'id' => 'integer',
        'reply_content' => 'array',
        'conversation_id' => 'integer',
        'user_id' => 'integer',
        'kefu_id' => 'integer',
        'rule_id' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * 关联自动回复规则
     */
    public function rule(): BelongsTo
    {
        return $this->belongsTo(KefuAutoReply::class, 'rule_id');
    }

    /**
     * 关联会话
     */
    public function conversation(): BelongsTo
    {
        return $this->belongsTo(KefuConversation::class, 'conversation_id');
    }
}
