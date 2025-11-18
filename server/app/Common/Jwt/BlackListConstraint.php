<?php
/**
 * FastApp.
 * 10/19/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Common\Jwt;

use Hyperf\Cache\Driver\DriverInterface;
use Lcobucci\JWT\Token;
use Lcobucci\JWT\Validation\Constraint;
use Lcobucci\JWT\Validation\ConstraintViolation;

class BlackListConstraint implements Constraint
{
    public function __construct(
        private readonly bool $enable,
        private readonly DriverInterface $cache
    ) {}

    public function assert(Token $token): void
    {
        if ($this->enable !== true) {
            return;
        }
        if ($this->cache->has($token->toString())) {
            throw ConstraintViolation::error('Token is in blacklist', $this);
        }
    }
}