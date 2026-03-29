<?php

declare(strict_types=1);

namespace Plugin\Ds\SysKefu\WebSocket;

/**
 * 用户消息推送格式
 */
class KefuMessageSendFormat extends KefuMessageFormat
{
    protected function getAction(): string
    {
        return 'kefu_message';
    }
}
