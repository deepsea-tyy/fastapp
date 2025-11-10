<?php

declare(strict_types=1);

use App\Common\UuidRequestIdProcessor;
use Monolog\Formatter\LineFormatter;
use Monolog\Handler\RotatingFileHandler;
use Monolog\Level;

$isDebug = env('APP_DEBUG', false);
$defaultLevel = $isDebug ? Level::Debug : Level::Info;

return [
    'default' => [
        'handler' => [
            'class' => RotatingFileHandler::class,
            'constructor' => [
                'filename' => BASE_PATH . '/runtime/logs/app.log',
                'level' => $defaultLevel,
                'maxFiles' => $isDebug ? 1 : 10,
                'dateFormat' => 'Y-m-d',
            ],
        ],
        'formatter' => [
            'class' => LineFormatter::class,
            'constructor' => [
                'format' => null,
                'dateFormat' => 'Y-m-d H:i:s',
                'allowInlineLineBreaks' => true,
            ],
        ],
        'processor' => [
            'class' => UuidRequestIdProcessor::class,
        ],
    ],
    'error' => [
        'handler' => [
            'class' => RotatingFileHandler::class,
            'constructor' => [
                'filename' => BASE_PATH . '/runtime/logs/error.log',
                'level' => Level::Error,
                'maxFiles' => $isDebug ? 1 : 10,
                'dateFormat' => 'Y-m-d',
            ],
        ],
        'formatter' => [
            'class' => LineFormatter::class,
            'constructor' => [
                'format' => null,
                'dateFormat' => 'Y-m-d H:i:s',
                'allowInlineLineBreaks' => true,
            ],
        ],
        'processor' => [
            'class' => UuidRequestIdProcessor::class,
        ],
    ],
    'sql' => [
        'handler' => [
            'class' => RotatingFileHandler::class,
            'constructor' => [
                'filename' => BASE_PATH . '/runtime/logs/sql.log',
                'level' => $isDebug ? Level::Info : Level::Emergency,
                'maxFiles' => $isDebug ? 1 : 10,
                'dateFormat' => 'Y-m-d',
            ],
        ],
        'formatter' => [
            'class' => LineFormatter::class,
            'constructor' => [
                'format' => null,
                'dateFormat' => 'Y-m-d H:i:s',
                'allowInlineLineBreaks' => true,
            ],
        ],
        'processor' => [
            'class' => UuidRequestIdProcessor::class,
        ],
    ],
    'queue' => [
        'handler' => [
            'class' => RotatingFileHandler::class,
            'constructor' => [
                'filename' => BASE_PATH . '/runtime/logs/queue.log',
                'level' => $isDebug ? Level::Debug : Level::Info,
                'maxFiles' => $isDebug ? 1 : 10,
                'dateFormat' => 'Y-m-d',
            ],
        ],
        'formatter' => [
            'class' => LineFormatter::class,
            'constructor' => [
                'format' => null,
                'dateFormat' => 'Y-m-d H:i:s',
                'allowInlineLineBreaks' => true,
            ],
        ],
        'processor' => [
            'class' => UuidRequestIdProcessor::class,
        ],
    ],
    'websocket' => [
        'handler' => [
            'class' => RotatingFileHandler::class,
            'constructor' => [
                'filename' => BASE_PATH . '/runtime/logs/websocket.log',
                'level' => $isDebug ? Level::Debug : Level::Info,
                'maxFiles' => $isDebug ? 1 : 10,
                'dateFormat' => 'Y-m-d',
            ],
        ],
        'formatter' => [
            'class' => LineFormatter::class,
            'constructor' => [
                'format' => null,
                'dateFormat' => 'Y-m-d H:i:s',
                'allowInlineLineBreaks' => true,
            ],
        ],
        'processor' => [
            'class' => UuidRequestIdProcessor::class,
        ],
    ],
];
