<?php

declare(strict_types=1);

/**
 * 订单簿配置
 * 支持切换不同的投递方式：redis（默认）或 rust
 */
return [
    /**
     * 订单簿投递驱动
     * 可选值: redis, rust
     * redis: 使用 Redis 队列，由 PHP 撮合进程处理
     * rust: 使用 Rust 撮合引擎处理
     */
    'driver' => env('ORDERBOOK_DRIVER', 'redis'),

    /**
     * Redis 配置（当 driver = redis 时使用）
     */
    'redis' => [
        // Redis 配置使用 config/autoload/redis.php 中的默认配置
    ],

    /**
     * Rust 撮合引擎配置（当 driver = rust 时使用）
     */
    'rust' => [
        /**
         * Rust 撮合引擎 API 地址
         */
        'api_url' => env('RUST_MATCHING_ENGINE_URL', 'http://localhost:8080'),

        /**
         * API 请求超时时间（秒）
         */
        'timeout' => env('RUST_MATCHING_ENGINE_TIMEOUT', 5),
    ],
];
