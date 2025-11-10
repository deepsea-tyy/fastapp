<?php
/**
 * FastApp.
 * 11/8/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Common\Event;

class WsCloseEvent
{
    public function __construct(public int|string $userId)
    {
    }
}