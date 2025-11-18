<?php

declare(strict_types=1);

namespace App\Websocket;

/**
 * WebSocket消息基类
 */
abstract class WsMessageAbstract
{
    protected array $data = [];

    /**
     * 填充消息数据
     */
    abstract public function fill(array $message): void;

    /**
     * 转换为JSON字符串
     */
    public function toJsonString(): string
    {
        return json_encode($this->data, JSON_UNESCAPED_UNICODE);
    }

    /**
     * 转换为数组
     */
    public function toArray(): array
    {
        return $this->data;
    }

    public function get(string $key)
    {
        return $this->data[$key] ?? null;
    }

    /**
     * 获取发送者UID
     */
    public function getFromUid(): ?int
    {
        return $this->data['from_uid'] ?? null;
    }

    /**
     * 获取接收者UID（单个或多个）
     */
    public function getToUids(): array
    {
        return is_array($this->data['to_uid']) ? $this->data['to_uid'] : [$this->data['to_uid']];
    }
}
