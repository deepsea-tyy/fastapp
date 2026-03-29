<?php

declare(strict_types=1);


namespace App\Common\Middleware;

use App\Common\Jwt\JwtFactory;
use App\Http\CurrentUser;
use Lcobucci\JWT\UnencryptedToken;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Swow\Psr7\Message\ServerRequestPlusInterface;

final class TokenMiddleware
{
    public function __construct(
        protected readonly JwtFactory  $jwtFactory,
        protected readonly CurrentUser $service
    )
    {
    }

    public function process(ServerRequestInterface $request, RequestHandlerInterface $handler): \Psr\Http\Message\ResponseInterface
    {
        $token = $this->getToken($request);
        return $handler->handle(
            value(
                static function (ServerRequestPlusInterface $request, UnencryptedToken $token) {
                    return $request->setAttribute('token', $token);
                },
                $request,
                $token
            )
        );
    }

    protected function getToken(ServerRequestInterface $request): ?UnencryptedToken
    {
        $token = $request->getHeaderLine('token');
        $pasToken = $this->jwtFactory->get('api')->parserAccessToken($token);
        $this->service->checkJwt($pasToken);
        return $pasToken;
    }
}
