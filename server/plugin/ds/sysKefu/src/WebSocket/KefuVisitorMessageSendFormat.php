<?php

declare(strict_types=1);

namespace Plugin\Ds\SysKefu\WebSocket;

/**
 * 游客消息推送格式
 */
class KefuVisitorMessageSendFormat extends KefuMessageFormat
{
    protected function getAction(): string
    {
        return 'kefu_visitor_message';
    }
}

