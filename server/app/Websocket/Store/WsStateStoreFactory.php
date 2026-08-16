<?php

declare(strict_types=1);

namespace App\Websocket\Store;

use Hyperf\Context\ApplicationContext;

final class WsStateStoreFactory
{
    public static function get(): WsStateStore
    {
        $container = ApplicationContext::getContainer();

        return $container->get(CacheWsStateStore::class);//本地
//        return $container->get(RedisWsStateStore::class);//平台
    }
}
