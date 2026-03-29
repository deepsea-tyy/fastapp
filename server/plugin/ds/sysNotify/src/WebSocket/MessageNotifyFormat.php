<?php

declare(strict_types=1);

namespace Plugin\Ds\SysNotify\WebSocket;

use App\Websocket\WsMessageAbstract;

/**
 * 消息通知 WebSocket 推送格式
 */
class MessageNotifyFormat extends WsMessageAbstract
{
    /**
     * 填充消息数据
     */
    public function fill(array $message): void
    {
        $this->data = array_merge([
            'type' => 'push_message',
            'action' => 'message_notify',
            'timestamp' => time(),
        ], $message);
    }

    /**
     * 获取推送目标用户ID列表
     * user_id = 0 表示全局推送
     */
    public function getToUids(): array
    {
        $userId = $this->data['user_id'] ?? null;

        // user_id = 0 表示全局推送，返回空数组，由 Listener 处理
        if ($userId === 0) {
            return [];
        }

        return $userId ? [$userId] : [];
    }

    /**
     * 是否为全局推送
     */
    public function isGlobalPush(): bool
    {
        return isset($this->data['user_id']) && $this->data['user_id'] === 0;
    }
}
