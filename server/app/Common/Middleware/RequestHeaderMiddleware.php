<?php
/**
 * FastApp.
 * 12/14/25
 * 请求头处理中间件
 * 用于移除会导致 Swoole Content-Length 警告的请求头
 */

namespace App\Common\Middleware;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface;

class RequestHeaderMiddleware implements MiddlewareInterface
{
    public function process(ServerRequestInterface $request, RequestHandlerInterface $handler): ResponseInterface
    {
        // 移除 Accept-Encoding 头,避免 Swoole 尝试压缩响应
        // 这会触发 "Context::build_header() (ERRNO 7105): The client has set 'Accept-Encoding', 'Content-Length' will be ignored" 警告
        // 并可能导致请求处理卡顿
        if ($request->hasHeader('Accept-Encoding')) {
            $request = $request->withoutHeader('Accept-Encoding');
        }

        $response = $handler->handle($request);

        // 确保响应中也没有压缩相关的头
        // 明确告知客户端响应未压缩
        if ($response->hasHeader('Content-Encoding')) {
            $response = $response->withoutHeader('Content-Encoding');
        }

        return $response;
    }
}
