<?php

declare(strict_types=1);

namespace Plugin\Ds\SysKefu\Event;

use Plugin\Ds\SysKefu\WebSocket\KefuMessageSendFormat;

final  class MessageSendEvent
{
    public function __construct(
        public KefuMessageSendFormat $message
    ) {}
}
