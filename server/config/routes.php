<?php

declare(strict_types=1);

use App\Common\Tools;
use Hyperf\HttpMessage\Stream\SwooleStream;
use Hyperf\HttpServer\Response;
use Hyperf\HttpServer\Router\Router;

Router::get('/', static function () {
    $index = Tools::ui_index_path();
    if ($index === null) {
        return 'welcome use fastapp';
    }

    return (new Response())
        ->withHeader('Content-Type', 'text/html; charset=utf-8')
        ->withBody(new SwooleStream((string) file_get_contents($index)));
});

Router::get('/favicon.ico', static function () {
    return '';
});

Router::addServer('ws', function () {
    Router::get('/ws', \App\Websocket\WsController::class);
});
