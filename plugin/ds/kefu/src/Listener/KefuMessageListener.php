<?php

declare(strict_types=1);

namespace Plugin\Ds\Kefu\Listener;

use App\Common\Event\WsCloseEvent;
use App\Websocket\WsController;
use Hyperf\Di\Annotation\Inject;
use Hyperf\Event\Annotation\Listener;
use Hyperf\Event\Contract\ListenerInterface;
use Hyperf\WebSocketServer\Sender;
use Plugin\Ds\Kefu\Event\MessageEndEvent;
use Plugin\Ds\Kefu\Event\MessageSendEvent;
use Plugin\Ds\Kefu\Event\VisitorMessageEndEvent;
use Plugin\Ds\Kefu\Event\VisitorMessageSendEvent;
use Plugin\Ds\Kefu\Model\Kefu;
use Plugin\Ds\Kefu\Service\KefuVisitorService;

#[Listener]
final class KefuMessageListener implements ListenerInterface
{
    #[Inject]
    protected Sender $sender;

    /**
     * 监听的事件列表
     */
    public function listen(): array
    {
        return [
            MessageSendEvent::class,
            MessageEndEvent::class,
            VisitorMessageSendEvent::class,
            VisitorMessageEndEvent::class,
            WsCloseEvent::class
        ];
    }

    /**
     * 事件处理入口
     */
    public function process(object $event): void
    {
        try {
            if ($event instanceof MessageSendEvent || $event instanceof MessageEndEvent) {
                $this->pushMessage($event->message);
            } elseif ($event instanceof VisitorMessageSendEvent || $event instanceof VisitorMessageEndEvent) {
                $this->pushVisitorMessage($event->message);
            } elseif ($event instanceof WsCloseEvent) {
                if (str_starts_with($event->userId, KefuVisitorService::ID_KEY)) {
                    KefuVisitorService::delByVisitorId($event->userId);
                }
            }
        } catch (\Throwable $exception) {
            print_r($exception->getMessage());
        }
    }

    /**
     * 推送消息到接收者
     */
    private function pushMessage($message): void
    {
        $toUids = $message->getToUids();
        if (empty($toUids)) {
            return;
        }

        foreach ($toUids as $uid) {
            foreach (WsController::getUserFds($uid) as $fd) {
                $this->sender->push($fd, $message->toJsonString());
            }
        }
    }

    /**
     * 推送游客消息
     */
    private function pushVisitorMessage($message): void
    {
        if ($message->get('sender_type') == 1) {
            $toUid = Kefu::query()->where(['id' => $message->get('kefu_id')])->value('created_by');
        } else {
            $toUid = $message->get('visitor_id');
        }

        if ($toUid) {
            foreach (WsController::getUserFds($toUid) as $fd) {
                $this->sender->push($fd, $message->toJsonString());
            }
        }
    }
}
