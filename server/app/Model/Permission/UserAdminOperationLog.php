<?php

declare(strict_types=1);


namespace App\Model\Permission;

use Carbon\Carbon;
use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id
 * @property string $username 用户名
 * @property string $method 请求方式
 * @property string $router 请求路由
 * @property string $service_name 业务名称
 * @property string $ip 请求IP地址
 * @property Carbon $created_at 创建时间
 * @property Carbon $updated_at 更新时间
 * @property array $request_params 请求参数
 */
class UserAdminOperationLog extends Model
{
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'user_admin_operation_log';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'username', 'method', 'router', 'service_name', 'ip', 'request_params', 'created_at', 'updated_at'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = ['id' => 'integer', 'request_params' => 'array', 'created_at' => 'datetime', 'updated_at' => 'datetime'];
}
