<?php

declare(strict_types=1);

namespace Plugin\Ds\Kefu\Model;

use App\Model\UserProfile;
use Hyperf\Database\Model\Relations\HasOne;
use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id ID
 * @property int $kefu_id 关联客服
 * @property int $user_id 用户id
 * @property int $status 会话状态：1-进行中，2-已结束
 * @property string $last_message_at 最后消息时间
 * @property int $unread_count 未读消息数（用户侧）
 * @property int $kefu_unread_count 未读消息数（客服侧）
 * @property \Carbon\Carbon $created_at
 * @property \Carbon\Carbon $updated_at
 */
class KefuConversation extends Model
{
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'kefu_conversation';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'kefu_id', 'user_id', 'status', 'last_message_at', 'unread_count', 'kefu_unread_count', 'created_at', 'updated_at'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = ['id' => 'integer', 'kefu_id' => 'integer', 'user_id' => 'integer', 'status' => 'integer', 'unread_count' => 'integer', 'kefu_unread_count' => 'integer', 'created_at' => 'datetime', 'updated_at' => 'datetime'];

    public function kefu(): HasOne
    {
        return $this->hasOne(Kefu::class, 'id', 'kefu_id');
    }

    public function profile(): HasOne
    {
        return $this->hasOne(UserProfile::class, 'user_id', 'user_id');
    }
}
