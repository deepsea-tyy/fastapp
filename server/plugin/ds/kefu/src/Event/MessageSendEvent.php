<?php

declare(strict_types=1);

namespace Plugin\Ds\Kefu\Event;

use Plugin\Ds\Kefu\WebSocket\KefuMessageSendFormat;

final  class MessageSendEvent
{
    public function __construct(
        public KefuMessageSendFormat $message
    ) {}
}
