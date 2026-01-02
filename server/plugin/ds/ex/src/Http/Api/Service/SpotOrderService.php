<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Http\Api\Service;

use App\Exception\BusinessException;
use Hyperf\DbConnection\Db;
use Plugin\Ds\Ex\Model\MarketPair;
use Plugin\Ds\Ex\Model\SpotOrder;
use Plugin\Ds\Ex\Model\SpotTradeLimit;

class SpotOrderService
{
    /**
     * 下单
     *
     * @param int $userId 用户ID
     * @param array $params 订单参数
     * @return SpotOrder
     * @throws BusinessException
     */
    public function placeOrder(int $userId, array $params): SpotOrder
    {
        // 验证必填参数
        $symbol = $params['symbol'] ?? '';
        $side = strtoupper($params['side'] ?? '');
        $type = strtoupper($params['type'] ?? '');
        $quantity = $params['quantity'] ?? 0;
        $price = $params['price'] ?? null;
        $amount = $params['amount'] ?? null;
        $clientOrderId = $params['client_order_id'] ?? null;

        if (empty($symbol)) {
            throw new BusinessException('交易对符号不能为空');
        }

        if (!in_array($side, [SpotOrder::SIDE_BUY, SpotOrder::SIDE_SELL])) {
            throw new BusinessException('订单方向无效');
        }

        if (!in_array($type, [SpotOrder::TYPE_LIMIT, SpotOrder::TYPE_MARKET])) {
            throw new BusinessException('订单类型无效');
        }

        // 获取交易对信息
        $pair = MarketPair::query()
            ->where('symbol', $symbol)
            ->where('market_type', 'spot')
            ->where('status', 1)
            ->first();

        if (!$pair) {
            throw new BusinessException('交易对不存在或已禁用');
        }

        // 检查用户交易限制
        $this->checkTradingLimit($userId, $symbol, $side, $quantity, $price, $amount);

        // 验证订单参数
        if ($type === SpotOrder::TYPE_LIMIT) {
            if ($price === null || $price <= 0) {
                throw new BusinessException('限价单必须指定价格');
            }
            if ($quantity <= 0) {
                throw new BusinessException('订单数量必须大于0');
            }
        } else {
            // 市价单
            if ($side === SpotOrder::SIDE_BUY) {
                if ($amount === null || $amount <= 0) {
                    throw new BusinessException('市价买入必须指定金额');
                }
            } else {
                if ($quantity <= 0) {
                    throw new BusinessException('订单数量必须大于0');
                }
            }
        }

        // 检查最小交易限制
        if ($type === SpotOrder::TYPE_LIMIT) {
            $notional = $quantity * $price;
            if ($notional < $pair->min_amount) {
                throw new BusinessException("交易金额不能小于最小交易金额 {$pair->min_amount}");
            }
            if ($quantity < $pair->min_quantity) {
                throw new BusinessException("交易数量不能小于最小交易数量 {$pair->min_quantity}");
            }
        }

        // 生成订单ID
        $orderId = $this->generateOrderId();

        // 创建订单
        $order = new SpotOrder();
        $order->order_id = $orderId;
        $order->user_id = $userId;
        $order->symbol = $pair->id;
        $order->client_order_id = $clientOrderId;
        $order->side = $side;
        $order->type = $type;
        $order->time_in_force = SpotOrder::TIME_IN_FORCE_GTC;
        $order->price = $price ?? 0;
        $order->quantity = $quantity;
        $order->quote_quantity = $amount ?? ($quantity * ($price ?? 0));
        $order->executed_quantity = 0;
        $order->executed_quote_quantity = 0;
        $order->avg_price = 0;
        $order->commission = 0;
        $order->status = SpotOrder::STATUS_NEW;
        $order->is_working = 0;

        // TODO: 这里应该实现实际的订单处理逻辑
        // 1. 冻结余额
        // 2. 加入订单簿
        // 3. 撮合交易
        // 目前先简单保存订单

        $order->save();

        return $order;
    }

    /**
     * 获取订单列表
     *
     * @param int $userId 用户ID
     * @param array $params 查询参数
     * @return array
     */
    public function getOrderList(int $userId, array $params): array
    {
        $query = SpotOrder::query()
            ->where('user_id', $userId)
            ->with('marketPair');

        // 交易对筛选
        if (!empty($params['symbol'])) {
            $pair = MarketPair::query()
                ->where('symbol', $params['symbol'])
                ->where('market_type', 'spot')
                ->first();
            if ($pair) {
                $query->where('symbol', $pair->id);
            }
        }

        // 状态筛选
        if (!empty($params['status'])) {
            $status = $this->mapStatusToDb($params['status']);
            $query->where('status', $status);
        }

        // 方向筛选
        if (!empty($params['side'])) {
            $query->where('side', strtoupper($params['side']));
        }

        // 时间范围筛选
        if (!empty($params['start_time'])) {
            $query->where('created_at', '>=', date('Y-m-d H:i:s', $params['start_time']));
        }
        if (!empty($params['end_time'])) {
            $query->where('created_at', '<=', date('Y-m-d H:i:s', $params['end_time']));
        }

        // 分页
        $page = (int)($params['page'] ?? 1);
        $limit = (int)($params['limit'] ?? 50);
        $limit = min($limit, 500); // 最大500条

        $total = $query->count();

        $orders = $query
            ->orderByDesc('created_at')
            ->offset(($page - 1) * $limit)
            ->limit($limit)
            ->get()
            ->map(function (SpotOrder $order) {
                $pair = $order->marketPair;
                return [
                    'id' => $order->order_id,
                    'symbol' => $pair ? $pair->symbol : '',
                    'type' => strtolower($order->type),
                    'side' => strtolower($order->side),
                    'status' => $this->mapStatus($order->status),
                    'price' => $order->price > 0 ? (float)$order->price : null,
                    'quantity' => (float)$order->quantity,
                    'filledQuantity' => (float)$order->executed_quantity,
                    'filledAmount' => (float)$order->executed_quote_quantity,
                    'avgPrice' => $order->avg_price > 0 ? (float)$order->avg_price : null,
                    'createdAt' => $order->created_at->getTimestamp() * 1000,
                    'updatedAt' => $order->updated_at->getTimestamp() * 1000,
                ];
            })
            ->toArray();

        return [
            'items' => $orders,
            'total' => $total,
            'page' => $page,
            'limit' => $limit,
        ];
    }

    /**
     * 取消订单
     *
     * @param int $userId 用户ID
     * @param string $orderId 订单ID
     * @return bool
     * @throws BusinessException
     */
    public function cancelOrder(int $userId, string $orderId): bool
    {
        $order = SpotOrder::query()
            ->where('order_id', $orderId)
            ->where('user_id', $userId)
            ->first();

        if (!$order) {
            throw new BusinessException('订单不存在');
        }

        // 检查订单状态
        if (!in_array($order->status, [SpotOrder::STATUS_NEW, SpotOrder::STATUS_PARTIALLY_FILLED])) {
            throw new BusinessException('订单状态不允许取消');
        }

        // TODO: 这里应该实现实际的取消逻辑
        // 1. 从订单簿移除
        // 2. 解冻余额
        // 3. 更新订单状态

        $order->status = SpotOrder::STATUS_CANCELED;
        $order->is_working = 0;
        $order->save();

        return true;
    }

    /**
     * 检查交易限制
     *
     * @param int $userId 用户ID
     * @param string $symbol 交易对符号
     * @param string $side 方向
     * @param float $quantity 数量
     * @param float|null $price 价格
     * @param float|null $amount 金额
     * @throws BusinessException
     */
    private function checkTradingLimit(int $userId, string $symbol, string $side, float $quantity, ?float $price, ?float $amount): void
    {
        // 检查特定交易对限制
        $pairLimit = SpotTradeLimit::query()
            ->where('user_id', $userId)
            ->where('symbol', $symbol)
            ->first();

        // 检查全局限制
        $globalLimit = SpotTradeLimit::query()
            ->where('user_id', $userId)
            ->whereNull('symbol')
            ->first();

        // 使用特定交易对限制，如果没有则使用全局限制
        $limit = $pairLimit ?? $globalLimit;

        if ($limit && $limit->is_trading_enabled == 0) {
            throw new BusinessException('您的账户已被限制交易');
        }

        if ($limit) {
            // 检查单笔最大数量
            if ($limit->max_order_quantity && $quantity > $limit->max_order_quantity) {
                throw new BusinessException("单笔最大数量不能超过 {$limit->max_order_quantity}");
            }

            // 检查单笔最大金额
            $notional = $amount ?? ($quantity * ($price ?? 0));
            if ($limit->max_order_notional && $notional > $limit->max_order_notional) {
                throw new BusinessException("单笔最大金额不能超过 {$limit->max_order_notional}");
            }

            // TODO: 检查每日限额（需要查询当日已交易量）
        }
    }

    /**
     * 生成订单ID
     *
     * @return string
     */
    private function generateOrderId(): string
    {
        // 生成格式：时间戳(毫秒) + 随机数
        $timestamp = (int)(microtime(true) * 1000);
        $random = mt_rand(1000, 9999);
        return (string)($timestamp . $random);
    }

    /**
     * 映射订单状态到前端格式
     *
     * @param string $status 数据库状态
     * @return string 前端状态
     */
    private function mapStatus(string $status): string
    {
        $map = [
            SpotOrder::STATUS_NEW => 'pending',
            SpotOrder::STATUS_PARTIALLY_FILLED => 'partiallyFilled',
            SpotOrder::STATUS_FILLED => 'filled',
            SpotOrder::STATUS_CANCELED => 'cancelled',
            SpotOrder::STATUS_REJECTED => 'rejected',
            SpotOrder::STATUS_EXPIRED => 'expired',
        ];

        return $map[$status] ?? 'pending';
    }

    /**
     * 映射前端状态到数据库格式
     *
     * @param string $status 前端状态
     * @return string 数据库状态
     */
    private function mapStatusToDb(string $status): string
    {
        $map = [
            'pending' => SpotOrder::STATUS_NEW,
            'partiallyFilled' => SpotOrder::STATUS_PARTIALLY_FILLED,
            'filled' => SpotOrder::STATUS_FILLED,
            'cancelled' => SpotOrder::STATUS_CANCELED,
            'rejected' => SpotOrder::STATUS_REJECTED,
            'expired' => SpotOrder::STATUS_EXPIRED,
        ];

        return $map[$status] ?? SpotOrder::STATUS_NEW;
    }
}

