<?php

declare(strict_types=1);
namespace Plugin\Ds\Ex\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * 优惠券表模型
 *
 * @property int $id
 * @property string $code 优惠券码
 * @property array $name 优惠券名称（多语言）
 * @property int $type 类型
 * @property int $discount_type 折扣类型
 * @property float $discount_value 折扣值
 * @property float $min_amount 最低使用金额
 * @property float $max_discount 最高折扣金额
 * @property int $total_count 发行总量
 * @property int $used_count 已使用数量
 * @property int $per_user_limit 每人限领数量
 * @property int $valid_days 有效天数
 * @property \Carbon\Carbon $start_time 有效期开始
 * @property \Carbon\Carbon $end_time 有效期结束
 * @property array $applicable_symbols 适用交易对
 * @property int $status 状态
 * @property array $description 使用说明（多语言）
 * @property \Carbon\Carbon $created_at 创建时间
 * @property \Carbon\Carbon $updated_at 更新时间
 */
class ExCoupon extends Model
{
    protected ?string $table = 'ex_coupons';

    protected array $fillable = [
        'code',
        'name',
        'type',
        'discount_type',
        'discount_value',
        'min_amount',
        'total_count',
        'used_count',
        'per_user_limit',
        'valid_days',
        'start_time',
        'end_time',
        'status',
        'description',
    ];

    protected array $casts = [
        'id' => 'integer',
        'name' => 'array',
        'type' => 'integer',
        'discount_type' => 'integer',
        'discount_value' => 'decimal:4',
        'min_amount' => 'decimal:8',
        'total_count' => 'integer',
        'used_count' => 'integer',
        'per_user_limit' => 'integer',
        'valid_days' => 'integer',
        'start_time' => 'datetime',
        'end_time' => 'datetime',
        'status' => 'integer',
        'description' => 'array',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected array $hidden = [];
}
