<?php
/**
 * FastApp.
 * 10/19/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Common\Jwt;

use Lcobucci\JWT\UnencryptedToken;

interface JwtInterface
{
    public function builderAccessToken(string $sub, ?\Closure $callable = null): UnencryptedToken;

    public function builderRefreshToken(string $sub, ?\Closure $callable = null): UnencryptedToken;

    public function parserAccessToken(string $accessToken): UnencryptedToken;

    public function parserRefreshToken(string $refreshToken): UnencryptedToken;

    public function addBlackList(UnencryptedToken $token): bool;

    public function hasBlackList(UnencryptedToken $token): bool;

    public function removeBlackList(UnencryptedToken $token): bool;

    public function getConfig(string $key, mixed $default = null): mixed;
}