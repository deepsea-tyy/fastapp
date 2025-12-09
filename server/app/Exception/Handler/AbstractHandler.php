<?php

declare(strict_types=1);


namespace App\Exception\Handler;

use App\Common\Result;
use App\Common\Tools;
use App\Common\UuidRequestIdProcessor;
use App\Exception\BusinessException;
use Hyperf\Codec\Json;
use Hyperf\Contract\ConfigInterface;
use Hyperf\Contract\StdoutLoggerInterface;
use Hyperf\Database\Model\ModelNotFoundException;
use Hyperf\ExceptionHandler\ExceptionHandler;
use Hyperf\HttpMessage\Stream\SwooleStream;
use Hyperf\Logger\LoggerFactory;
use Psr\Container\ContainerInterface;
use Swoole\Coroutine;
use Swow\Psr7\Message\ResponsePlusInterface;

abstract class AbstractHandler extends ExceptionHandler
{

    public function __construct(
        private readonly ContainerInterface $container,
        private readonly ConfigInterface    $config,
    )
    {
    }

    abstract public function handleResponse(\Throwable $throwable): Result;

    /**
     * 检查异常是否需要记录日志
     *
     * @param \Throwable $throwable
     * @return bool
     */
    private function shouldLogException(\Throwable $throwable): bool
    {
        $ignoredClasses = [
            BusinessException::class,
            ModelNotFoundException::class,
            \Lcobucci\JWT\Exception::class,
            \Hyperf\Validation\ValidationException::class,
        ];
        foreach ($ignoredClasses as $class) {
            if ($throwable instanceof $class) {
                return false;
            }
        }
        return true;
    }

    public function handle(\Throwable $throwable, ResponsePlusInterface $response): ResponsePlusInterface
    {
        $result = $this->handleResponse($throwable)->toArray();

        if ($this->config->get('debug')) {
            $result['throwable'] = [
                'message' => $throwable->getMessage(),
                'file' => $throwable->getFile(),
                'line' => $throwable->getLine(),
//                'trace' => $throwable->getTrace(),
            ];
        }

        if ($this->shouldLogException($throwable)) {
            if ($this->config->get('debug')) {
                $this->container->get(StdoutLoggerInterface::class)->error(implode(' ', [$throwable->getMessage(), $throwable->getFile(), $throwable->getLine()]));
            }
            Coroutine::create(static function () use ($throwable) {
                Tools::getContainer()->get(LoggerFactory::class)->get('exception', 'error')->error($throwable->getMessage(), ['exception' => $throwable]);
            });
        }
        return $response
            ->setHeader('Content-Type', 'application/json; charset=utf-8')
            ->setHeader('Request-Id', UuidRequestIdProcessor::getUuid())
            ->setHeader('Access-Control-Allow-Origin', '*')
            ->setHeader('Access-Control-Allow-Headers', '*')
            ->setHeader('Access-Control-Allow-Credentials', 'true')
            ->setBody(new SwooleStream(Json::encode($result)));
    }
}
