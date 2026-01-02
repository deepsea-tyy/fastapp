<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Http\Api\Service;

use Hyperf\DbConnection\Db;
use Plugin\Ds\Ex\Model\ExWalletBalance;
use Plugin\Ds\Ex\Model\ExWalletBalanceLog;
use Plugin\Ds\Ex\Model\ExWalletTransfer;
use Plugin\Ds\Ex\Model\ExWalletAddress;
use Plugin\Ds\Ex\Model\ExWalletWithdrawal;

class ExWalletService
{
    /**
     * 查询指定钱包类型的余额
     */
    public function getBalance(int $userId, string $walletType = ''): array
    {
        $map['user_id'] = $userId;
        $map['status'] = 1;
        $query = ExWalletBalance::query()->select(['wallet_type', 'symbol', 'available', 'frozen', 'total']);
        if ($walletType) {
            $map['wallet_type'] = $walletType;
        }
        return $query->where($map)->get()->mapToGroups(function ($item) {
            return [$item->wallet_type => [
                'symbol' => $item->symbol,
                'available' => $item->available,
                'frozen' => $item->frozen,
                'total' => $item->total,
            ]];
        })->toArray();
    }

    /**
     * 账户划转
     */
    public function transfer(int $userId, string $fromWalletType, string $toWalletType, string $symbol, string|int $amount): array
    {

        // 验证划转规则
        if ($fromWalletType === $toWalletType) {
            throw new \RuntimeException('源账户和目标账户不能相同');
        }

        try {
            Db::beginTransaction();

            // 1. 扣减源账户可用余额
            $fromBalance = ExWalletBalance::query()
                ->where('user_id', $userId)
                ->where('wallet_type', $fromWalletType)
                ->where('symbol', $symbol)
                ->lockForUpdate()
                ->first();

            if (!$fromBalance) {
                throw new \RuntimeException('源账户余额不足');
            }

            if (bccomp($fromBalance->available, $amount, 18) < 0) {
                throw new \RuntimeException('可用余额不足');
            }

            $oldVersion = $fromBalance->version;
            $affected = ExWalletBalance::query()
                ->where('id', $fromBalance->id)
                ->where('version', $oldVersion)
                ->update([
                    'available' => Db::raw("available - {$amount}"),
                    'version' => Db::raw('version + 1'),
                ]);

            if ($affected === 0) {
                throw new \RuntimeException('余额更新失败，请重试');
            }

            // 2. 增加目标账户可用余额
            $toBalance = ExWalletBalance::query()
                ->where('user_id', $userId)
                ->where('wallet_type', $toWalletType)
                ->where('symbol', $symbol)
                ->lockForUpdate()
                ->first();

            if ($toBalance) {
                ExWalletBalance::query()
                    ->where('id', $toBalance->id)
                    ->update([
                        'available' => Db::raw("available + {$amount}"),
                        'version' => Db::raw('version + 1'),
                    ]);
            } else {
                ExWalletBalance::query()->create([
                    'user_id' => $userId,
                    'wallet_type' => $toWalletType,
                    'symbol' => $symbol,
                    'available' => $amount,
                    'frozen' => 0,
                    'status' => 1,
                    'version' => 1,
                ]);
            }

            // 刷新获取最新数据
            $fromBalance->refresh();
            $toBalance = ExWalletBalance::query()
                ->where('user_id', $userId)
                ->where('wallet_type', $toWalletType)
                ->where('symbol', $symbol)
                ->first();

            // 3. 记录源账户流水
            ExWalletBalanceLog::query()->create([
                'user_id' => $userId,
                'wallet_type' => $fromWalletType,
                'symbol' => $symbol,
                'change_type' => 'OUT',
                'amount' => '-' . $amount,
                'available_before' => bcadd($fromBalance->available, $amount, 18),
                'available_after' => $fromBalance->available,
                'frozen_before' => $fromBalance->frozen,
                'frozen_after' => $fromBalance->frozen,
                'ref_type' => 'TRANSFER',
                'remark' => "划转至{$toWalletType}账户",
            ]);

            // 4. 记录目标账户流水
            ExWalletBalanceLog::query()->create([
                'user_id' => $userId,
                'wallet_type' => $toWalletType,
                'symbol' => $symbol,
                'change_type' => 'IN',
                'amount' => $amount,
                'available_before' => bcsub($toBalance->available, $amount, 18),
                'available_after' => $toBalance->available,
                'frozen_before' => $toBalance->frozen,
                'frozen_after' => $toBalance->frozen,
                'ref_type' => 'TRANSFER',
                'remark' => "从{$fromWalletType}账户划入",
            ]);

            // 5. 记录划转记录
            $transfer = ExWalletTransfer::query()->create([
                'user_id' => $userId,
                'from_wallet_type' => $fromWalletType,
                'to_wallet_type' => $toWalletType,
                'symbol' => $symbol,
                'amount' => $amount,
                'status' => 1, // 成功
            ]);

            Db::commit();

            return [
                'transferId' => (string)$transfer->id,
                'status' => 'SUCCESS',
            ];
        } catch (\Exception $e) {
            Db::rollBack();
            throw $e;
        }
    }

    /**
     * 查询资金流水
     */
    public function getBalanceLog(int $userId, array $params): array
    {
        $query = ExWalletBalanceLog::query()
            ->where('user_id', $userId);

        if (!empty($params['symbol'])) {
            $query->where('symbol', $params['symbol']);
        }

        if (!empty($params['wallet_type'])) {
            $query->where('wallet_type', $params['wallet_type']);
        }

        if (!empty($params['change_type'])) {
            $query->where('change_type', $params['change_type']);
        }

        if (!empty($params['startTime'])) {
            $query->where('created_at', '>=', $params['startTime']);
        }

        if (!empty($params['endTime'])) {
            $query->where('created_at', '<=', $params['endTime']);
        }

        $query->orderByDesc('created_at');

        $page = (int)($params['page'] ?? 1);
        $limit = (int)($params['limit'] ?? 50);

        $total = $query->count();
        $list = $query
            ->offset(($page - 1) * $limit)
            ->limit($limit)
            ->get()
            ->map(function ($item) {
                return [
                    'id' => (string)$item->id,
                    'symbol' => $item->symbol,
                    'walletType' => $item->wallet_type,
                    'changeType' => $item->change_type,
                    'refType' => $item->ref_type,
                    'amount' => $item->amount,
                    'availableBefore' => $item->available_before,
                    'availableAfter' => $item->available_after,
                    'frozenBefore' => $item->frozen_before,
                    'frozenAfter' => $item->frozen_after,
                    'remark' => $item->remark,
                    'createdAt' => $item->created_at->format('Y-m-d H:i:s'),
                ];
            })
            ->toArray();

        return [
            'list' => $list,
            'total' => $total,
        ];
    }

    /**
     * 获取充值地址
     */
    public function getDepositAddress(int $userId, string $symbol, string $network): array
    {
        $address = ExWalletAddress::query()
            ->where('user_id', $userId)
            ->where('symbol', $symbol)
            ->where('network', $network)
            ->where('address_type', 1) // 充值地址
            ->where('status', 1)
            ->first();

        if (!$address) {
            // TODO: 这里应该生成新的充值地址
            // 实际项目中需要调用区块链服务生成地址
            throw new \RuntimeException('充值地址不存在，请联系客服');
        }

        return [
            'symbol' => $address->symbol,
            'network' => $address->network,
            'address' => $address->address,
            'tag' => $address->tag,
            'minDeposit' => '10.00000000', // TODO: 从配置中获取最小充值金额
        ];
    }

    /**
     * 申请提现
     */
    public function withdraw(int $userId, array $data): array
    {
        $symbol = $data['symbol'];
        $network = $data['network'];
        $address = $data['address'];
        $tag = $data['tag'] ?? null;
        $amount = $data['amount'];

        // TODO: 验证提现地址格式
        // TODO: 检查白名单
        // TODO: 验证提现限额
        // TODO: 计算手续费（这里暂时固定为1）
        $fee = '1.00000000';
        $actualAmount = bcsub($amount, $fee, 18);
        $totalAmount = $amount; // 总扣除金额 = 提现金额（已包含手续费）

        try {
            Db::beginTransaction();

            // 1. 冻结资金账户余额
            $balance = ExWalletBalance::query()
                ->where('user_id', $userId)
                ->where('wallet_type', 'FUNDING')
                ->where('symbol', $symbol)
                ->lockForUpdate()
                ->first();

            if (!$balance) {
                throw new \RuntimeException('余额不足');
            }

            if (bccomp($balance->available, $totalAmount, 18) < 0) {
                throw new \RuntimeException('可用余额不足');
            }

            $oldVersion = $balance->version;
            $affected = ExWalletBalance::query()
                ->where('id', $balance->id)
                ->where('version', $oldVersion)
                ->update([
                    'available' => Db::raw("available - {$totalAmount}"),
                    'frozen' => Db::raw("frozen + {$totalAmount}"),
                    'version' => Db::raw('version + 1'),
                ]);

            if ($affected === 0) {
                throw new \RuntimeException('余额更新失败，请重试');
            }

            // 刷新获取最新数据
            $balance->refresh();

            // 2. 记录流水
            ExWalletBalanceLog::query()->create([
                'user_id' => $userId,
                'wallet_type' => 'FUNDING',
                'symbol' => $symbol,
                'change_type' => 'ORDER_FREEZE',
                'amount' => '-' . $totalAmount,
                'available_before' => bcadd($balance->available, $totalAmount, 18),
                'available_after' => $balance->available,
                'frozen_before' => bcsub($balance->frozen, $totalAmount, 18),
                'frozen_after' => $balance->frozen,
                'ref_type' => 'WITHDRAW',
                'remark' => '提现冻结',
            ]);

            // 3. 创建提现记录
            $withdrawal = ExWalletWithdrawal::query()->create([
                'user_id' => $userId,
                'symbol' => $symbol,
                'network' => $network,
                'to_address' => $address,
                'tag' => $tag,
                'amount' => $amount,
                'fee' => $fee,
                'actual_amount' => $actualAmount,
                'status' => 1, // 待审核
                'audit_status' => 1, // 待审核
            ]);

            Db::commit();

            return [
                'withdrawalId' => (string)$withdrawal->id,
                'symbol' => $symbol,
                'amount' => $amount,
                'fee' => $fee,
                'actualAmount' => $actualAmount,
                'status' => 'PENDING_AUDIT',
            ];
        } catch (\Exception $e) {
            Db::rollBack();
            throw $e;
        }
    }

    /**
     * 转账给用户
     * @param int $userId 发送者用户ID
     * @param int $recipientType 收款方式：0=邮箱，1=手机号，2=用户ID
     * @param string $recipient 收款人
     * @param string $symbol 币种
     * @param string|int $amount 金额
     * @param string $remark 备注
     */
    public function transferToUser(int $userId, int $recipientType, string $recipient, string $symbol, string|int $amount, string $remark = ''): array
    {
        // 1. 根据收款方式查找收款用户
        $recipientUser = match ($recipientType) {
            0 => \App\Model\User::query()->where('email', $recipient)->first(),
            1 => \App\Model\User::query()->where('mobile', $recipient)->first(),
            2 => \App\Model\User::query()->where('id', $recipient)->first(),
            default => throw new \RuntimeException('无效的收款方式'),
        };

        if (!$recipientUser) {
            throw new \RuntimeException('收款用户不存在');
        }

        if ($recipientUser->id === $userId) {
            throw new \RuntimeException('不能转账给自己');
        }

        try {
            Db::beginTransaction();

            // 2. 扣减发送者资金账户可用余额
            $fromBalance = ExWalletBalance::query()
                ->where('user_id', $userId)
                ->where('wallet_type', 'FUNDING')
                ->where('symbol', $symbol)
                ->lockForUpdate()
                ->first();

            if (!$fromBalance) {
                throw new \RuntimeException('余额不足');
            }

            if (bccomp($fromBalance->available, $amount, 18) < 0) {
                throw new \RuntimeException('可用余额不足');
            }

            $oldVersion = $fromBalance->version;
            $affected = ExWalletBalance::query()
                ->where('id', $fromBalance->id)
                ->where('version', $oldVersion)
                ->update([
                    'available' => Db::raw("available - {$amount}"),
                    'version' => Db::raw('version + 1'),
                ]);

            if ($affected === 0) {
                throw new \RuntimeException('余额更新失败，请重试');
            }

            // 3. 增加收款者资金账户可用余额
            $toBalance = ExWalletBalance::query()
                ->where('user_id', $recipientUser->id)
                ->where('wallet_type', 'FUNDING')
                ->where('symbol', $symbol)
                ->lockForUpdate()
                ->first();

            if ($toBalance) {
                ExWalletBalance::query()
                    ->where('id', $toBalance->id)
                    ->update([
                        'available' => Db::raw("available + {$amount}"),
                        'version' => Db::raw('version + 1'),
                    ]);
            } else {
                ExWalletBalance::query()->create([
                    'user_id' => $recipientUser->id,
                    'wallet_type' => 'FUNDING',
                    'symbol' => $symbol,
                    'available' => $amount,
                    'frozen' => 0,
                    'status' => 1,
                    'version' => 1,
                ]);
            }

            // 刷新获取最新数据
            $fromBalance->refresh();
            $toBalance = ExWalletBalance::query()
                ->where('user_id', $recipientUser->id)
                ->where('wallet_type', 'FUNDING')
                ->where('symbol', $symbol)
                ->first();

            // 4. 记录发送者流水
            ExWalletBalanceLog::query()->create([
                'user_id' => $userId,
                'wallet_type' => 'FUNDING',
                'symbol' => $symbol,
                'change_type' => 'OUT',
                'amount' => '-' . $amount,
                'available_before' => bcadd($fromBalance->available, $amount, 18),
                'available_after' => $fromBalance->available,
                'frozen_before' => $fromBalance->frozen,
                'frozen_after' => $fromBalance->frozen,
                'ref_type' => 'USER_TRANSFER',
                'remark' => $remark ?: "转账给用户 {$recipientUser->id}",
            ]);

            // 5. 记录收款者流水
            ExWalletBalanceLog::query()->create([
                'user_id' => $recipientUser->id,
                'wallet_type' => 'FUNDING',
                'symbol' => $symbol,
                'change_type' => 'IN',
                'amount' => $amount,
                'available_before' => bcsub($toBalance->available, $amount, 18),
                'available_after' => $toBalance->available,
                'frozen_before' => $toBalance->frozen,
                'frozen_after' => $toBalance->frozen,
                'ref_type' => 'USER_TRANSFER',
                'remark' => $remark ?: "收到用户 {$userId} 转账",
            ]);

            Db::commit();

            return [
                'status' => 'SUCCESS',
                'recipientUserId' => (string)$recipientUser->id,
                'amount' => $amount,
                'symbol' => $symbol,
            ];
        } catch (\Exception $e) {
            Db::rollBack();
            throw $e;
        }
    }
}
