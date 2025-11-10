<?php

declare(strict_types=1);

namespace Plugin\Ds\Invite\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * 用户邀请码模型
 *
 * @property int $id ID
 * @property int $user_id 用户ID
 * @property int $type 类型:1=默认
 * @property string|null $invite_code 邀请码
 * @property array|null $config 邀请码配置（JSON）
 * @property string $created_at 创建时间
 */
class UserInviteCode extends Model
{
    public const UPDATED_AT = null;
    protected ?string $table = 'user_invite_code';

    protected array $fillable = [
        'user_id',
        'type',
        'invite_code',
        'config',
    ];

    protected array $casts = [
        'id' => 'integer',
        'user_id' => 'integer',
        'type' => 'integer',
        'config' => 'array',
        'created_at' => 'datetime',
    ];
}

