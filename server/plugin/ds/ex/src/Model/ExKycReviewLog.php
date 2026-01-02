<?php

declare(strict_types=1);
namespace Plugin\Ds\Ex\Model;

use Carbon\Carbon;
use Hyperf\DbConnection\Model\Model;

/**
 * KYC审核日志表模型
 *
 * @property int $id 主键ID
 * @property int $kyc_id 申请ID
 * @property int $user_id 用户ID
 * @property string $action 操作类型：AUTO_REVIEW=自动审核,MANUAL_REVIEW=人工审核,APPROVE=通过,REJECT=拒绝,CANCEL=取消
 * @property int|null $operator_id 操作人ID
 * @property string|null $operator_type 操作人类型：SYSTEM=系统,ADMIN=管理员
 * @property int|null $before_status 操作前状态
 * @property int|null $after_status 操作后状态（即当前状态）
 * @property string|null $remark 操作备注
 * @property string|null $ip_address 操作IP地址
 * @property string|null $user_agent 用户代理
 * @property Carbon|null $created_at 创建时间
 */
class ExKycReviewLog extends Model
{
    public const UPDATED_AT = null;

    protected ?string $table = 'ex_kyc_review_log';

    protected array $fillable = [
        'kyc_id',
        'user_id',
        'action',
        'operator_id',
        'operator_type',
        'before_status',
        'after_status',
        'remark',
        'ip_address',
        'user_agent',
        'created_at',
    ];

    protected array $casts = [
        'id' => 'integer',
        'kyc_id' => 'integer',
        'user_id' => 'integer',
        'action' => 'string',
        'operator_id' => 'integer',
        'operator_type' => 'string',
        'before_status' => 'integer',
        'after_status' => 'integer',
        'remark' => 'string',
        'ip_address' => 'string',
        'user_agent' => 'string',
        'created_at' => 'datetime',
    ];

    protected array $hidden = [];
}

