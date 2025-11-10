<?php

declare(strict_types=1);

namespace App\Model;

use App\Http\Admin\Service\Permission\DataScopeTool;
use App\Model\Enums\User\Status;
use App\Model\Permission\AdminSetting;
use App\Model\Permission\Menu;
use App\Model\Permission\Role;
use Hyperf\Collection\Collection;
use Hyperf\Database\Model\Events\Creating;
use Hyperf\Database\Model\Events\Deleted;
use Hyperf\Database\Model\Relations\BelongsToMany;
use Hyperf\Database\Model\Relations\HasOne;
use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id ID
 * @property string $username 用户名
 * @property string $email 用户邮箱
 * @property int $code 手机code
 * @property string $mobile 手机
 * @property string $password 密码
 * @property string $user_type 用户类型:100=系统用户,200=普通用户,300=通用账户
 * @property int $status 状态:1=正常,2=停用
 * @property string $google2fa google2fa
 * @property string $remark 备注
 * @property int $created_by 创建者
 * @property int $updated_by 更新者
 * @property \Carbon\Carbon $created_at
 * @property \Carbon\Carbon $updated_at
 * @property AdminSetting|null $adminSetting 管理员设置关联
 * @property UserProfile|null $profile 用户信息关联
 */
final class User extends Model
{
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'user';

    /**
     * 隐藏的字段列表.
     * @var string[]
     */
    protected array $hidden = ['password', 'google2fa'];

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'username', 'password', 'user_type', 'mobile', 'email', 'status', 'google2fa', 'remark', 'code', 'created_by', 'updated_by', 'created_at', 'updated_at'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = [
        'id' => 'integer',
        'status' => 'integer',
        'user_type' => 'integer',
        'created_by' => 'integer',
        'updated_by' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'code' => 'integer',
    ];

    public function roles(): BelongsToMany
    {
        return $this->belongsToMany(Role::class, 'user_belongs_role');
    }

    public function adminSetting(): HasOne
    {
        return $this->hasOne(AdminSetting::class, 'user_id');
    }

    public function profile(): HasOne
    {
        return $this->hasOne(UserProfile::class, 'user_id');
    }

    public function deleted(Deleted $event): void
    {
        $this->getRoles()->detach();
        $this->adminSetting?->delete();
        $this->profile?->delete();
    }

    public function setPasswordAttribute($value): void
    {
        $this->attributes['password'] = password_hash((string)$value, \PASSWORD_DEFAULT);
    }

    public function creating(Creating $event): void
    {
        if (!$this->isDirty('password')) {
            $this->resetPassword();
        }
    }

    public function verifyPassword(string $password): bool
    {
        return password_verify($password, $this->password);
    }

    public function resetPassword(): void
    {
        $this->password = 123456;
    }

    public function isSuperAdmin(): bool
    {
        return  $this->getRoles()->contains('code', 'SuperAdmin');
    }

    public function getRoles(): Collection
    {
        return DataScopeTool::getCurrentUser($this->id)->roles;
    }

    /**
     * @return Collection<int, Menu>
     */
    public function getPermissions(): Collection
    {
        return $this->getRoles()
            ->where('status', Status::Normal)
            ->with('menus')
            ->orderBy('sort')
            ->get()
            ->pluck('menus')
            ->flatten()
            ->unique('id') // 根据菜单ID去重
            ->values();
    }

    public function hasPermission(string $permission): bool
    {
        return $this->getRoles()->whereRelation('menus', 'name', $permission)->exists();
    }
}