<?php

declare(strict_types=1);

use App\Common\Jwt\Jwt;
use Lcobucci\JWT\Signer\Hmac\Sha256;
use Lcobucci\JWT\Signer\Key\InMemory;
use Lcobucci\JWT\Token\RegisteredClaims;

/**
 * Get JWT key, automatically detect if it's base64 encoded or plain text
 */
function getJwtKey(?string $secret): InMemory
{
    if (empty($secret)) {
        throw new \RuntimeException('JWT_SECRET or JWT_API_SECRET environment variable is required');
    }

    // Try to decode as base64, if successful and round-trip matches, use base64Encoded
    $decoded = @base64_decode($secret, true);
    if ($decoded !== false && $decoded !== '' && base64_encode($decoded) === $secret) {
        // Valid base64 string
        return InMemory::base64Encoded($secret);
    }

    // Plain text, use as is
    return InMemory::plainText($secret);
}
return [
    'default' => [
        'driver' => Jwt::class,
        'key' => getJwtKey(env('JWT_SECRET')),
        'alg' => new Sha256(),
        'ttl' => (int) env('JWT_TTL', 3600),
        'refresh_ttl' => (int) env('JWT_REFRESH_TTL', 7200),
        'blacklist' => [
            'enable' => true,
            'prefix' => 'jwt_blacklist',
            'connection' => 'default',
            'ttl' => (int) env('JWT_BLACKLIST_TTL', 7201),
        ],
        'claims' => [
            RegisteredClaims::ISSUER => (string) env('APP_NAME'),
        ],
    ],
    'api' => [
        // jwt 配置 https://lcobucci-jwt.readthedocs.io/en/latest/
        'driver' => Jwt::class,
        // jwt 签名key
        'key' => getJwtKey(env('JWT_API_SECRET')),
        // jwt 签名算法 可选 https://lcobucci-jwt.readthedocs.io/en/latest/supported-algorithms/
        'alg' => new Sha256(),
        // token过期时间，单位为秒
        'ttl' => (int) env('JWT_TTL', 3600),
        // 刷新token过期时间，单位为秒
        'refresh_ttl' => (int) env('JWT_REFRESH_TTL', 7200),
        // 黑名单模式
        'blacklist' => [
            // 是否开启黑名单
            'enable' => true,
            // 黑名单缓存前缀
            'prefix' => 'jwt_blacklist',
            // 黑名单缓存驱动
            'connection' => 'default',
            // 黑名单缓存时间 该时间一定要设置比token过期时间要大一点，最好设置跟过期时间一样
            'ttl' => (int) env('JWT_BLACKLIST_TTL', 7201),
        ],
        'claims' => [
            // 默认的jwt claims
            RegisteredClaims::ISSUER => (string) env('APP_NAME'),
        ],
    ],
];
