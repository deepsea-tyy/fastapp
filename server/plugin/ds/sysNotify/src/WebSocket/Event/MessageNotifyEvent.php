<?php

declare(strict_types=1);

namespace Plugin\Ds\SysNotify\WebSocket\Event;

use Plugin\Ds\SysNotify\WebSocket\MessageNotifyFormat;

/**
 * 消息通知推送事件
 */
final class MessageNotifyEvent
{
    public function __construct(
        public MessageNotifyFormat $message
    ) {}
}
