<?php

declare(strict_types=1);

use Hyperf\HttpServer\Router\Router;

Router::get('/', static function () {
    return 'welcome use fastapp';
});

Router::get('/favicon.ico', static function () {
    return '';
});

Router::addServer('ws', function () {
    Router::get('/ws', \App\Websocket\WsController::class);
});
