<?php

declare(strict_types=1);

namespace Plugin\Ds\Kefu\Model;

use Hyperf\Database\Model\Relations\HasMany;
use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id ID
 * @property string $nickname 昵称
 * @property string $avatar 头像
 * @property int $status 1启用2禁用
 * @property int $max_concurrent 最大会话数
 * @property int $current_concurrent 当前会话数
 * @property \Carbon\Carbon $created_at
 * @property \Carbon\Carbon $updated_at
 * @property int $created_by 创建者
 * @property int $updated_by 更新者
 */
class Kefu extends Model
{
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'kefu';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'nickname', 'avatar', 'status', 'max_concurrent', 'current_concurrent', 'created_at', 'updated_at', 'created_by', 'updated_by'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = ['id' => 'integer', 'status' => 'integer', 'max_concurrent' => 'integer', 'current_concurrent' => 'integer', 'created_at' => 'datetime', 'updated_at' => 'datetime', 'created_by' => 'integer', 'updated_by' => 'integer'];

    public function conversation(): HasMany
    {
        return $this->hasMany(KefuConversation::class, 'kefu_id', 'id')->orderBy('last_message_at', 'desc');
    }

    public function visitor(): HasMany
    {
        return $this->hasMany(KefuVisitor::class, 'kefu_id', 'id')
            ->select(['kefu_id', 'visitor_id'])
            ->groupBy(['visitor_id']);
    }
}
