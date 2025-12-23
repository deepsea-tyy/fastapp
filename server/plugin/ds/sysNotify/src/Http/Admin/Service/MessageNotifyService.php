<?php

declare(strict_types=1);

namespace Plugin\Ds\SysNotify\Http\Admin\Service;

use App\Common\IService;
use App\Common\Tools;
use Plugin\Ds\SysNotify\WebSocket\Event\MessageNotifyEvent;
use Plugin\Ds\SysNotify\Repository\MessageNotifyRepository as Repository;
use Plugin\Ds\SysNotify\WebSocket\MessageNotifyFormat;

class MessageNotifyService extends IService
{
    public function __construct(
        protected readonly Repository $repository
    ) {}

    public function create(array $data): mixed
    {
        $notify = parent::create($data);

        // 触发 WebSocket 推送
        $messageFormat = new MessageNotifyFormat();
        $messageFormat->fill([
            'id' => $notify->id,
            'user_id' => $notify->user_id ?? 0,
            'notify_type' => $notify->notify_type,
            'title' => $notify->title ?? '',
            'content' => $notify->content,
            'created_at' => $notify->created_at->toDateTimeString(),
        ]);
        Tools::eventDispatcher(new MessageNotifyEvent($messageFormat));
        return $notify;
    }
}
