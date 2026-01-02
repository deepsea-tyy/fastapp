<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Http\Admin\Service;

use App\Common\IService;
use Plugin\Ds\Ex\Repository\ExKycRepository as Repository;
use Plugin\Ds\Ex\Model\ExKyc;
use Plugin\Ds\Ex\Model\ExKycReviewLog;
use Plugin\Ds\Ex\Model\ExUserVip;
use Plugin\Ds\Ex\Model\ExVip;
use Hyperf\DbConnection\Db;

class ExKycService extends IService
{
    public function __construct(
        protected readonly Repository $repository
    )
    {
    }

    /**
     * 通过审核
     */
    public function approve(int $id, int $operatorId, string $ipAddress = null, string $userAgent = null): void
    {
        Db::transaction(function () use ($id, $operatorId, $ipAddress, $userAgent) {
            // 获取当前记录
            $kyc = ExKyc::findOrFail($id);
            $beforeStatus = $kyc->status;

            // 更新状态为已通过 (1)
            $kyc->status = 1;
            $kyc->save();

            // 记录操作日志
            ExKycReviewLog::create([
                'kyc_id' => $id,
                'user_id' => $kyc->user_id,
                'action' => 'APPROVE',
                'operator_id' => $operatorId,
                'operator_type' => 'ADMIN',
                'before_status' => $beforeStatus,
                'after_status' => 1,
                'remark' => null,
                'ip_address' => $ipAddress,
                'user_agent' => $userAgent,
            ]);

            // 初始化用户VIP信息（如果不存在）
            // 从 ExVip 配置表获取 level=0 的配置数据
            $vipConfig = ExVip::where('level', 0)->first();

            $userVipData = [
                'level' => 0, // vip0
                'holder_wallet_asset_usd' => '0.00',
                'platform_token_balance' => '0.00000000',
                'trading_volume_30d_usdt' => '0.00',
            ];

            // 如果存在配置，使用配置中的平台币币种代码
            if ($vipConfig) {
                $userVipData = array_merge($userVipData, $vipConfig->toArray());
            }

            $uv = ExUserVip::firstOrCreate(['user_id' => $kyc->user_id]);
            if ($uv->wasRecentlyCreated) {
                $uv->fill($userVipData)->save();
            }
        });
    }

    /**
     * 拒绝审核
     */
    public function reject(int $id, string $reason, int $operatorId, string $ipAddress = null, string $userAgent = null): void
    {
        Db::transaction(function () use ($id, $reason, $operatorId, $ipAddress, $userAgent) {
            // 获取当前记录
            $kyc = ExKyc::findOrFail($id);
            $beforeStatus = $kyc->status;

            // 更新状态为已拒绝 (2) 并保存拒绝原因
            $kyc->status = 2;
            $kyc->remark = $reason;
            $kyc->save();

            // 记录操作日志
            ExKycReviewLog::create([
                'kyc_id' => $id,
                'user_id' => $kyc->user_id,
                'action' => 'REJECT',
                'operator_id' => $operatorId,
                'operator_type' => 'ADMIN',
                'before_status' => $beforeStatus,
                'after_status' => 2,
                'remark' => $reason,
                'ip_address' => $ipAddress,
                'user_agent' => $userAgent,
            ]);
        });
    }
}
