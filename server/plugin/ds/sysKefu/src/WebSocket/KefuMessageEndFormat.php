<?php

declare(strict_types=1);

namespace Plugin\Ds\SysKefu\WebSocket;

/**
 * 用户会话结束推送格式
 */
class KefuMessageEndFormat extends KefuMessageFormat
{
    protected function getAction(): string
    {
        return 'kefu_message_end';
    }
}
