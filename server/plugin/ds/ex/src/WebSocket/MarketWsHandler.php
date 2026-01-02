<?php
/**
 * FastApp - Market WebSocket Handler
 * 市场行情 WebSocket 消息处理器
 * 支持动态订阅策略：热门币种全量推送 + 可视区域按需订阅
 */

namespace Plugin\Ds\Ex\WebSocket;

use App\Common\Tools;
use App\Websocket\WsController;
use App\Websocket\WsMessageHandlerInterface;
use App\Websocket\WsResponse;
use App\Websocket\WsRoomManager;
use Hyperf\Logger\LoggerFactory;
use Psr\Log\LoggerInterface;

class MarketWsHandler implements WsMessageHandlerInterface
{
    /**
     * 获取该处理器支持的所有action映射（需要认证）
     *
     * @return array<string, string>
     */
    public function getActions(): array
    {
        return [
            'market.subscribe' => 'subscribe',                   // 订阅单个交易对
            'market.subscribe.batch' => 'subscribeBatch',        // 批量订阅交易对
            'market.unsubscribe' => 'unsubscribe',               // 取消订阅单个交易对
            'market.unsubscribe.batch' => 'unsubscribeBatch',    // 批量取消订阅
            'market.subscribe.hot' => 'subscribeHot',            // 订阅热门币种（前20）
            'market.unsubscribe.hot' => 'unsubscribeHot',        // 取消订阅热门币种
            'kline.subscribe' => 'subscribeKline',               // 订阅K线数据
            'kline.unsubscribe' => 'unsubscribeKline',           // 取消订阅K线数据
            'depth.subscribe' => 'subscribeDepth',                // 订阅深度数据
            'depth.unsubscribe' => 'unsubscribeDepth',           // 取消订阅深度数据
        ];
    }

    /**
     * 获取该处理器支持的访客模式action映射（无需认证）
     *
     * @return array<string, string>
     */
    public function getVisitorActions(): array
    {
        return [
            // visitor.bind_fd 在 WsController 中直接处理，无需在这里注册
            'visitor.market.subscribe.hot' => 'visitorSubscribeHot', // 访客订阅热门币种
            'visitor.kline.subscribe' => 'visitorSubscribeKline',     // 访客订阅K线数据
            'visitor.depth.subscribe' => 'visitorSubscribeDepth',     // 访客订阅深度数据
        ];
    }

    /**
     * 订阅单个交易对
     * 数据格式: {"symbol": "BTCUSDT"}
     */
    public function subscribe(array $data, int $userId): WsResponse
    {
        $symbol = $data['symbol'] ?? '';

        if (empty($symbol)) {
            return WsResponse::error('Symbol is required');
        }

        Tools::console([
            'action' => 'market.subscribe',
            'symbol' => $symbol,
            'userId' => $userId,
            'data' => $data,
        ]);

        // 获取用户的所有连接
        $fds = WsController::getUserFds($userId);
        if (empty($fds)) {
            Tools::console(['error' => 'No active connections found', 'userId' => $userId]);
            return WsResponse::error('No active connections found');
        }

        $roomId = "market:{$symbol}";
        foreach ($fds as $fd) {
            WsRoomManager::joinRoom($roomId, $fd, $userId);
        }

        Tools::console([
            'success' => 'Subscribed to market',
            'roomId' => $roomId,
            'fds' => $fds,
        ]);

        return WsResponse::success([
            'subscribed' => [$symbol],
        ], 'Subscribed successfully');
    }

    /**
     * 批量订阅交易对（用于可视区域动态订阅）
     * 数据格式: {"symbols": ["BTCUSDT", "ETHUSDT", "BNBUSDT"]}
     */
    public function subscribeBatch(array $data, int $userId): WsResponse
    {
        $symbols = $data['symbols'] ?? [];

        if (empty($symbols) || !is_array($symbols)) {
            return WsResponse::error('Symbols array is required');
        }

        // 限制单次订阅数量，防止滥用
        $maxSubscriptions = 20;
        if (count($symbols) > $maxSubscriptions) {
            return WsResponse::error("Cannot subscribe more than {$maxSubscriptions} symbols at once");
        }

        // 获取用户的所有连接
        $fds = WsController::getUserFds($userId);
        if (empty($fds)) {
            return WsResponse::error('No active connections found');
        }

        $subscribed = [];
        foreach ($symbols as $symbol) {
            if (empty($symbol)) {
                continue;
            }
            $roomId = "market:{$symbol}";
            foreach ($fds as $fd) {
                WsRoomManager::joinRoom($roomId, $fd, $userId);
            }
            $subscribed[] = $symbol;
        }

        return WsResponse::success([
            'subscribed' => $subscribed,
            'count' => count($subscribed),
        ], 'Batch subscribed successfully');
    }

    /**
     * 取消订阅单个交易对
     */
    public function unsubscribe(array $data, int $userId): WsResponse
    {
        $symbol = $data['symbol'] ?? '';

        if (empty($symbol)) {
            return WsResponse::error('Symbol is required');
        }

        // 获取用户的所有连接
        $fds = WsController::getUserFds($userId);
        if (empty($fds)) {
            return WsResponse::error('No active connections found');
        }

        $roomId = "market:{$symbol}";
        foreach ($fds as $fd) {
            WsRoomManager::leaveRoom($roomId, $fd, $userId);
        }

        return WsResponse::success([
            'unsubscribed' => [$symbol],
        ], 'Unsubscribed successfully');
    }

    /**
     * 批量取消订阅（用于滚动优化）
     */
    public function unsubscribeBatch(array $data, int $userId): WsResponse
    {
        $symbols = $data['symbols'] ?? [];

        if (empty($symbols) || !is_array($symbols)) {
            return WsResponse::error('Symbols array is required');
        }

        // 获取用户的所有连接
        $fds = WsController::getUserFds($userId);
        if (empty($fds)) {
            return WsResponse::error('No active connections found');
        }

        $unsubscribed = [];
        foreach ($symbols as $symbol) {
            if (empty($symbol)) {
                continue;
            }
            $roomId = "market:{$symbol}";
            foreach ($fds as $fd) {
                WsRoomManager::leaveRoom($roomId, $fd, $userId);
            }
            $unsubscribed[] = $symbol;
        }

        return WsResponse::success([
            'unsubscribed' => $unsubscribed,
            'count' => count($unsubscribed),
        ], 'Batch unsubscribed successfully');
    }

    /**
     * 订阅热门币种（前20个，全量推送，1秒/次）
     * 数据格式: {}
     *
     * 注意：游客模式下，连接建立时已自动订阅热门币种
     *      用户登录后，也会自动保持订阅
     *      该接口主要用于重新订阅或确认订阅状态
     */
    public function subscribeHot(array $data, int $userId): WsResponse
    {
        // 获取用户的所有连接
        $fds = WsController::getUserFds($userId);
        if (empty($fds)) {
            // 用户没有活动连接，或者是游客模式（连接时已自动订阅）
            return WsResponse::success([
                'room_id' => 'market:hot',
                'note' => 'Already subscribed in visitor mode',
            ], 'Subscribed to hot tickers successfully');
        }

        // 加入热门行情房间
        $roomId = "market:hot";
        foreach ($fds as $fd) {
            WsRoomManager::joinRoom($roomId, $fd, $userId);
        }

        return WsResponse::success([
            'room_id' => $roomId,
        ], 'Subscribed to hot tickers successfully');
    }

    /**
     * 取消订阅热门币种
     */
    public function unsubscribeHot(array $data, int $userId): WsResponse
    {
        // 获取用户的所有连接
        $fds = WsController::getUserFds($userId);
        if (empty($fds)) {
            return WsResponse::error('No active connections found');
        }

        $roomId = "market:hot";
        foreach ($fds as $fd) {
            WsRoomManager::leaveRoom($roomId, $fd, $userId);
        }

        return WsResponse::success([
            'room_id' => $roomId,
        ], 'Unsubscribed from hot tickers successfully');
    }

    /**
     * 访客模式：订阅热门币种（前20个，全量推送，1秒/次）
     * 数据格式: {}
     *
     * @param array $data
     * @param string $bindKey 访客的 bind_key
     * @return WsResponse
     */
    public function visitorSubscribeHot(array $data, string $bindKey): WsResponse
    {
        if (empty($bindKey)) {
            return WsResponse::error('Please bind connection first');
        }

        // 获取用户的所有连接（使用 bind_key 作为用户标识）
        $fds = WsController::getUserFds($bindKey);
        if (empty($fds)) {
            return WsResponse::error('No active connections found');
        }

        // 加入热门行情房间
        $roomId = "market:hot";
        foreach ($fds as $fd) {
            WsRoomManager::joinRoom($roomId, $fd, $bindKey);
        }

        return WsResponse::success([
            'room_id' => $roomId,
        ], 'Visitor subscribed to hot tickers successfully');
    }

    /**
     * 订阅K线数据
     * 数据格式: {"symbol": "BTC/USDT", "interval": "1m"}
     * 或: {"symbol": "BTCUSDT:1m"} (兼容格式)
     */
    public function subscribeKline(array $data, int $userId): WsResponse
    {
        // 支持两种格式：
        // 1. {"symbol": "BTC/USDT", "interval": "1m"}
        // 2. {"symbol": "BTCUSDT:1m"} (兼容格式)
        $symbol = $data['symbol'] ?? '';
        $interval = $data['interval'] ?? '';

        // 如果 symbol 包含冒号，说明是兼容格式
        if (str_contains($symbol, ':')) {
            [$symbol, $interval] = explode(':', $symbol, 2);
        }

        Tools::console([
            'action' => 'kline.subscribe',
            'symbol' => $symbol,
            'interval' => $interval,
            'userId' => $userId,
            'data' => $data,
        ]);

        if (empty($symbol) || empty($interval)) {
            return WsResponse::error('Symbol and interval are required');
        }

        // 将 symbol 转换为无斜杠格式（BTC/USDT -> BTCUSDT）
        $symbolNoSlash = str_replace('/', '', $symbol);

        // 获取用户的所有连接
        $fds = WsController::getUserFds($userId);
        if (empty($fds)) {
            Tools::console(['error' => 'No active connections found', 'userId' => $userId]);
            return WsResponse::error('No active connections found');
        }

        $roomId = "kline:{$symbolNoSlash}:{$interval}";
        foreach ($fds as $fd) {
            WsRoomManager::joinRoom($roomId, $fd, $userId);
        }

        Tools::console([
            'success' => 'Subscribed to kline',
            'roomId' => $roomId,
            'fds' => $fds,
        ]);

        return WsResponse::success([
            'room_id' => $roomId,
            'symbol' => $symbol,
            'interval' => $interval,
        ], 'Subscribed to kline successfully');
    }

    /**
     * 取消订阅K线数据
     * 数据格式: {"symbol": "BTC/USDT", "interval": "1m"}
     * 或: {"symbol": "BTCUSDT:1m"} (兼容格式)
     */
    public function unsubscribeKline(array $data, int $userId): WsResponse
    {
        $symbol = $data['symbol'] ?? '';
        $interval = $data['interval'] ?? '';

        // 如果 symbol 包含冒号，说明是兼容格式
        if (str_contains($symbol, ':')) {
            [$symbol, $interval] = explode(':', $symbol, 2);
        }

        if (empty($symbol) || empty($interval)) {
            return WsResponse::error('Symbol and interval are required');
        }

        // 将 symbol 转换为无斜杠格式（BTC/USDT -> BTCUSDT）
        $symbolNoSlash = str_replace('/', '', $symbol);

        // 获取用户的所有连接
        $fds = WsController::getUserFds($userId);
        if (empty($fds)) {
            return WsResponse::error('No active connections found');
        }

        $roomId = "kline:{$symbolNoSlash}:{$interval}";
        foreach ($fds as $fd) {
            WsRoomManager::leaveRoom($roomId, $fd, $userId);
        }

        return WsResponse::success([
            'room_id' => $roomId,
            'symbol' => $symbol,
            'interval' => $interval,
        ], 'Unsubscribed from kline successfully');
    }

    /**
     * 订阅深度数据
     * 数据格式: {"symbol": "BTC/USDT"}
     * 或: {"symbol": "BTCUSDT"} (兼容格式)
     */
    public function subscribeDepth(array $data, int $userId): WsResponse
    {
        $symbol = $data['symbol'] ?? '';

        Tools::console([
            'action' => 'depth.subscribe',
            'symbol' => $symbol,
            'userId' => $userId,
            'data' => $data,
        ]);

        if (empty($symbol)) {
            return WsResponse::error('Symbol is required');
        }

        // 将 symbol 转换为无斜杠格式（BTC/USDT -> BTCUSDT）
        $symbolNoSlash = str_replace('/', '', $symbol);

        // 获取用户的所有连接
        $fds = WsController::getUserFds($userId);
        if (empty($fds)) {
            Tools::console(['error' => 'No active connections found', 'userId' => $userId]);
            return WsResponse::error('No active connections found');
        }

        $roomId = "depth:{$symbolNoSlash}";
        foreach ($fds as $fd) {
            WsRoomManager::joinRoom($roomId, $fd, $userId);
        }

        Tools::console([
            'success' => 'Subscribed to depth',
            'roomId' => $roomId,
            'fds' => $fds,
        ]);

        return WsResponse::success([
            'room_id' => $roomId,
            'symbol' => $symbol,
        ], 'Subscribed to depth successfully');
    }

    /**
     * 取消订阅深度数据
     * 数据格式: {"symbol": "BTC/USDT"}
     * 或: {"symbol": "BTCUSDT"} (兼容格式)
     */
    public function unsubscribeDepth(array $data, int $userId): WsResponse
    {
        $symbol = $data['symbol'] ?? '';

        if (empty($symbol)) {
            return WsResponse::error('Symbol is required');
        }

        // 将 symbol 转换为无斜杠格式（BTC/USDT -> BTCUSDT）
        $symbolNoSlash = str_replace('/', '', $symbol);

        // 获取用户的所有连接
        $fds = WsController::getUserFds($userId);
        if (empty($fds)) {
            return WsResponse::error('No active connections found');
        }

        $roomId = "depth:{$symbolNoSlash}";
        foreach ($fds as $fd) {
            WsRoomManager::leaveRoom($roomId, $fd, $userId);
        }

        return WsResponse::success([
            'room_id' => $roomId,
            'symbol' => $symbol,
        ], 'Unsubscribed from depth successfully');
    }

    /**
     * 访客模式：订阅K线数据
     * 数据格式: {"symbol": "BTC/USDT", "interval": "1m"}
     *
     * @param array $data
     * @param string $bindKey 访客的 bind_key
     * @return WsResponse
     */
    public function visitorSubscribeKline(array $data, string $bindKey): WsResponse
    {
        if (empty($bindKey)) {
            return WsResponse::error('Please bind connection first');
        }

        $symbol = $data['symbol'] ?? '';
        $interval = $data['interval'] ?? '';

        // 如果 symbol 包含冒号，说明是兼容格式
        if (str_contains($symbol, ':')) {
            [$symbol, $interval] = explode(':', $symbol, 2);
        }

        Tools::console([
            'action' => 'visitor.kline.subscribe',
            'symbol' => $symbol,
            'interval' => $interval,
            'bindKey' => $bindKey,
            'data' => $data,
        ]);

        if (empty($symbol) || empty($interval)) {
            return WsResponse::error('Symbol and interval are required');
        }

        // 将 symbol 转换为无斜杠格式（BTC/USDT -> BTCUSDT）
        $symbolNoSlash = str_replace('/', '', $symbol);

        // 获取访客的所有连接
        $fds = WsController::getUserFds($bindKey);
        if (empty($fds)) {
            Tools::console(['error' => 'No active connections found', 'bindKey' => $bindKey]);
            return WsResponse::error('No active connections found');
        }

        $roomId = "kline:{$symbolNoSlash}:{$interval}";
        foreach ($fds as $fd) {
            WsRoomManager::joinRoom($roomId, $fd, $bindKey);
        }

        Tools::console([
            'success' => 'Visitor subscribed to kline',
            'roomId' => $roomId,
            'fds' => $fds,
        ]);

        return WsResponse::success([
            'room_id' => $roomId,
            'symbol' => $symbol,
            'interval' => $interval,
        ], 'Visitor subscribed to kline successfully');
    }

    /**
     * 访客模式：订阅深度数据
     * 数据格式: {"symbol": "BTC/USDT"}
     * 或: {"symbol": "BTCUSDT"} (兼容格式)
     *
     * @param array $data
     * @param string $bindKey 访客的 bind_key
     * @return WsResponse
     */
    public function visitorSubscribeDepth(array $data, string $bindKey): WsResponse
    {
        if (empty($bindKey)) {
            return WsResponse::error('Please bind connection first');
        }

        $symbol = $data['symbol'] ?? '';

        Tools::console([
            'action' => 'visitor.depth.subscribe',
            'symbol' => $symbol,
            'bindKey' => $bindKey,
            'data' => $data,
        ]);

        if (empty($symbol)) {
            return WsResponse::error('Symbol is required');
        }

        // 将 symbol 转换为无斜杠格式（BTC/USDT -> BTCUSDT）
        $symbolNoSlash = str_replace('/', '', $symbol);

        // 获取访客的所有连接
        $fds = WsController::getUserFds($bindKey);
        if (empty($fds)) {
            Tools::console(['error' => 'No active connections found', 'bindKey' => $bindKey]);
            return WsResponse::error('No active connections found');
        }

        $roomId = "depth:{$symbolNoSlash}";
        foreach ($fds as $fd) {
            WsRoomManager::joinRoom($roomId, $fd, $bindKey);
        }

        Tools::console([
            'success' => 'Visitor subscribed to depth',
            'roomId' => $roomId,
            'fds' => $fds,
        ]);

        return WsResponse::success([
            'room_id' => $roomId,
            'symbol' => $symbol,
        ], 'Visitor subscribed to depth successfully');
    }
}
