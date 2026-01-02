<?php

declare(strict_types=1);
namespace Plugin\Ds\Ex\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * 用户邀请码模型
 *
 * @property int $id ID
 * @property int $uid 用户ID
 * @property int $type 类型:1=默认
 * @property string|null $invite_code 邀请码
 * @property array|null $config 邀请码配置（JSON）
 * @property \Carbon\Carbon $created_at 创建时间
 */
class ExUserInviteCode extends Model
{
    public const UPDATED_AT = null;
    protected ?string $table = 'ex_user_invite_codes';

    protected array $fillable = [
        'uid',
        'type',
        'invite_code',
        'config',
    ];

    protected array $casts = [
        'id' => 'integer',
        'uid' => 'integer',
        'type' => 'integer',
        'config' => 'array',
        'created_at' => 'datetime',
    ];

    protected array $hidden = [];
}
