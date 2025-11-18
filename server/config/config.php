<?php

declare(strict_types=1);

use Hyperf\Contract\StdoutLoggerInterface;
use Psr\Log\LogLevel;

$isDebug = env('APP_DEBUG', false);
return [
    'app_name' => env('APP_NAME', 'fastapp'),
    'scan_cacheable' => !$isDebug,
    'debug' => $isDebug,
    'env' => env('APP_ENV', 'prod'),
    'captcha' => env('APP_CAPTCHA', 'captcha'),
    StdoutLoggerInterface::class => [
        'log_level' => $isDebug ? [
            LogLevel::INFO,
            LogLevel::NOTICE,
            LogLevel::WARNING,
            LogLevel::ERROR,
            LogLevel::CRITICAL,
            LogLevel::ALERT,
            LogLevel::EMERGENCY,
        ] : [
            LogLevel::ERROR,
            LogLevel::CRITICAL,
            LogLevel::ALERT,
            LogLevel::EMERGENCY,
        ],
    ],
];
