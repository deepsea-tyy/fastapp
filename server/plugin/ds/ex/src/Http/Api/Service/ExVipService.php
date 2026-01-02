<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Http\Api\Service;

use App\Common\Tools;
use Plugin\Ds\Ex\Model\ExUserVip;
use Plugin\Ds\Ex\Model\ExUserVipLog;
use Plugin\Ds\Ex\Model\ExVip;
use Plugin\Ds\Ex\Repository\ExVipRepository as Repository;

class ExVipService
{
    public function __construct(
        protected readonly Repository $repository
    )
    {
    }

    /**
     * 获取VIP等级列表（仅显示启用的）
     */
    public function getVipLevels(string $lang = ''): array
    {
        return ExVip::query()
            ->where('status', 1)
            ->orderBy('level')
            ->get()->map(function (ExVip $item) use ($lang) {
                $item->name = Tools::formatLang($item->name, $lang);
                $item->description = Tools::formatLang($item->description, $lang);
                return $item;
            })
            ->toArray();
    }

    /**
     * 获取用户VIP信息
     */
    public function getUserVip(int $userId): ?ExUserVip
    {
        $item = ExUserVip::query()
            ->where('user_id', $userId)
            ->first();
        if ($item) {
            $item->name = Tools::formatLang($item->name, $userId);
            $item->description = Tools::formatLang($item->description, $userId);
        }
        return $item;
    }

    /**
     * 获取用户VIP详细信息（包含VIP等级配置信息）
     */
    public function getUserVipDetail(int $userId): ?array
    {
        $userVip = $this->getUserVip($userId);

        // 如果用户没有VIP信息，返回VIP0（普通用户）的配置
        if (!$userVip) {
            $vip0 = ExVip::query()->where('level', 0)->first();
            if ($vip0) {
                $vip0->name = Tools::formatLang($vip0->name);
                $vip0->description = Tools::formatLang($vip0->description);
                return $vip0->toArray();
            }
            return null;
        }

        // 获取对应VIP等级的配置
        $vipConfig = ExVip::query()
            ->where('level', $userVip->level)
            ->first();

        if (!$vipConfig) {
            return null;
        }

        // 合并用户VIP信息和VIP配置
        $data = array_merge($vipConfig->toArray(), $userVip->toArray());

        // 添加额外的状态信息
        $data['is_in_protection_period'] = $userVip->isInProtectionPeriod();
        $data['is_expired'] = $userVip->isExpired();
        $data['is_permanent'] = $userVip->isPermanent();

        return $data;
    }

    /**
     * 获取用户VIP升级记录
     */
    public function getUserVipLogs(int $userId, int $page = 1, int $pageSize = 20): array
    {
        $query = ExUserVipLog::query()
            ->where('user_id', $userId)
            ->orderByDesc('created_at');

        $total = $query->count();
        $list = $query
            ->offset(($page - 1) * $pageSize)
            ->limit($pageSize)
            ->get()
            ->toArray();

        return [
            'list' => $list,
            'total' => $total,
            'page' => $page,
            'page_size' => $pageSize,
        ];
    }

    /**
     * 根据资产获取可达到的最高VIP等级（持有者计划）
     *
     * @param float $walletAssetUsd 钱包资产（USD）
     * @param float $platformTokenBalance 平台币余额
     * @return ExVip|null
     */
    public function getMaxVipLevelByAsset(float $walletAssetUsd, float $platformTokenBalance): ?ExVip
    {
        return ExVip::query()
            ->where('status', 1)
            ->where(function ($query) use ($walletAssetUsd, $platformTokenBalance) {
                $query->where('holder_wallet_asset_usd', '<=', $walletAssetUsd)
                    ->orWhere('holder_platform_token', '<=', $platformTokenBalance);
            })
            ->orderByDesc('level')
            ->first();
    }

    /**
     * 根据交易量获取可达到的最高VIP等级（交易型VIP）
     *
     * @param float $tradingVolume30dUsdt 30天交易量（USDT）
     * @return ExVip|null
     */
    public function getMaxVipLevelByTradingVolume(float $tradingVolume30dUsdt): ?ExVip
    {
        return ExVip::query()
            ->where('status', 1)
            ->where('trading_volume_usdt', '<=', $tradingVolume30dUsdt)
            ->orderByDesc('level')
            ->first();
    }

    /**
     * 获取指定等级的VIP配置
     */
    public function getVipConfigByLevel(int $level): ?ExVip
    {
        return ExVip::query()
            ->where('level', $level)
            ->where('status', 1)
            ->first();
    }

    /**
     * 获取所有VIP等级配置（包括禁用的）
     */
    public function getAllVipLevels(): array
    {
        return ExVip::query()
            ->orderBy('level')
            ->get()
            ->toArray();
    }

    /**
     * 判断用户是否需要降级（检查保护期）
     */
    public function shouldDowngrade(ExUserVip $userVip, int $targetLevel): bool
    {
        // 如果目标等级高于或等于当前等级，不需要降级
        if ($targetLevel >= $userVip->level) {
            return false;
        }

        // 如果在降级保护期内，不降级
        if ($userVip->isInProtectionPeriod()) {
            return false;
        }

        return true;
    }
}
