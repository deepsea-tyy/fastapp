<?php

declare(strict_types=1);

namespace Plugin\Ds\Invite\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * 用户上下级关系模型
 *
 * @property int $id ID
 * @property int $user_id 用户ID
 * @property int $parent_id 上级ID
 * @property string $path 路径：从根节点到当前节点的完整路径，如 /1/2/3/
 * @property int $level 层级深度：0=根节点，1=一级下级，以此类推
 * @property string $created_at 创建时间
 */
class UserRelation extends Model
{
    public const UPDATED_AT = null;
    protected ?string $table = 'user_relation';

    protected array $fillable = [
        'user_id',
        'parent_id',
        'path',
        'level',
    ];

    protected array $casts = [
        'id' => 'integer',
        'user_id' => 'integer',
        'parent_id' => 'integer',
        'level' => 'integer',
        'created_at' => 'datetime',
    ];
}

