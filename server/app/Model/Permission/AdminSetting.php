<?php

declare(strict_types=1);

namespace App\Model\Permission;

use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id
 * @property int $user_id
 * @property string $phone 联系电话
 * @property array $dept_id 部门ID（数组）
 * @property array $backend_setting 后台设置数据
 */
class AdminSetting extends Model
{
    public bool $timestamps = false;
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'user_admin_setting';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'user_id', 'dept_id', 'phone', 'backend_setting'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = [
        'id' => 'integer',
        'user_id' => 'integer',
        'dept_id' => 'array',
        'backend_setting' => 'array'
    ];

    /**
     * 获取部门列表（dept_id 是数组，所以返回多个部门）
     * @return \Hyperf\Database\Model\Collection
     */
    public function departments(): \Hyperf\Database\Model\Collection
    {
        $deptIds = $this->dept_id ?? [];
        if (empty($deptIds)) {
            return \Hyperf\Database\Model\Collection::make([]);
        }
        return Department::query()->whereIn('id', $deptIds)->get();
    }
}
