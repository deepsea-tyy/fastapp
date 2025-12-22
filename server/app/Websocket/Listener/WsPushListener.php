<?php
/**
 * WebSocket推送监听器
 * 监听WsPushEvent，执行实际的消息推送
 */

namespace App\Websocket\Listener;

use App\Common\Tools;
use App\Websocket\Event\WsPushEvent;
use App\Websocket\WsConnectionManager;
use App\Websocket\WsController;
use App\Websocket\WsResponse;
use App\Websocket\WsRoomManager;
use Hyperf\Event\Annotation\Listener;
use Hyperf\Event\Contract\ListenerInterface;
use Hyperf\WebSocketServer\Sender;
use Swoole\Coroutine;

#[Listener]
class WsPushListener implements ListenerInterface
{
    public function __construct(
        protected Sender $sender
    ) {
    }

    public function listen(): array
    {
        return [
            WsPushEvent::class,
        ];
    }

    public function process(object $event): void
    {
        if (!$event instanceof WsPushEvent) {
            return;
        }

        // 在协程中异步执行推送
        Coroutine::create(function () use ($event) {
            try {
                $this->handlePush($event);
            } catch (\Throwable $e) {
                Tools::logAsync(
                    "WebSocket push error: " . $e->getMessage(),
                    'error',
                    'error',
                    'websocket'
                );
            }
        });
    }

    private function handlePush(WsPushEvent $event): void
    {
        $fds = $this->resolveFds($event);

        if (empty($fds)) {
            return;
        }

        // 构建响应
        $response = $this->buildResponse($event);
        $message = $response->toJson();

        // 批量推送
        foreach ($fds as $fd) {
            try {
                $this->sender->push($fd, $message, WEBSOCKET_OPCODE_TEXT);
            } catch (\Throwable $e) {
                // 只记录推送失败的错误
                Tools::logAsync(
                    "Failed to push message to fd {$fd}: " . $e->getMessage(),
                    'warning',
                    'warning',
                    'websocket'
                );
            }
        }

        // 移除频繁的推送日志，减少日志噪音
    }

    /**
     * 解析目标fd列表
     */
    private function resolveFds(WsPushEvent $event): array
    {
        $fds = [];

        switch ($event->targetType) {
            case WsPushEvent::TARGET_USER:
                $fds = WsController::getUserFds($event->target);
                break;

            case WsPushEvent::TARGET_USERS:
                foreach ($event->target as $userId) {
                    $userFds = WsController::getUserFds($userId);
                    $fds = array_merge($fds, $userFds);
                }
                break;

            case WsPushEvent::TARGET_ALL:
                $connections = WsConnectionManager::getAllConnections();
                $fds = array_column($connections, 'fd');
                break;

            case WsPushEvent::TARGET_FD:
                $fds = [$event->target];
                break;

            case WsPushEvent::TARGET_FDS:
                $fds = $event->target;
                break;

            case WsPushEvent::TARGET_ROOM:
                $fds = WsRoomManager::getRoomFds($event->target);
                break;
        }

        // 排除指定的用户和fd
        $fds = $this->applyExclusions($fds, $event->excludeUserIds, $event->excludeFds);

        return array_unique($fds);
    }

    /**
     * 应用排除规则
     */
    private function applyExclusions(array $fds, array $excludeUserIds, array $excludeFds): array
    {
        if (empty($excludeUserIds) && empty($excludeFds)) {
            return $fds;
        }

        // 排除指定的fd
        if (!empty($excludeFds)) {
            $fds = array_diff($fds, $excludeFds);
        }

        // 排除指定用户的fd
        if (!empty($excludeUserIds)) {
            $excludeUserFds = [];
            foreach ($excludeUserIds as $userId) {
                $userFds = WsController::getUserFds($userId);
                $excludeUserFds = array_merge($excludeUserFds, $userFds);
            }
            $fds = array_diff($fds, $excludeUserFds);
        }

        return array_values($fds);
    }

    /**
     * 构建响应消息
     */
    private function buildResponse(WsPushEvent $event): WsResponse
    {
        $data = $event->data;

        // 如果指定了事件名，添加到data中
        if ($event->event !== null) {
            $data = array_merge(['event' => $event->event], $data);
        }

        return WsResponse::success($data, 'push');
    }
}
