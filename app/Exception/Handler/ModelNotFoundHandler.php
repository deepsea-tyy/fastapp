<?php

declare(strict_types=1);


namespace App\Exception\Handler;

use App\Common\Result;
use App\Common\ResultCode;
use Hyperf\Database\Model\ModelNotFoundException;

final class ModelNotFoundHandler extends AbstractHandler
{
    public function handleResponse(\Throwable $throwable): Result
    {
        $this->stopPropagation();
        return new Result(
            code: ResultCode::NOT_FOUND
        );
    }

    public function isValid(\Throwable $throwable): bool
    {
        return $throwable instanceof ModelNotFoundException;
    }
}
