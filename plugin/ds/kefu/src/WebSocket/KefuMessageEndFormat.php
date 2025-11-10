<?php

declare(strict_types=1);

namespace Plugin\Ds\Kefu\WebSocket;

use App\Websocket\WsMessageAbstract;

/**
 * 客服会话结束WebSocket格式
 */
class KefuMessageEndFormat extends WsMessageAbstract
{
    /**
     * 填充消息数据
     */
    public function fill(array $message): void
    {
        $this->data = array_merge([
            'type' => 'push_message',
            'action' => 'kefu_message_end',
            'timestamp' => time(),
        ], $message);
    }
}
