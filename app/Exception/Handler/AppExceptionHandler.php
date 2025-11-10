<?php

declare(strict_types=1);


namespace App\Exception\Handler;

use App\Common\Result;
use App\Common\ResultCode;

final class AppExceptionHandler extends AbstractHandler
{
    public function handleResponse(\Throwable $throwable): Result
    {
        $this->stopPropagation();
        return new Result(
            code: ResultCode::FAIL,
            message: $throwable->getMessage()
        );
    }

    public function isValid(\Throwable $throwable): bool
    {
        return true;
    }
}
