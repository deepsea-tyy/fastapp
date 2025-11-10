<?php

declare(strict_types=1);

namespace Plugin\Ds\Kefu\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id ID
 * @property string $visitor_id 游客标识
 * @property string $kefu_id 客服ID
 * @property int $sender_type
 * @property string $content 消息内容
 * @property \Carbon\Carbon $created_at 
 * @property \Carbon\Carbon $updated_at 
 */
class KefuVisitor extends Model
{
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'kefu_visitor';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'visitor_id', 'kefu_id', 'sender_type', 'content', 'created_at', 'updated_at'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = [
        'id' => 'integer',
        'sender_type' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];
}

