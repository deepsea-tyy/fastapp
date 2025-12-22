<?php
/**
 * WebSocket连接管理后台控制器
 */

namespace App\Http\Admin\Controller\Websocket;

use App\Common\Result;
use App\Common\Tools;
use App\Http\Admin\Controller\AbstractController;
use App\Websocket\Event\WsPushEvent;
use App\Websocket\WsConnectionManager;
use App\Websocket\WsController;
use App\Websocket\WsRoomManager;
use Hyperf\HttpServer\Annotation\Controller;
use Hyperf\HttpServer\Annotation\GetMapping;
use Hyperf\HttpServer\Annotation\PostMapping;
use Hyperf\HttpServer\Contract\RequestInterface;
use Swoole\WebSocket\Server;

#[Controller]
class ConnectionController extends AbstractController
{
    /**
     * 获取所有在线连接列表
     */
    #[GetMapping(path: '/admin/websocket/connection/list')]
    public function list(RequestInterface $request): Result
    {
        $page = $this->getPage();
        $pageSize = $this->getPageSize();
        $keyword = $request->input('keyword', '');

        $connections = WsConnectionManager::getAllConnections();

        // 按连接时间倒序排序
        usort($connections, function ($a, $b) {
            return $b['connect_time'] - $a['connect_time'];
        });

        // 关键词搜索
        if (!empty($keyword)) {
            $connections = array_filter($connections, function ($conn) use ($keyword) {
                return str_contains((string)$conn['user_id'], $keyword)
                    || str_contains($conn['ip'] ?? '', $keyword)
                    || str_contains((string)$conn['fd'], $keyword);
            });
        }

        $total = count($connections);
        $connections = array_slice($connections, ($page - 1) * $pageSize, $pageSize);

        // 格式化数据
        foreach ($connections as &$conn) {
            $conn['connect_time_formatted'] = date('Y-m-d H:i:s', $conn['connect_time']);
            $conn['last_ping_time_formatted'] = isset($conn['last_ping_time'])
                ? date('Y-m-d H:i:s', $conn['last_ping_time'])
                : '-';
            $conn['online_duration'] = time() - $conn['connect_time'];
        }

        return $this->success([
            'list' => $connections,
            'total' => $total,
            'page' => $page,
            'page_size' => $pageSize,
        ]);
    }

    /**
     * 获取连接统计信息
     */
    #[GetMapping(path: '/admin/websocket/connection/stats')]
    public function stats(): Result
    {
        $stats = WsConnectionManager::getStats();
        return $this->success($stats);
    }

    /**
     * 获取用户的连接详情
     */
    #[GetMapping(path: '/admin/websocket/connection/user/{userId}')]
    public function userConnections(int $userId): Result
    {
        $connections = WsConnectionManager::getUserConnections($userId);

        foreach ($connections as &$conn) {
            $conn['connect_time_formatted'] = date('Y-m-d H:i:s', $conn['connect_time']);
        }

        return $this->success($connections);
    }

    /**
     * 强制断开指定连接
     */
    #[PostMapping(path: '/admin/websocket/connection/close')]
    public function closeConnection(RequestInterface $request): Result
    {
        $fd = (int)$request->input('fd');

        if (!WsConnectionManager::isConnectionExists($fd)) {
            return $this->error('连接不存在');
        }

        try {
            $server = $this->getServer();
            if ($server && $server->isEstablished($fd)) {
                $server->close($fd);
                return $this->success(null, '连接已断开');
            }
            return $this->error('无法断开连接');
        } catch (\Throwable $e) {
            return $this->error('断开连接失败：' . $e->getMessage());
        }
    }

    /**
     * 批量断开连接
     */
    #[PostMapping(path: '/admin/websocket/connection/batchClose')]
    public function batchCloseConnections(RequestInterface $request): Result
    {
        $fds = $request->input('fds', []);

        if (empty($fds) || !is_array($fds)) {
            return $this->error('参数错误');
        }

        $server = $this->getServer();
        if (!$server) {
            return $this->error('无法获取WebSocket服务');
        }

        $successCount = 0;
        $failCount = 0;

        foreach ($fds as $fd) {
            try {
                if ($server->isEstablished($fd)) {
                    $server->close($fd);
                    $successCount++;
                } else {
                    $failCount++;
                }
            } catch (\Throwable $e) {
                $failCount++;
            }
        }

        return $this->success([
            'success_count' => $successCount,
            'fail_count' => $failCount,
        ], "成功断开 {$successCount} 个连接，失败 {$failCount} 个");
    }

    /**
     * 向指定用户推送消息（测试）
     */
    #[PostMapping(path: '/admin/websocket/connection/push')]
    public function pushMessage(RequestInterface $request): Result
    {
        $userId = $request->input('user_id');
        $message = $request->input('message', '');
        $event = $request->input('event', 'admin_message');

        if (empty($userId)) {
            return $this->error('用户ID不能为空');
        }

        // 触发推送事件
        Tools::eventDispatcher(
            WsPushEvent::toUser((int)$userId, [
                'message' => $message,
                'from' => 'admin',
                'time' => time(),
            ], $event)
        );

        return $this->success(null, '消息已推送');
    }

    /**
     * 广播消息给所有在线用户
     */
    #[PostMapping(path: '/admin/websocket/connection/broadcast')]
    public function broadcast(RequestInterface $request): Result
    {
        $message = $request->input('message', '');
        $event = $request->input('event', 'admin_broadcast');

        if (empty($message)) {
            return $this->error('消息不能为空');
        }

        // 触发广播事件
        Tools::eventDispatcher(
            WsPushEvent::toAll([
                'message' => $message,
                'from' => 'admin',
                'time' => time(),
            ], $event)
        );

        return $this->success(null, '广播消息已发送');
    }

    /**
     * 获取所有房间列表
     */
    #[GetMapping(path: '/admin/websocket/room/list')]
    public function roomList(): Result
    {
        $rooms = WsRoomManager::getAllRooms();
        return $this->success($rooms);
    }

    /**
     * 获取房间详情
     */
    #[GetMapping(path: '/admin/websocket/room/{roomId}')]
    public function roomDetail(string $roomId): Result
    {
        $fds = WsRoomManager::getRoomFds($roomId);
        $userIds = WsRoomManager::getRoomUserIds($roomId);

        $connections = [];
        foreach ($fds as $fd) {
            $info = WsConnectionManager::getConnectionInfo($fd);
            if ($info) {
                $connections[] = $info;
            }
        }

        return $this->success([
            'room_id' => $roomId,
            'member_count' => count($fds),
            'user_ids' => $userIds,
            'connections' => $connections,
        ]);
    }

    /**
     * 向房间推送消息
     */
    #[PostMapping(path: '/admin/websocket/room/push')]
    public function pushToRoom(RequestInterface $request): Result
    {
        $roomId = $request->input('room_id', '');
        $message = $request->input('message', '');
        $event = $request->input('event', 'admin_room_message');

        if (empty($roomId)) {
            return $this->error('房间ID不能为空');
        }

        // 触发房间推送事件
        Tools::eventDispatcher(
            WsPushEvent::toRoom($roomId, [
                'message' => $message,
                'from' => 'admin',
                'time' => time(),
            ], $event)
        );

        return $this->success(null, '消息已推送到房间');
    }

    /**
     * 获取WebSocket Server实例
     */
    private function getServer(): ?Server
    {
        try {
            $container = \Hyperf\Context\ApplicationContext::getContainer();
            return $container->get(Server::class);
        } catch (\Throwable $e) {
            return null;
        }
    }
}
