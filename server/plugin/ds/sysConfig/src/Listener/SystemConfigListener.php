<?php

declare(strict_types=1);

namespace Plugin\Ds\SysConfig\Listener;

use Hyperf\Database\Model\Events\Created;
use Hyperf\Database\Model\Events\Deleted;
use Hyperf\Database\Model\Events\Updated;
use Hyperf\Event\Annotation\Listener;
use Hyperf\Event\Contract\ListenerInterface;
use Plugin\Ds\SysConfig\Helper\CacheConfigHelper;
use Plugin\Ds\SysConfig\Model\Config;
use Psr\Container\ContainerInterface;

#[Listener]
class SystemConfigListener implements ListenerInterface
{
    public function __construct(protected ContainerInterface $container)
    {
    }

    public function listen(): array
    {
        return [
            Created::class,
            Updated::class,
            Deleted::class,
        ];
    }

    public function process(object $event): void
    {
        if ($event->getModel() instanceof Config) {
            CacheConfigHelper::clear();
        }
    }
}
