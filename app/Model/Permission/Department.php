<?php

declare(strict_types=1);


namespace App\Model\Permission;

use App\Model\User;
use Carbon\Carbon;
use Hyperf\Database\Model\Collection;
use Hyperf\Database\Model\Relations\BelongsTo;
use Hyperf\Database\Model\Relations\HasMany;
use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id 主键
 * @property string $name 部门名称
 * @property string $code 部门代码
 * @property int $parent_id 父部门ID
 * @property int $sort 排序
 * @property int $status 状态 (1正常 2停用)
 * @property int $created_by 创建者
 * @property int $updated_by 更新者
 * @property Carbon $created_at 创建时间
 * @property Carbon $updated_at 更新时间
 * @property string $remark 备注
 * @property Collection|Department[] $children 子部门
 * @property Department|null $parent 父部门
 * @property Collection|User[] $users 部门用户
 */
final class Department extends Model
{
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'department';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = [
        'id', 'name', 'code', 'parent_id', 'sort', 'status', 'created_by', 'updated_by', 'created_at', 'updated_at', 'remark'
    ];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = [
        'id' => 'integer',
        'parent_id' => 'integer',
        'sort' => 'integer',
        'status' => 'integer',
        'created_by' => 'integer',
        'updated_by' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * 获取子部门
     */
    public function children(): HasMany
    {
        return $this->hasMany(Department::class, 'parent_id', 'id');
    }

    /**
     * 获取父部门
     */
    public function parent(): BelongsTo
    {
        return $this->belongsTo(Department::class, 'parent_id', 'id');
    }

    /**
     * 获取部门下的用户（通过 user_admin_setting 中间表）
     * 注意：dept_id 是 JSON 数组字段，需要使用 JSON 查询
     * @return Collection|User[]
     */
    public function users()
    {
        // 由于 dept_id 是 JSON 数组，hasManyThrough 不支持，使用自定义查询
        return User::query()
            ->whereHas('adminSetting', function ($query) {
                // JSON 数组字段查询：检查数组中是否包含当前部门ID
                $query->whereJsonContains('dept_id', $this->id);
            })
            ->get();
    }

    /**
     * 获取所有子部门ID（包括自己）
     */
    public function getAllChildrenIds(): array
    {
        $ids = [$this->id];
        $children = $this->children()->get();
        foreach ($children as $child) {
            $ids = array_merge($ids, $child->getAllChildrenIds());
        }
        return $ids;
    }
}
