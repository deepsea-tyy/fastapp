<?php

declare(strict_types=1);

namespace App\Exception\Handler;

use App\Common\Result;
use App\Common\ResultCode;
use App\Exception\JwtInBlackException;

/**
 * JWT 黑名单异常处理器
 * 处理 JwtInBlackException 异常，返回 401 状态码
 */
final class JwtInBlackExceptionHandler extends AbstractHandler
{
    public function handleResponse(\Throwable $throwable): Result
    {
        $this->stopPropagation();
        return new Result(
            code: ResultCode::UNAUTHORIZED,
            message: trans('jwt.blacklisted'),
        );
    }

    public function isValid(\Throwable $throwable): bool
    {
        return $throwable instanceof JwtInBlackException;
    }
}