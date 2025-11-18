<?php

declare(strict_types=1);

namespace Plugin\Ds\Kefu\Event;

use Plugin\Ds\Kefu\WebSocket\KefuMessageEndFormat;

final  class MessageEndEvent
{
    public function __construct(
        public KefuMessageEndFormat $message
    ) {}
}
