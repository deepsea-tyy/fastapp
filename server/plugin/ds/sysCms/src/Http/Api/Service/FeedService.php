<?php
/**
 * FastApp.
 * 12/17/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace Plugin\Ds\SysCms\Http\Api\Service;

use Plugin\Ds\SysCms\Model\FeedUserReadPosition;
use Swoole\Coroutine;

class FeedService
{
    public static function readMessage(int $userId, $feed_type): void
    {
        Coroutine::create(function () use ($userId, $feed_type) {
            if (!$userId) return;
            $t = date('Y-m-d H:i:s');
            $map = ['user_id' => $userId, 'feed_type' => $feed_type];
            if (!FeedUserReadPosition::query()->where($map)->update(['last_read_at' => $t])) FeedUserReadPosition::query()->create($map);
        });
    }
}