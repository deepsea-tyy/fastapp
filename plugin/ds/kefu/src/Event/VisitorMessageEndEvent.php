<?php

declare(strict_types=1);

namespace Plugin\Ds\Kefu\Event;

use Plugin\Ds\Kefu\WebSocket\KefuVisitorMessageEndFormat;

final class VisitorMessageEndEvent
{
    public function __construct(
        public KefuVisitorMessageEndFormat $message
    ) {}
}

