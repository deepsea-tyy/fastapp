<?php
/**
 * WebSocket 后台管理控制器
 * 提供 WebSocket 连接的管理接口
 */

declare(strict_types=1);

namespace Plugin\Ds\Ex\Http\Admin\Controller;

use App\Common\AbstractController;
use App\Common\Middleware\AccessTokenMiddleware;
use App\Common\Result;
use App\Http\Admin\Middleware\PermissionMiddleware;
use App\Http\Admin\Permission;
use App\Websocket\WsConnectionManager;
use Hyperf\HttpServer\Annotation\Controller;
use Hyperf\HttpServer\Annotation\DeleteMapping;
use Hyperf\HttpServer\Annotation\GetMapping;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\HttpServer\Annotation\PostMapping;
use Hyperf\WebSocketServer\Sender;

#[Controller]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
class WebsocketController extends AbstractController
{
    public function __construct(
        private readonly Sender $sender
    )
    {
    }

    /**
     * 获取所有连接信息（分页）
     */
    #[GetMapping(path: '/admin/ds/ex/websocket/connections')]
    #[Permission(code: 'ds:ex:websocket:list')]
    public function getAllConnections(): Result
    {
        $request = $this->getRequest();
        $userId = $request->input('user_id');
        $page = max(1, (int)$request->input('page', 1));
        $pageSize = max(1, min(100, (int)$request->input('page_size', 20)));

        $result = WsConnectionManager::getConnectionsList($userId, $page, $pageSize);

        return $this->success($result);
    }

    /**
     * 获取连接统计信息
     */
    #[GetMapping(path: '/admin/ds/ex/websocket/stats')]
    #[Permission(code: 'ds:ex:websocket:list')]
    public function getStats(): Result
    {
        $stats = WsConnectionManager::getStats();

        return $this->success($stats);
    }

    /**
     * 获取指定连接的详细信息
     */
    #[GetMapping(path: '/admin/ds/ex/websocket/connection/{fd}')]
    #[Permission(code: 'ds:ex:websocket:info')]
    public function getConnectionInfo(int $fd): Result
    {
        $info = WsConnectionManager::getConnectionInfo($fd);

        if (!$info) {
            return $this->error('连接不存在');
        }

        return $this->success($info);
    }

    /**
     * 关闭指定连接
     */
    #[DeleteMapping(path: '/admin/ds/ex/websocket/connection/{fd}')]
    #[Permission(code: 'ds:ex:websocket:close')]
    public function closeConnection(int $fd): Result
    {
        try {
            $server = $this->getWebSocketServer();

            if (!$server) {
                return $this->error('WebSocket 服务未启动');
            }

            // 检查连接是否存在
            if (!$server->exists($fd)) {
                // 清理 Redis 中的连接信息
                WsConnectionManager::removeConnection($fd);
                return $this->error('连接已不存在');
            }

            // 发送关闭通知
            $this->sender->push($fd, json_encode([
                'type' => 'system',
                'message' => '连接已被管理员关闭',
            ], JSON_UNESCAPED_UNICODE));

            // 关闭连接
            $server->close($fd);

            return $this->success(null, '连接已关闭');
        } catch (\Throwable $e) {
            return $this->error('关闭连接失败：' . $e->getMessage());
        }
    }

    /**
     * 批量关闭连接
     */
    #[PostMapping(path: '/admin/ds/ex/websocket/connections/close')]
    #[Permission(code: 'ds:ex:websocket:close')]
    public function closeConnections(): Result
    {
        $fds = $this->getRequest()->input('fds', []);

        if (empty($fds) || !is_array($fds)) {
            return $this->error('参数错误');
        }

        $server = $this->getWebSocketServer();

        if (!$server) {
            return $this->error('WebSocket 服务未启动');
        }

        $successCount = 0;
        $failCount = 0;

        foreach ($fds as $fd) {
            try {
                if ($server->exists((int)$fd)) {
                    // 发送关闭通知
                    $this->sender->push((int)$fd, json_encode([
                        'type' => 'system',
                        'message' => '连接已被管理员关闭',
                    ], JSON_UNESCAPED_UNICODE));

                    // 关闭连接
                    $server->close((int)$fd);
                    $successCount++;
                }
            } catch (\Throwable) {
                $failCount++;
            }
        }

        return $this->success([
            'success_count' => $successCount,
            'fail_count' => $failCount,
        ], "成功关闭 {$successCount} 个连接");
    }

    /**
     * 向指定连接发送消息
     */
    #[PostMapping(path: '/admin/ds/ex/websocket/connection/{fd}/message')]
    #[Permission(code: 'ds:ex:websocket:send')]
    public function sendMessage(int $fd): Result
    {
        $message = $this->getRequest()->input('message');

        if (empty($message)) {
            return $this->error('消息内容不能为空');
        }

        $server = $this->getWebSocketServer();

        if (!$server) {
            return $this->error('WebSocket 服务未启动');
        }

        if (!$server->exists($fd)) {
            return $this->error('连接不存在');
        }

        try {
            // 构造消息
            $data = [
                'type' => 'admin_message',
                'message' => $message,
                'time' => time(),
            ];

            // 发送消息
            $this->sender->push($fd, json_encode($data, JSON_UNESCAPED_UNICODE));

            return $this->success(null, '消息已发送');
        } catch (\Throwable $e) {
            return $this->error('发送消息失败：' . $e->getMessage());
        }
    }

    /**
     * 批量获取用户在线状态
     */
    #[PostMapping(path: '/admin/ds/ex/websocket/users/online-status')]
    #[Permission(code: 'ds:ex:websocket:list')]
    public function getBatchUserOnlineStatus(): Result
    {
        $userIds = $this->getRequest()->input('user_ids', []);

        if (empty($userIds) || !is_array($userIds)) {
            return $this->error('参数错误');
        }

        $status = WsConnectionManager::getBatchUserOnlineStatus($userIds);

        return $this->success($status);
    }

    /**
     * 修复连接统计
     */
    #[PostMapping(path: '/admin/ds/ex/websocket/fix-stats')]
    #[Permission(code: 'ds:ex:websocket:list')]
    public function fixStats(): Result
    {
        $result = WsConnectionManager::fixConnectionStats();

        return $this->success($result, '统计修复完成');
    }

    /**
     * 获取 WebSocket Server 实例
     */
    private function getWebSocketServer(): ?\Swoole\WebSocket\Server
    {
        try {
            $container = \Hyperf\Context\ApplicationContext::getContainer();
            $serverFactory = $container->get(\Hyperf\Server\ServerFactory::class);
            $serverConfig = $container->get(\Hyperf\Contract\ConfigInterface::class)->get('server.servers');

            // 查找 WebSocket server 配置
            foreach ($serverConfig as $server) {
                if (($server['type'] ?? '') === \Hyperf\Server\Server::SERVER_WEBSOCKET) {
                    return $serverFactory->getServer()->getServer();
                }
            }

            return null;
        } catch (\Throwable $e) {
            return null;
        }
    }
}
