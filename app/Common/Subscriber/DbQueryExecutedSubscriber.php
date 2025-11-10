<?php

declare(strict_types=1);

namespace App\Common\Subscriber;

use App\Common\Tools;
use Hyperf\Collection\Arr;
use Hyperf\Database\Events\QueryExecuted;
use Hyperf\Event\Annotation\Listener;
use Hyperf\Event\Contract\ListenerInterface;

#[Listener] // 处理 SQL 执行日志
final class DbQueryExecutedSubscriber implements ListenerInterface
{

    public function listen(): array
    {
        return [
            QueryExecuted::class,
        ];
    }

    public function process(object $event): void
    {
        if ($event instanceof QueryExecuted) {
            $sql = $event->sql;
            if (!Arr::isAssoc($event->bindings)) {
                $position = 0;
                foreach ($event->bindings as $value) {
                    $position = mb_strpos($sql, '?', $position);
                    if ($position === false) {
                        break;
                    }
                    $value = "'{$value}'";
                    $before = mb_substr($sql, 0, $position);
                    $after = mb_substr($sql, $position + 1, mb_strlen($sql) - $position);
                    $sql = $before . $value . $after;
                    $position += mb_strlen($value);
                }
            }
            $msg = \sprintf('[%s:%s] %s', $event->connectionName, $event->time, $sql);
            // 使用异步日志记录，避免阻塞主流程
            Tools::logAsync($msg, 'info', 'sql', 'sql');
        }
    }
}
