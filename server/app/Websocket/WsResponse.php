<?php
/**
 * FastApp.
 * 11/4/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Websocket;

use Hyperf\Contract\Arrayable;

/**
 * WebSocket响应数据结构
 */
class WsResponse implements Arrayable
{
    public function __construct(
        public bool $success = true,
        public mixed $data = null,
        public string $message = '',
        public string $opId = '',
        public ?int $timestamp = null
    ) {
        if ($this->timestamp === null) {
            $this->timestamp = time();
        }
    }

    /**
     * 创建成功响应
     */
    public static function success(mixed $data = null, string $message = '', string $opId = ''): self
    {
        return new self(true, $data, $message, $opId);
    }

    /**
     * 创建失败响应
     */
    public static function error(string $message, string $opId = '', mixed $data = null): self
    {
        return new self(false, $data, $message, $opId);
    }

    /**
     * 转换为数组
     */
    public function toArray(): array
    {
        $result = [
            'success' => $this->success,
            'op_id' => $this->opId,
        ];

        if ($this->message !== '') {
            $result['message'] = $this->message;
        }

        if ($this->data !== null) {
            $result['data'] = $this->data;
        }

        if ($this->timestamp !== null) {
            $result['timestamp'] = $this->timestamp;
        }

        return $result;
    }

    /**
     * 转换为JSON字符串
     */
    public function toJson(): string
    {
        return json_encode($this->toArray(), JSON_UNESCAPED_UNICODE);
    }

    /**
     * 设置操作ID
     */
    public function withOpId(string $opId): self
    {
        $this->opId = $opId;
        return $this;
    }

    /**
     * 设置消息
     */
    public function withMessage(string $message): self
    {
        $this->message = $message;
        return $this;
    }

    /**
     * 设置数据
     */
    public function withData(mixed $data): self
    {
        $this->data = $data;
        return $this;
    }
}

