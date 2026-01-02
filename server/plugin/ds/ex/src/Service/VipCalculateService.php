<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Service;

use Carbon\Carbon;
use Hyperf\DbConnection\Db;
use Plugin\Ds\Ex\Model\ExUserVip;
use Plugin\Ds\Ex\Model\ExUserVipLog;
use Plugin\Ds\Ex\Model\ExVip;

/**
 * VIP等级计算服务
 */
class VipCalculateService
{
    /**
     * 计算并更新用户VIP等级
     *
     * @param int $userId 用户ID
     * @param float $walletAssetUsd 钱包资产（USD）
     * @param float $platformTokenBalance 平台币余额
     * @param float|null $tradingVolume30dUsdt 30天交易量（USDT），如果为null则不更新
     * @param string|null $operatorIp 操作IP
     * @return ExUserVip
     */
    public function calculateAndUpdateVipLevel(
        int $userId,
        float $walletAssetUsd,
        float $platformTokenBalance,
        ?float $tradingVolume30dUsdt = null,
        ?string $operatorIp = null
    ): ExUserVip {
        return Db::transaction(function () use ($userId, $walletAssetUsd, $platformTokenBalance, $tradingVolume30dUsdt, $operatorIp) {
            // 获取或创建用户VIP信息
            $userVip = ExUserVip::query()->where('user_id', $userId)->first();
            if (!$userVip) {
                $userVip = new ExUserVip();
                $userVip->user_id = $userId;
                $userVip->level = 0;
                $userVip->holder_level = 0;
                $userVip->trading_level = 0;
                $userVip->primary_type = ExUserVipLog::TRIGGER_TYPE_HOLDER;
            }

            $oldLevel = $userVip->level;

            // 计算持有者计划等级
            $holderLevel = $this->calculateHolderLevel($walletAssetUsd, $platformTokenBalance);
            $userVip->holder_level = $holderLevel;

            // 如果提供了交易量，更新交易型VIP等级缓存
            if ($tradingVolume30dUsdt !== null) {
                $tradingLevel = $this->calculateTradingLevel($tradingVolume30dUsdt);
                $userVip->trading_level = $tradingLevel;
                $userVip->trading_volume_30d_usdt = $tradingVolume30dUsdt;
                $userVip->trading_volume_cached_at = Carbon::now();
            }

            // 取两者最高等级
            $newLevel = max($userVip->holder_level, $userVip->trading_level);

            // 检查是否需要降级（考虑保护期）
            if ($newLevel < $oldLevel) {
                if ($userVip->isInProtectionPeriod()) {
                    // 在保护期内，不降级
                    $newLevel = $oldLevel;
                } else {
                    // 降级
                    $userVip->level = $newLevel;
                    $userVip->primary_type = $userVip->holder_level >= $userVip->trading_level
                        ? ExUserVipLog::TRIGGER_TYPE_HOLDER
                        : ExUserVipLog::TRIGGER_TYPE_TRADING;
                }
            } elseif ($newLevel > $oldLevel) {
                // 升级
                $userVip->level = $newLevel;
                $userVip->primary_type = $userVip->holder_level >= $userVip->trading_level
                    ? ExUserVipLog::TRIGGER_TYPE_HOLDER
                    : ExUserVipLog::TRIGGER_TYPE_TRADING;

                // 设置降级保护期
                $vipConfig = ExVip::query()->where('level', $newLevel)->first();
                if ($vipConfig && $vipConfig->protection_days > 0) {
                    $userVip->protection_until = Carbon::now()->addDays($vipConfig->protection_days);
                }
            }

            $userVip->last_calculated_at = Carbon::now();
            $userVip->save();

            // 如果等级发生变化，记录日志
            if ($newLevel != $oldLevel) {
                $this->logVipChange(
                    $userId,
                    $oldLevel,
                    $newLevel,
                    $userVip->primary_type,
                    [
                        'wallet_asset_usd' => $walletAssetUsd,
                        'platform_token_balance' => $platformTokenBalance,
                        'trading_volume_30d_usdt' => $tradingVolume30dUsdt,
                        'holder_level' => $holderLevel,
                        'trading_level' => $userVip->trading_level,
                    ],
                    $operatorIp
                );
            }

            return $userVip;
        });
    }

    /**
     * 计算持有者计划VIP等级
     */
    private function calculateHolderLevel(float $walletAssetUsd, float $platformTokenBalance): int
    {
        $vipLevel = ExVip::query()
            ->where('status', 1)
            ->where(function ($query) use ($walletAssetUsd, $platformTokenBalance) {
                $query->where('holder_wallet_asset_usd', '<=', $walletAssetUsd)
                    ->orWhere('holder_platform_token', '<=', $platformTokenBalance);
            })
            ->orderByDesc('level')
            ->first();

        return $vipLevel ? $vipLevel->level : 0;
    }

    /**
     * 计算交易型VIP等级
     */
    private function calculateTradingLevel(float $tradingVolume30dUsdt): int
    {
        $vipLevel = ExVip::query()
            ->where('status', 1)
            ->where('trading_volume_usdt', '<=', $tradingVolume30dUsdt)
            ->orderByDesc('level')
            ->first();

        return $vipLevel ? $vipLevel->level : 0;
    }

    /**
     * 手动调整用户VIP等级
     *
     * @param int $userId 用户ID
     * @param int $targetLevel 目标等级
     * @param int $operatorId 操作人ID
     * @param string|null $remark 备注
     * @param string|null $operatorIp 操作IP
     * @param Carbon|null $expiredAt VIP到期时间，NULL表示永久
     * @return ExUserVip
     */
    public function manualAdjustVipLevel(
        int $userId,
        int $targetLevel,
        int $operatorId,
        ?string $remark = null,
        ?string $operatorIp = null,
        ?Carbon $expiredAt = null
    ): ExUserVip {
        return Db::transaction(function () use ($userId, $targetLevel, $operatorId, $remark, $operatorIp, $expiredAt) {
            // 获取或创建用户VIP信息
            $userVip = ExUserVip::query()->where('user_id', $userId)->first();
            if (!$userVip) {
                $userVip = new ExUserVip();
                $userVip->user_id = $userId;
                $userVip->level = 0;
                $userVip->holder_level = 0;
                $userVip->trading_level = 0;
            }

            $oldLevel = $userVip->level;
            $userVip->level = $targetLevel;
            $userVip->primary_type = ExUserVipLog::TRIGGER_TYPE_MANUAL;
            $userVip->expired_at = $expiredAt;

            // 手动调整时，设置降级保护期
            $vipConfig = ExVip::query()->where('level', $targetLevel)->first();
            if ($vipConfig && $vipConfig->protection_days > 0) {
                $userVip->protection_until = Carbon::now()->addDays($vipConfig->protection_days);
            }

            $userVip->last_calculated_at = Carbon::now();
            $userVip->save();

            // 记录日志
            $this->logVipChange(
                $userId,
                $oldLevel,
                $targetLevel,
                ExUserVipLog::TRIGGER_TYPE_MANUAL,
                [
                    'operator_id' => $operatorId,
                    'expired_at' => $expiredAt?->toDateTimeString(),
                ],
                $operatorIp,
                $operatorId,
                ExUserVipLog::OPERATOR_TYPE_ADMIN,
                $remark
            );

            return $userVip;
        });
    }

    /**
     * 记录VIP变更日志
     */
    private function logVipChange(
        int $userId,
        int $fromLevel,
        int $toLevel,
        int $triggerType,
        array $upgradeData = [],
        ?string $ip = null,
        ?int $operatorId = null,
        ?string $operatorType = null,
        ?string $remark = null
    ): void {
        $log = new ExUserVipLog();
        $log->user_id = $userId;
        $log->from_level = $fromLevel;
        $log->to_level = $toLevel;
        $log->trigger_type = $triggerType;

        // 判断操作类型
        if ($toLevel > $fromLevel) {
            $log->action_type = ExUserVipLog::ACTION_UPGRADE;
        } elseif ($toLevel < $fromLevel) {
            $log->action_type = ExUserVipLog::ACTION_DOWNGRADE;
            // 根据触发类型设置降级原因
            if ($triggerType == ExUserVipLog::TRIGGER_TYPE_HOLDER) {
                $log->downgrade_reason = ExUserVipLog::DOWNGRADE_REASON_ASSET_DECREASED;
            } elseif ($triggerType == ExUserVipLog::TRIGGER_TYPE_TRADING) {
                $log->downgrade_reason = ExUserVipLog::DOWNGRADE_REASON_VOLUME_INSUFFICIENT;
            }
        } else {
            $log->action_type = ExUserVipLog::ACTION_MANUAL_ADJUST;
        }

        $log->upgrade_data = $upgradeData;
        $log->operator_id = $operatorId;
        $log->operator_type = $operatorType ?? ExUserVipLog::OPERATOR_TYPE_SYSTEM;
        $log->ip = $ip;
        $log->remark = $remark;
        $log->save();
    }

    /**
     * 检查并处理VIP到期
     */
    public function checkAndHandleExpiredVip(int $userId): ?ExUserVip
    {
        $userVip = ExUserVip::query()->where('user_id', $userId)->first();
        if (!$userVip || !$userVip->isExpired()) {
            return $userVip;
        }

        return Db::transaction(function () use ($userVip) {
            $oldLevel = $userVip->level;

            // VIP过期，降为普通用户（VIP0）
            $userVip->level = 0;
            $userVip->holder_level = 0;
            $userVip->trading_level = 0;
            $userVip->protection_until = null;
            $userVip->last_calculated_at = Carbon::now();
            $userVip->save();

            // 记录日志
            $this->logVipChange(
                $userVip->user_id,
                $oldLevel,
                0,
                ExUserVipLog::TRIGGER_TYPE_MANUAL,
                ['reason' => 'VIP expired'],
                null,
                null,
                ExUserVipLog::OPERATOR_TYPE_SYSTEM,
                'VIP到期自动降级'
            );

            // 设置降级原因为到期
            ExUserVipLog::query()
                ->where('user_id', $userVip->user_id)
                ->orderByDesc('id')
                ->limit(1)
                ->update(['downgrade_reason' => ExUserVipLog::DOWNGRADE_REASON_EXPIRED]);

            return $userVip;
        });
    }
}
