<?php

declare(strict_types=1);

namespace Plugin\Ds\SysNotify\Listener;

use App\Common\Tools;
use App\Websocket\Event\WsPushEvent;
use Hyperf\Event\Annotation\Listener;
use Hyperf\Event\Contract\ListenerInterface;
use Plugin\Ds\SysNotify\WebSocket\Event\MessageNotifyEvent;

/**
 * 消息通知推送监听器
 */
#[Listener]
final class MessageNotifyListener implements ListenerInterface
{
    /**
     * 监听的事件列表
     */
    public function listen(): array
    {
        return [
            MessageNotifyEvent::class,
        ];
    }

    /**
     * 事件处理入口
     */
    public function process(object $event): void
    {
        if (!$event instanceof MessageNotifyEvent) {
            return;
        }

        try {
            $message = $event->message;

            // 判断是否为全局推送
            if ($message->isGlobalPush()) {
                $this->pushGlobalMessage($message);
            } else {
                $this->pushToUsers($message);
            }
        } catch (\Throwable $exception) {
            Tools::logAsync(
                'MessageNotifyListener error: ' . $exception->getMessage(),
                'error',
                'error',
                'notify'
            );
        }
    }

    /**
     * 推送消息到指定用户（使用 WsPushEvent）
     */
    private function pushToUsers($message): void
    {
        $toUids = $message->getToUids();
        if (empty($toUids)) {
            return;
        }

        // 获取消息数据和事件类型
        $data = $message->toArray();
        $event = $data['action'] ?? null;

        // 使用 WsPushEvent 统一推送
        Tools::eventDispatcher(
            WsPushEvent::toUsers($toUids, $data, $event)
        );
    }

    /**
     * 推送全局消息（推送给所有在线用户）
     */
    private function pushGlobalMessage($message): void
    {
        $data = $message->toArray();
        $event = $data['action'] ?? null;

        Tools::eventDispatcher(
            WsPushEvent::toAll($data, $event)
        );
    }
}
