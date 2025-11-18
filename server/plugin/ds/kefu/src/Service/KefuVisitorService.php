<?php

declare(strict_types=1);

namespace Plugin\Ds\Kefu\Service;

use App\Common\Tools;
use Plugin\Ds\Kefu\Event\VisitorMessageEndEvent;
use Plugin\Ds\Kefu\Event\VisitorMessageSendEvent;
use Plugin\Ds\Kefu\Model\KefuVisitor;
use Plugin\Ds\Kefu\WebSocket\KefuVisitorMessageEndFormat;
use Plugin\Ds\Kefu\WebSocket\KefuVisitorMessageSendFormat;

class KefuVisitorService
{
    const ID_KEY = 'visitor_';

    public function __construct()
    {
    }

    /**
     * 获取消息列表
     */
    public function list(array $params): array
    {
        $query = KefuVisitor::query()
            ->where('visitor_id', $params['visitor_id'])
            ->where('kefu_id', $params['kefu_id']);

        $paginate = $query
            ->orderByDesc('id')
            ->simplePaginate(perPage: (int)($params['page_size'] ?? 10), page: (int)($params['page'] ?? 1));

        return array_reverse($paginate->items());
    }

    /**
     * 保存游客消息
     */
    public function save(array $data): ?KefuVisitor
    {
        $message = new KefuVisitor();
        $message->fill($data);
        $message->save();

        $messageFormat = new KefuVisitorMessageSendFormat();
        $messageFormat->fill(array_merge($data, [
            'message_id' => $message->id,
            'created_at' => $message->created_at->toDateTimeString(),
        ]));
        Tools::eventDispatcher(new VisitorMessageSendEvent($messageFormat));
        return $message;
    }

    /**
     * 结束游客会话
     *
     * @param array $data
     * @return bool
     */
    public function endConversation(array $data): bool
    {
        $endFormat = new KefuVisitorMessageEndFormat();
        $endFormat->fill($data);
        Tools::eventDispatcher(new VisitorMessageEndEvent($endFormat));
        return true;
    }

    public static function delByVisitorId(string $visitorId): int
    {
        return (int)KefuVisitor::query()->where('visitor_id', $visitorId)->delete();
    }
}

