<?php

declare(strict_types=1);

namespace Plugin\Ds\SysKefu\Event;

use Plugin\Ds\SysKefu\WebSocket\KefuVisitorMessageEndFormat;

final class VisitorMessageEndEvent
{
    public function __construct(
        public KefuVisitorMessageEndFormat $message
    ) {}
}

