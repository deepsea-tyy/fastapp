<?php

declare(strict_types=1);

namespace Plugin\Ds\SysKefu\Listener;

use App\Common\Tools;
use App\Websocket\Event\WsCloseEvent;
use App\Websocket\Event\WsPushEvent;
use Hyperf\Event\Annotation\Listener;
use Hyperf\Event\Contract\ListenerInterface;
use Plugin\Ds\SysKefu\Event\MessageEndEvent;
use Plugin\Ds\SysKefu\Event\MessageSendEvent;
use Plugin\Ds\SysKefu\Event\VisitorMessageEndEvent;
use Plugin\Ds\SysKefu\Event\VisitorMessageSendEvent;
use Plugin\Ds\SysKefu\Model\Kefu;
use Plugin\Ds\SysKefu\Model\KefuVisitor;
use Plugin\Ds\SysKefu\Service\KefuVisitorService;
use Plugin\Ds\SysKefu\WebSocket\KefuVisitorMessageEndFormat;

#[Listener]
final class KefuMessageListener implements ListenerInterface
{
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
                $this->pushToUsers($event->message);
            } elseif ($event instanceof VisitorMessageSendEvent || $event instanceof VisitorMessageEndEvent) {
                $this->pushToUsers($event->message, true);
            } elseif ($event instanceof WsCloseEvent) {
                $this->handleDisconnect($event->userId);
            }
        } catch (\Throwable $exception) {
            Tools::logAsync(
                'KefuMessageListener error: ' . $exception->getMessage(),
                'error',
                'error',
                'kefu'
            );
        }
    }

    /**
     * 统一推送消息到用户（使用 WsPushEvent）
     *
     * @param mixed $message 消息对象
     * @param bool $isVisitor 是否为游客消息
     */
    private function pushToUsers(mixed $message, bool $isVisitor = false): void
    {
        // 获取目标用户ID
        if ($isVisitor) {
            // 游客消息特殊处理
            if ($message->get('sender_type') == 1) {
                // 游客发送，推给客服
                $kefuId = $message->get('kefu_id');
                $toUid = Kefu::query()->where(['id' => $kefuId])->value('created_by');
            } else {
                // 客服发送，推给游客
                $toUid = $message->get('visitor_id');
            }
            if (!$toUid) return;
            $toUids = [$toUid];
        } else {
            // 普通用户消息
            $toUids = $message->getToUids();
        }

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
     * 处理连接断开
     */
    private function handleDisconnect(string $visitorId): void
    {
        // 处理游客断开连接
        if (str_starts_with($visitorId, KefuVisitorService::ID_KEY)) {

            // 查询该游客的会话信息
            $kefu_id = KefuVisitor::query()
                ->where('visitor_id', $visitorId)
                ->value('kefu_id');

            if (!$kefu_id) return;
            // 触发游客会话结束事件
            $endFormat = new KefuVisitorMessageEndFormat();
            $endFormat->fill([
                'visitor_id' => $visitorId,
                'kefu_id' => $kefu_id,
                'sender_type' => 1,
            ]);

            // 推送会话结束消息（复用 pushToUsers）
            $this->pushToUsers($endFormat, true);

            // 删除游客消息记录
            KefuVisitorService::delByVisitorId($visitorId);

        }
    }
}
