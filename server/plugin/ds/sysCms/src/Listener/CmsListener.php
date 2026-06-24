<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Listener;

use App\Common\Event\UserRegisterEvent;
use Hyperf\Event\Annotation\Listener;
use Hyperf\Event\Contract\ListenerInterface;
use Plugin\Ds\SysCms\Model\FeedUserStats;

/**
 * CMS 监听器
 * 监听用户注册事件，初始化 Feed 用户统计
 */
#[Listener]
class CmsListener implements ListenerInterface
{
    public function listen(): array
    {
        return [
            UserRegisterEvent::class,
        ];
    }

    public function process(object $event): void
    {
        if ($event instanceof UserRegisterEvent) {
            FeedUserStats::query()->create(['user_id' => $event->getUser()->id]);
        }
    }
}
