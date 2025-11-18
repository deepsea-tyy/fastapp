<?php
/**
 * FastApp.
 * 10/19/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Common\Middleware;

use App\Common\Jwt\JwtFactory;
use App\Common\Jwt\JwtInterface;
use App\Http\PassportService;
use Hyperf\Collection\Arr;
use Hyperf\Stringable\Str;
use Lcobucci\JWT\Token;
use Lcobucci\JWT\UnencryptedToken;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Swow\Psr7\Message\ServerRequestPlusInterface;
use function Hyperf\Support\value;

abstract class AbstractTokenMiddleware
{
    public function __construct(
        protected readonly JwtFactory $jwtFactory,
        protected readonly PassportService $checkToken
    ) {}

    public function process(ServerRequestInterface $request, RequestHandlerInterface $handler): ResponseInterface
    {
        $token = $this->parserToken($request);
        $this->checkToken->checkJwt($token);
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

    abstract public function getJwt(): JwtInterface;

    protected function parserToken(ServerRequestInterface $request): Token
    {
        return $this->getJwt()->parserAccessToken($this->getToken($request));
    }

    protected function getToken(ServerRequestInterface $request): string
    {
        if ($request->hasHeader('Authorization')) {
            return Str::replace('Bearer ', '', $request->getHeaderLine('Authorization'));
        }
        if ($request->hasHeader('token')) {
            return $request->getHeaderLine('token');
        }
        if (Arr::has($request->getQueryParams(), 'token')) {
            return $request->getQueryParams()['token'];
        }
        return '';
    }
}
