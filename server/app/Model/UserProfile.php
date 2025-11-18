<?php

declare(strict_types=1);

namespace App\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id
 * @property int $user_id 用户ID
 * @property string $nickname 用户昵称
 * @property string $avatar 用户头像
 * @property string $signed 个人签名
 * @property string $lang 言语
 * @property string $trans_password 交易密码
 * @property \Carbon\Carbon $created_at
 * @property \Carbon\Carbon $updated_at
 */
class UserProfile extends Model
{
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'user_profile';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'user_id', 'nickname', 'avatar', 'signed', 'lang', 'trans_password', 'created_at', 'updated_at'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = [
        'id' => 'integer',
        'user_id' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected array $hidden = ['trans_password'];
}