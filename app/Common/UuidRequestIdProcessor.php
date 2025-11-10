<?php
/**
 * FastApp.
 * 10/19/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 *
 * UUID 请求ID处理器
 *
 * 功能：
 * 1. 为每条日志记录自动添加请求ID（UUID），便于追踪同一请求的所有日志
 * 2. 支持协程环境，子协程自动继承父协程的请求ID
 * 3. 提供静态方法供其他组件获取请求ID（如异常处理、API响应等）
 *
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

declare(strict_types=1);

namespace App\Common;

use Hyperf\Context\Context;
use Hyperf\Coroutine\Coroutine;
use Monolog\LogRecord;
use Monolog\Processor\ProcessorInterface;
use Ramsey\Uuid\Uuid;

final class UuidRequestIdProcessor implements ProcessorInterface
{
    public const REQUEST_ID = 'log.request.id';

    /**
     * 处理日志记录，自动添加请求ID
     */
    public function __invoke(LogRecord $record): LogRecord
    {
        $record->extra['request_id'] = self::getUuid();
        return $record;
    }

    /**
     * 获取当前请求的UUID
     * 
     * 获取优先级：
     * 1. 当前协程的Context中获取
     * 2. 父协程的Context中获取（协程继承）
     * 3. 生成新的UUID并保存
     */
    public static function getUuid(): string
    {
        // 优先从当前协程获取
        $requestId = Context::get(self::REQUEST_ID);
        if ($requestId) {
            return $requestId;
        }

        // 如果在协程中，尝试从父协程继承
        if (Coroutine::inCoroutine()) {
            $parentId = Coroutine::parentId();
            if ($parentId !== null) {
                $requestId = Context::get(self::REQUEST_ID, null, $parentId);
                if ($requestId !== null) {
                    // 继承父协程的请求ID到当前协程
                    Context::set(self::REQUEST_ID, $requestId);
                    return $requestId;
                }
            }
        }

        // 生成新的UUID
        $requestId = Uuid::uuid4()->toString();
        Context::set(self::REQUEST_ID, $requestId);
        return $requestId;
    }

    /**
     * 设置请求UUID（通常由中间件或请求入口调用）
     */
    public static function setUuid(string $requestId): string
    {
        Context::set(self::REQUEST_ID, $requestId);
        return $requestId;
    }
}