<?php

declare(strict_types=1);

namespace Plugin\Ds\SysKefu\WebSocket;

/**
 * 游客会话结束推送格式
 */
class KefuVisitorMessageEndFormat extends KefuMessageFormat
{
    protected function getAction(): string
    {
        return 'kefu_visitor_conversation_end';
    }
}

