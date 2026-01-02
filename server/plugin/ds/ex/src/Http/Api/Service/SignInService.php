<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Http\Api\Service;

use Carbon\Carbon;
use Plugin\Ds\Ex\Model\ExSignInLog;
use Plugin\Ds\Ex\Model\ExRewardLog;

class SignInService
{
    /**
     * 每日签到
     */
    public function signIn(int $uid): array
    {
        $today = Carbon::today()->toDateString();

        $exists = ExSignInLog::query()
            ->where('uid', $uid)
            ->where('sign_date', $today)
            ->exists();

        if ($exists) {
            return ['success' => false, 'message' => '今日已签到'];
        }

        $yesterday = Carbon::yesterday()->toDateString();
        $yesterdayLog = ExSignInLog::query()
            ->where('uid', $uid)
            ->where('sign_date', $yesterday)
            ->first();

        $totalDays = ExSignInLog::query()
            ->where('uid', $uid)
            ->count();

        $continuousDays = $yesterdayLog ? $yesterdayLog->continuous_days + 1 : 1;

        $reward = $this->calculateReward($continuousDays);

        $log = ExSignInLog::query()->create([
            'uid' => $uid,
            'sign_date' => $today,
            'continuous_days' => $continuousDays,
            'total_days' => $totalDays + 1,
            'reward_type' => $reward['type'],
            'reward_amount' => $reward['amount'],
            'reward_symbol' => $reward['symbol'],
        ]);

        if ($reward['amount'] > 0) {
            ExRewardLog::query()->create([
                'uid' => $uid,
                'source_type' => 5,
                'source_id' => $log->id,
                'reward_type' => $reward['type'],
                'reward_name' => '签到奖励',
                'reward_amount' => $reward['amount'],
                'symbol' => $reward['symbol'],
                'status' => 0,
            ]);
        }

        return [
            'success' => true,
            'data' => [
                'continuous_days' => $continuousDays,
                'total_days' => $totalDays + 1,
                'reward' => $reward,
            ],
        ];
    }

    /**
     * 计算签到奖励
     */
    protected function calculateReward(int $continuousDays): array
    {
        $baseReward = 10;

        if ($continuousDays >= 30) {
            $amount = 500;
        } elseif ($continuousDays >= 15) {
            $amount = 150;
        } elseif ($continuousDays >= 7) {
            $amount = 50;
        } else {
            $amount = $baseReward;
        }

        return [
            'type' => 2,
            'amount' => $amount,
            'symbol' => 'POINTS',
        ];
    }

    /**
     * 获取签到历史
     */
    public function getSignInHistory(int $uid, ?string $month = null): array
    {
        if (!$month) {
            $month = Carbon::now()->format('Y-m');
        }

        $startDate = Carbon::parse($month)->startOfMonth();
        $endDate = Carbon::parse($month)->endOfMonth();

        $logs = ExSignInLog::query()
            ->where('uid', $uid)
            ->whereBetween('sign_date', [$startDate, $endDate])
            ->orderBy('sign_date')
            ->get();

        $latestLog = ExSignInLog::query()
            ->where('uid', $uid)
            ->orderByDesc('sign_date')
            ->first();

        return [
            'continuous_days' => $latestLog ? $latestLog->continuous_days : 0,
            'total_days' => $latestLog ? $latestLog->total_days : 0,
            'sign_dates' => $logs->pluck('sign_date')->toArray(),
            'rewards' => $logs->map(function ($log) {
                return [
                    'date' => $log->sign_date,
                    'reward_type' => $log->reward_type,
                    'reward_amount' => $log->reward_amount,
                    'reward_symbol' => $log->reward_symbol,
                ];
            })->toArray(),
        ];
    }

    /**
     * 检查今日是否已签到
     */
    public function hasSignedInToday(int $uid): bool
    {
        $today = Carbon::today()->toDateString();

        return ExSignInLog::query()
            ->where('uid', $uid)
            ->where('sign_date', $today)
            ->exists();
    }
}
