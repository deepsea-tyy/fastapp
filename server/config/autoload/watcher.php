<?php

declare(strict_types=1);

use Hyperf\Watcher\Driver\ScanFileDriver;

return [
    'enable' => env('APP_DEBUG', false),
    'driver' => ScanFileDriver::class,
    'bin' => 'php',
    'watch' => [
        'dir' => ['app', 'config'],
        'file' => ['.env'],
        'scan_interval' => 2000,
    ],
];
