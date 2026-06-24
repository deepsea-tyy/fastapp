<?php

declare(strict_types=1);

return [
    'enable' => true,
    'port' => (int)env('APP_DOC_PORT'),
    'json_dir' => BASE_PATH . '/storage/swagger',
    'html' => '',
    'url' => '/swagger',
    'auto_generate' => true,
    'scan' => [
        'paths' => [
            BASE_PATH . '/app/Common',
            BASE_PATH . '/app/Schema',
            BASE_PATH . '/app/Http/Api',
        ],
    ],
    'processors' => [],
];
