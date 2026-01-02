<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Http\Api\Service;

use App\Exception\BusinessException;
use Plugin\Ds\Ex\Model\ExKyc;

class ExKycService
{
    // KYC状态常量
    public const STATUS_PENDING = 0;      // 待审核
    public const STATUS_APPROVED = 1;     // 已通过
    public const STATUS_REJECTED = 2;     // 已拒绝
    public const STATUS_CANCELLED = 3;    // 已取消

    /**
     * 提交KYC认证申请
     * 利用数据表唯一索引 unique(['user_id', 'kyc_level'])
     */
    public function submit(array $data): ExKyc
    {
        $kyc = ExKyc::query()->firstOrCreate(['user_id' => $data['user_id']]);

        // 检查状态
        if (!$kyc->wasRecentlyCreated && $kyc->kyc_level == 1 && $kyc->status === self::STATUS_PENDING) {
            throw new BusinessException(message: '您已有审核中的申请');
        }
        if ($kyc->status == self::STATUS_APPROVED && $kyc->kyc_level == 2) {
            throw new BusinessException(message: '您已通过该等级认证');
        }
        $kyc->fill(array_merge($data, ['status' => self::STATUS_PENDING]));
        // 检查证件号码是否被他人使用
        $idNumberHash = hash('sha256', $data['id_number']);
        if (ExKyc::query()
            ->where('id_number_hash', $idNumberHash)
            ->where('user_id', '!=', $data['user_id'])
            ->where('status', self::STATUS_APPROVED)
            ->exists()) {
            throw new BusinessException(message: '该证件号码已被使用');
        }
        $data['id_number_hash'] = $idNumberHash;
        if ($kyc->kyc_level == 2) {
            // 设置定位时间
            if (isset($data['latitude'], $data['longitude']) && !isset($data['location_time'])) {
                $data['location_time'] = date('Y-m-d H:i:s');
            }
            $data['status'] = 0;
            $kyc->fill($data);
        }

        $kyc->save();
        return $kyc;
    }

    /**
     * 获取用户KYC记录
     */
    public function getUserKyc(int $userId): ?ExKyc
    {
        return ExKyc::query()
            ->where('user_id', $userId)
            ->orderByDesc('kyc_level')
            ->first();
    }
}

