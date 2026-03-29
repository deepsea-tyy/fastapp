<?php

declare(strict_types=1);

namespace App\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id
 * @property int $user_id 用户id
 * @property int $type 类型 1:登录,2:注册,3:重置密码,4:绑定手机,5:绑定邮箱,6:解绑手机,7:解绑邮箱,8:禁用账户,9:删除账户,10:绑定2fa,11:解绑2fa
 * @property string $ip
 * @property string $os 操作系统
 * @property string $device_id 设备唯一标识（iOS/Android/Web通用）
 * @property string $country_code 国家代码
 * @property string $country 国家
 * @property string $region 省
 * @property string $city 市
 * @property string $created_at
 */
class UserAccountLog extends Model
{
    public const UPDATED_AT = null;
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'user_account_log';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'user_id', 'type', 'ip', 'os', 'device_id', 'country_code', 'country', 'region', 'city', 'created_at'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = ['id' => 'integer', 'user_id' => 'integer', 'type' => 'integer'];
}
