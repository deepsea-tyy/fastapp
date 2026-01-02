<?php

declare(strict_types=1);
namespace Plugin\Ds\Ex\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * 用户上下级关系模型
 *
 * @property int $id ID
 * @property int $uid 用户ID
 * @property int $parent_uid 上级用户ID
 * @property string $path 路径：从根节点到当前节点的完整路径，如 /1/2/3/
 * @property int $level 层级深度：0=根节点，1=一级下级，以此类推
 * @property \Carbon\Carbon $created_at 创建时间
 */
class ExUserRelation extends Model
{
    public const UPDATED_AT = null;
    protected ?string $table = 'ex_user_relations';

    protected array $fillable = [
        'uid',
        'parent_uid',
        'path',
        'level',
    ];

    protected array $casts = [
        'id' => 'integer',
        'uid' => 'integer',
        'parent_uid' => 'integer',
        'level' => 'integer',
        'created_at' => 'datetime',
    ];

    protected array $hidden = [];
}
