<?php

declare(strict_types=1);
namespace Plugin\Ds\Ex\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * 用户优惠券表模型
 *
 * @property int $id
 * @property int $uid 用户ID
 * @property int $coupon_id 优惠券ID
 * @property string $code 优惠券码
 * @property int $status 状态
 * @property int $source_type 来源
 * @property int $source_id 来源ID
 * @property \Carbon\Carbon $receive_time 领取时间
 * @property \Carbon\Carbon $use_time 使用时间
 * @property \Carbon\Carbon $expire_time 过期时间
 * @property string $order_id 使用订单号
 * @property \Carbon\Carbon $created_at 创建时间
 * @property \Carbon\Carbon $updated_at 更新时间
 */
class ExUserCoupon extends Model
{
    protected ?string $table = 'ex_user_coupons';

    protected array $fillable = [
        'uid',
        'coupon_id',
        'code',
        'status',
        'source_type',
        'receive_time',
        'use_time',
        'expire_time',
        'order_id',
    ];

    protected array $casts = [
        'id' => 'integer',
        'uid' => 'integer',
        'coupon_id' => 'integer',
        'status' => 'integer',
        'source_type' => 'integer',
        'receive_time' => 'datetime',
        'use_time' => 'datetime',
        'expire_time' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected array $hidden = [];
}
