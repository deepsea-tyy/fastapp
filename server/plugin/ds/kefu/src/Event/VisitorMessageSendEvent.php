<?php

declare(strict_types=1);

namespace Plugin\Ds\Kefu\Event;

use Plugin\Ds\Kefu\WebSocket\KefuVisitorMessageSendFormat;

final class VisitorMessageSendEvent
{
    public function __construct(
        public KefuVisitorMessageSendFormat $message
    ) {}
}

