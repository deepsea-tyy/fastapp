<?php

declare(strict_types=1);

namespace Plugin\Ds\SysKefu\WebSocket;

use App\Websocket\WsMessageAbstract;

/**
 * 客服消息统一格式基类
 * 用于规范化消息推送格式
 */
abstract class KefuMessageFormat extends WsMessageAbstract
{
    /**
     * 获取消息动作类型
     */
    abstract protected function getAction(): string;

    /**
     * 填充消息数据
     */
    public function fill(array $message): void
    {
        $this->data = array_merge([
            'type' => 'push_message',
            'action' => $this->getAction(),
            'timestamp' => time(),
        ], $message);
    }

    /**
     * 获取推送目标用户ID列表
     */
    public function getToUids(): array
    {
        $toUids = [];

        // 用户消息：to_uid 字段
        if (isset($this->data['to_uid'])) {
            $toUids[] = $this->data['to_uid'];
        }

        // 游客消息：visitor_id 或 kefu 的 created_by
        if (isset($this->data['visitor_id']) && isset($this->data['sender_type'])) {
            // 根据发送者类型确定接收者
            if ($this->data['sender_type'] == 1) {
                // 游客发送，推给客服
                // 这里需要通过 kefu_id 查找 created_by，由子类实现
            } else {
                // 客服发送，推给游客
                $toUids[] = $this->data['visitor_id'];
            }
        }

        return array_filter($toUids);
    }
}
