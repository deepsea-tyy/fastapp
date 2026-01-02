<?php

declare(strict_types=1);
namespace Plugin\Ds\Ex\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * 账户表模型
 *
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
 * @property \Carbon\Carbon $created_at 创建时间
 * @property \Carbon\Carbon $updated_at 更新时间
 */
class User extends Model
{
    protected ?string $table = 'user';

    protected array $fillable = [
        'username',
        'email',
        'code',
        'mobile',
        'password',
        'user_type',
        'status',
        'google2fa',
        'remark',
        'created_by',
        'updated_by',
        'created_at',
        'updated_at',
    ];

    protected array $casts = [
        'username' => 'string',
        'email' => 'string',
        'code' => 'integer',
        'mobile' => 'string',
        'password' => 'string',
        'user_type' => 'string',
        'status' => 'integer',
        'google2fa' => 'string',
        'remark' => 'string',
        'created_by' => 'integer',
        'updated_by' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];
    protected array $hidden = [
        'password',
        'google2fa',
    ];
}
