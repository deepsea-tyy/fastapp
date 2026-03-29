<?php

declare(strict_types=1);

namespace Plugin\Ds\SysKefu\Event;

use Plugin\Ds\SysKefu\WebSocket\KefuVisitorMessageSendFormat;

final class VisitorMessageSendEvent
{
    public function __construct(
        public KefuVisitorMessageSendFormat $message
    ) {}
}

