<?php

declare(strict_types=1);


namespace App\Common\Middleware;

use App\Common\Jwt\JwtFactory;
use App\Http\PassportService;
use Hyperf\Stringable\Str;
use Lcobucci\JWT\UnencryptedToken;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Swow\Psr7\Message\ServerRequestPlusInterface;
use function Hyperf\Support\value;

class AccessTokenMiddleware
{
    public function __construct(
        protected readonly JwtFactory         $jwtFactory,
        protected readonly PassportService $checkToken
    )
    {
    }

    public function process(ServerRequestInterface $request, RequestHandlerInterface $handler): ResponseInterface
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
        $token = Str::replace('Bearer ', '', $request->getHeaderLine('Authorization'));
        $pasToken = $this->jwtFactory->get()->parserAccessToken($token);
        $this->checkToken->checkJwt($pasToken);
        return $pasToken;
    }
}
