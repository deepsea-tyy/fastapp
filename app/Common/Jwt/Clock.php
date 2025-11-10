<?php
/**
 * FastApp.
 * 10/19/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Common\Jwt;


use Carbon\Carbon;
use Psr\Clock\ClockInterface;

class Clock implements ClockInterface
{
    public function now(): \DateTimeImmutable
    {
        return Carbon::now()->toDateTimeImmutable();
    }
}