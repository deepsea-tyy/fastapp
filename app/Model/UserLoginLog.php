<?php

declare(strict_types=1);

namespace App\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id 
 * @property int $user_id 用户id
 * @property string $ip 
 * @property string $device 设备
 * @property string $country_code 国家代码
 * @property string $country 国家
 * @property string $region 省
 * @property string $city 市
 * @property string $created_at 
 */
class UserLoginLog extends Model
{
    public const UPDATED_AT = null;
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'user_login_log';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'user_id', 'ip', 'device', 'country_code', 'country', 'region', 'city', 'created_at'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = ['id' => 'integer', 'user_id' => 'integer'];
}
