<?php

declare(strict_types=1);


namespace App\Exception\Handler;

use App\Common\Result;
use App\Exception\BusinessException;

final class BusinessExceptionHandler extends AbstractHandler
{
    /**
     * @param BusinessException $throwable
     */
    public function handleResponse(\Throwable $throwable): Result
    {
        $this->stopPropagation();
        return $throwable->getResponse();
    }

    public function isValid(\Throwable $throwable): bool
    {
        return $throwable instanceof BusinessException;
    }
}
