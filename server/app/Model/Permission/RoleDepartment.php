<?php

declare(strict_types=1);

namespace App\Model\Permission;

use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id 
 * @property int $role_id 角色id
 * @property int $dept_id 部门id
 * @property \Carbon\Carbon $created_at 
 * @property \Carbon\Carbon $updated_at 
 */
class RoleDepartment extends Model
{
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'role_belongs_department';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'role_id', 'dept_id', 'created_at', 'updated_at'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = ['id' => 'integer', 'role_id' => 'integer', 'dept_id' => 'integer', 'created_at' => 'datetime', 'updated_at' => 'datetime'];
}
