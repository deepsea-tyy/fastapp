<?php

declare(strict_types=1);

namespace Plugin\Ds\SysKefu\Event;

use Plugin\Ds\SysKefu\WebSocket\KefuMessageEndFormat;

final  class MessageEndEvent
{
    public function __construct(
        public KefuMessageEndFormat $message
    ) {}
}
