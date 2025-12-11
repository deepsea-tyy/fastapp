<?php

declare(strict_types=1);


namespace App\Common\Middleware;

use App\Common\Event\RequestOperationEvent;
use App\Common\Request\Request;
use App\Common\Tools;
use App\Http\CurrentUser;
use Hyperf\Collection\Arr;
use Hyperf\Di\Annotation\AnnotationCollector;
use Hyperf\Di\Annotation\MultipleAnnotation;
use Hyperf\HttpServer\Router\Dispatched;
use Hyperf\HttpServer\Annotation\DeleteMapping;
use Hyperf\HttpServer\Annotation\GetMapping;
use Hyperf\HttpServer\Annotation\PatchMapping;
use Hyperf\HttpServer\Annotation\PostMapping;
use Hyperf\HttpServer\Annotation\PutMapping;
use Hyperf\Swagger\Annotation\Delete;
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\Patch;
use Hyperf\Swagger\Annotation\Post;
use Hyperf\Swagger\Annotation\Put;
use OpenApi\Annotations\Operation;
use Psr\Container\ContainerInterface;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface;

class OperationMiddleware implements MiddlewareInterface
{

    private function parse(mixed $callback): ?array
    {
        if (\is_array($callback) && \count($callback) === 2) {
            return $callback;
        }

        if (!\is_string($callback)) {
            return null;
        }

        $separator = str_contains($callback, '@') ? '@' : (str_contains($callback, '::') ? '::' : null);
        if (!$separator) {
            return null;
        }

        $parts = explode($separator, $callback);
        return \count($parts) === 2 ? $parts : null;
    }

    private const SWAGGER_ATTRIBUTES = [
        Post::class,
        Get::class,
        Delete::class,
        Patch::class,
        Put::class,
    ];

    private const HTTP_SERVER_ATTRIBUTES = [
        PostMapping::class,
        GetMapping::class,
        DeleteMapping::class,
        PatchMapping::class,
        PutMapping::class,
    ];

    public function __construct(
        private readonly CurrentUser        $user,
        private readonly ContainerInterface $container
    ) {}

    public function process(ServerRequestInterface $request, RequestHandlerInterface $handler): ResponseInterface
    {
        $response = $handler->handle($request);

        // 只有请求成功时才记录操作日志
        if ($this->isSuccessResponse($response)) {
            $this->logOperationIfNeeded($request);
        }

        return $response;
    }

    private function getOperationSummary(string $controller, string $method, string $path, string $httpMethod): ?string
    {
        $annotations = AnnotationCollector::getClassMethodAnnotation($controller, $method);

        // 优先查找 Swagger 注解的 summary
        foreach (self::SWAGGER_ATTRIBUTES as $attribute) {
            $annotation = $this->getAnnotation($annotations, $attribute);
            if ($annotation instanceof Operation && !empty($annotation->summary)) {
                return $annotation->summary;
            }
        }

        // 查找 HTTP Server 注解，使用路径生成描述
        foreach (self::HTTP_SERVER_ATTRIBUTES as $attribute) {
            if (!empty($annotations[$attribute])) {
                $pathParts = explode('/', trim($path, '/'));
                $resource = end($pathParts) ?: '';
                return $httpMethod . ' ' . $resource;
            }
        }

        return null;
    }

    private function getAnnotation(array $annotations, string $attribute): ?Operation
    {
        $annotation = $annotations[$attribute] ?? null;
        if (!$annotation instanceof MultipleAnnotation) {
            return null;
        }

        return Arr::first($annotation->toAnnotations());
    }

    private function getRequestParams(ServerRequestInterface $request): array
    {
        $params = array_merge(
            $request->getQueryParams(),
            \is_array($request->getParsedBody()) ? $request->getParsedBody() : []
        );

        // 过滤敏感信息
        $sensitiveKeys = ['password', 'pwd', 'passwd', 'token', 'secret', 'api_key', 'api_secret'];
        foreach ($sensitiveKeys as $key) {
            if (isset($params[$key])) {
                $params[$key] = '***';
            }
        }

        return $params;
    }

    private function isSuccessResponse(ResponseInterface $response): bool
    {
        $statusCode = $response->getStatusCode();
        return $statusCode >= 200 && $statusCode < 300;
    }

    private function logOperationIfNeeded(ServerRequestInterface $request): void
    {
        $dispatched = $request->getAttribute(Dispatched::class);
        $parseResult = $this->parse($dispatched?->handler?->callback);
        if (!$parseResult) {
            return;
        }

        [$controller, $method] = $parseResult;
        $summary = $this->getOperationSummary($controller, $method, $request->getUri()->getPath(), $request->getMethod());
        if (!$summary) {
            return;
        }

        $requestObj = $this->container->get(Request::class);
        Tools::eventDispatcher(new RequestOperationEvent(
            $this->user->id(),
            $summary,
            $request->getUri()->getPath(),
            Arr::first($requestObj->getClientIps(), fn($val) => $val, '0.0.0.0'),
            $request->getMethod(),
            $this->getRequestParams($request)
        ));
    }
}
