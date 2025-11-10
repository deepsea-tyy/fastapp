<?php
/**
 * FastApp.
 * 10/17/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Common\Middleware;


use Hyperf\Context\ResponseContext;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface;

class CorsMiddleware implements MiddlewareInterface
{
    public function process(ServerRequestInterface $request, RequestHandlerInterface $handler): ResponseInterface
    {
        if ($request->getMethod() === 'OPTIONS') {
            return $this->setHeader(ResponseContext::get());
        }

        return $this->setHeader($handler->handle($request));
    }

    private function setHeader(ResponseInterface $response)
    {
        return $response->setHeader('Access-Control-Allow-Origin', '*')
            ->setHeader('Access-Control-Allow-Credentials', 'true')
            ->setHeader('Access-Control-Allow-Methods', 'GET, POST, PATCH, PUT, DELETE, OPTIONS')
            ->setHeader('Access-Control-Allow-Headers', '*');
    }
}