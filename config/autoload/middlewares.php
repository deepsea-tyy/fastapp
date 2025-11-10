<?php

declare(strict_types=1);

use App\Common\Middleware\CorsMiddleware;
use App\Common\Middleware\TranslationMiddleware;
use Hyperf\Validation\Middleware\ValidationMiddleware;

return [
    'http' => [
        // 多语言识别中间件
        TranslationMiddleware::class,
        // 验证器中间件,处理 formRequest 验证器
        ValidationMiddleware::class,
        // 跨域中间件，正式环境建议关闭。使用 Nginx 等代理服务器处理跨域问题。
        CorsMiddleware::class,
    ],
];
