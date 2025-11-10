<?php
/**
 * FastApp.
 * 10/19/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Common\Jwt;

use Lcobucci\JWT\Token;
use Lcobucci\JWT\Validation\Constraint;
use Lcobucci\JWT\Validation\ConstraintViolation;

class AccessTokenConstraint implements Constraint
{
    public function assert(Token $token): void
    {
        if (! $token->isRelatedTo('refresh')) {
            throw ConstraintViolation::error('Token is not a refresh token', $this);
        }
    }
}