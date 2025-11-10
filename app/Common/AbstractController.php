<?php

declare(strict_types=1);


namespace App\Common;
use App\Common\Request\Request;
use Hyperf\Context\ApplicationContext;

abstract class AbstractController
{
    protected function success(mixed $data = [], ?string $message = null): Result
    {
        return new Result(ResultCode::SUCCESS, $message, $data);
    }

    protected function error(?string $message = null, mixed $data = []): Result
    {
        return new Result(ResultCode::FAIL, $message, $data);
    }

    protected function json(ResultCode $code, mixed $data = [], ?string $message = null): Result
    {
        return new Result($code, $message, $data);
    }

    protected function getRequest(): Request
    {
        return ApplicationContext::getContainer()->get(Request::class);
    }
    protected function getCurrentPage(): int
    {
        return (int) $this->getRequest()->input('page', 1);
    }

    protected function getPageSize(): int
    {
        return (int) $this->getRequest()->input('page_size', 10);
    }

    protected function getRequestData(): array
    {
        return $this->getRequest()->all();
    }
}
