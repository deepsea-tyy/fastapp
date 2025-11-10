<?php

declare(strict_types=1);

namespace App\Common\Subscriber;

use Hyperf\Command\Event\FailToHandle;
use Hyperf\Contract\ConfigInterface;
use Hyperf\Contract\StdoutLoggerInterface;
use Hyperf\Event\Annotation\Listener;
use Hyperf\Event\Contract\ListenerInterface;
use Hyperf\ExceptionHandler\Formatter\FormatterInterface;
use Hyperf\Logger\LoggerFactory;
use Psr\Log\LoggerInterface;

#[Listener]    // 处理命令异常
final class FailToHandleSubscriber implements ListenerInterface
{
    private LoggerInterface $logger;

    public function __construct(
        private readonly StdoutLoggerInterface $stdoutLogger,
        private readonly FormatterInterface    $formatter,
        LoggerFactory                          $loggerFactory,
        private readonly ConfigInterface       $config,
    )
    {
        $this->logger = $loggerFactory->get('command');
    }

    public function listen(): array
    {
        return [
            FailToHandle::class,
        ];
    }

    /**
     * @param FailToHandle $event
     */
    public function process(object $event): void
    {
        $msg = \sprintf('%s Command failed to handle, %s', $event->getCommand()->getName(), $this->formatter->format($event->getThrowable()));
        $this->config->get('debug') ? $this->stdoutLogger->debug($msg) : $this->logger->debug($msg);
    }
}
