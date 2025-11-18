<?php

declare(strict_types=1);


namespace App\Common\Middleware;

use Lcobucci\JWT\UnencryptedToken;
use Psr\Http\Message\ServerRequestInterface;

final class TokenMiddleware extends AccessTokenMiddleware
{

    protected function getToken(ServerRequestInterface $request): ?UnencryptedToken
    {
        $token = $request->getHeaderLine('token');
        $pasToken = $this->jwtFactory->get('api')->parserAccessToken($token);
        $this->checkToken->checkJwt($pasToken);
        return $pasToken;
    }
}
