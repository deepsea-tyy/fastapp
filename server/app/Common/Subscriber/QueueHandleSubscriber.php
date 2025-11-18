<?php

declare(strict_types=1);

namespace App\Common\Subscriber;

use Hyperf\AsyncQueue\AnnotationJob;
use Hyperf\AsyncQueue\Event\AfterHandle;
use Hyperf\AsyncQueue\Event\BeforeHandle;
use Hyperf\AsyncQueue\Event\Event;
use Hyperf\AsyncQueue\Event\FailedHandle;
use Hyperf\AsyncQueue\Event\RetryHandle;
use Hyperf\Contract\ConfigInterface;
use Hyperf\Contract\StdoutLoggerInterface;
use Hyperf\Event\Annotation\Listener;
use Hyperf\Event\Contract\ListenerInterface;
use Hyperf\ExceptionHandler\Formatter\FormatterInterface;
use Hyperf\Logger\LoggerFactory;
use Psr\Log\LoggerInterface;

#[Listener]// 处理队列
final class QueueHandleSubscriber implements ListenerInterface
{
    protected LoggerInterface $logger;

    public function __construct(
        /** @phpstan-ignore-next-line */
        private readonly StdoutLoggerInterface $stdoutLogger,
        private readonly FormatterInterface    $formatter,
        LoggerFactory                          $loggerFactory,
        private readonly ConfigInterface       $config,
    )
    {
        $this->logger = $loggerFactory->get('queue');
    }

    public function listen(): array
    {
        return [
            AfterHandle::class,
            BeforeHandle::class,
            FailedHandle::class,
            RetryHandle::class,
        ];
    }

    public function process(object $event): void
    {
        if ($event instanceof Event) {
            $job = $event->getMessage()->job();
            $jobClass = $job::class;
            if ($job instanceof AnnotationJob) {
                $jobClass = \sprintf('Job[%s@%s]', $job->class, $job->method);
            }
            $date = date('Y-m-d H:i:s');
            $format = match (true) {
                $event instanceof BeforeHandle => '[%s] Processing %s.',
                $event instanceof AfterHandle => '[%s] Processed %s.',
                $event instanceof FailedHandle => '[%s] Failed %s.' . \PHP_EOL . $this->formatter->format($event->getThrowable()),
                $event instanceof RetryHandle => '[%s] Retried %s.',
                default => null,
            };

            $msg = \sprintf($format, $date, $jobClass);
            $this->config->get('debug') ? $this->stdoutLogger->debug($msg) : $this->logger->debug($msg);
        }
    }
}
