<?php

declare(strict_types=1);


namespace App\Common\Event;

class RequestOperationEvent
{
    public function __construct(
        private readonly int $userId,
        private readonly string $operation,
        private readonly string $path,
        private readonly string $ip,
        private readonly string $method = 'GET',
        private readonly array $requestParams = []
    ) {}

    public function getOperation(): string
    {
        return $this->operation;
    }

    public function getUserId(): int
    {
        return $this->userId;
    }

    public function getIp(): string
    {
        return $this->ip;
    }

    public function getPath(): string
    {
        return $this->path;
    }

    public function getMethod(): string
    {
        return $this->method;
    }

    public function getRequestParams(): array
    {
        return $this->requestParams;
    }
}
