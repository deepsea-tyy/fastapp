<?php
/**
 * FastApp.
 * 11/4/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace Plugin\Ds\SysKefu\WebSocket;

use App\Websocket\WsMessageHandlerInterface;
use App\Websocket\WsResponse;
use Plugin\Ds\SysKefu\Service\KefuMessageService;
use Plugin\Ds\SysKefu\Service\KefuVisitorService;

class KefuMessageHandler implements WsMessageHandlerInterface
{
    public function __construct(
        protected KefuMessageService $messageService,
        protected KefuVisitorService $visitorService,
    )
    {
    }

    /**
     * 游客
    */
    public function getVisitorActions(): array
    {
        return [
            'visitor.kefu_message_send' => 'kefuMessageVisitorSend',
            'visitor.kefu_message_end' => 'kefuMessageVisitorEnd',
        ];
    }

    /**
     * 需登录
     *
     * @return array<string, string>
     */
    public function getActions(): array
    {
        return [
            'kefu_message_send' => 'kefuMessageSend',
            'kefu_message_read' => 'kefuMessageRead',
            'kefu_message_end' => 'kefuMessageEnd',
        ];
    }

    /**
     * 验证必填字段
     */
    protected function validateRequired(array $data, array $requiredFields): ?string
    {
        foreach ($requiredFields as $field) {
            if (empty($data[$field])) {
                return "{$field} is required";
            }
        }
        return null;
    }

    /**
     * 统一错误处理包装
     */
    protected function handleWithErrorCatch(callable $callback, string $errorContext): WsResponse
    {
        try {
            return $callback();
        } catch (\Throwable $e) {
            return WsResponse::error("Failed to {$errorContext}");
        }
    }

    /**
     * 处理通过WebSocket发送客服消息
     */
    public function kefuMessageSend(array $data, int $userId): WsResponse
    {
        if ($error = $this->validateRequired($data, ['conversation_id'])) {
            return WsResponse::error($error);
        }

        if (empty($data['content']) && empty($data['file_url'])) {
            return WsResponse::error('content or file_url is required');
        }

        $messageData = [
            'conversation_id' => (int)$data['conversation_id'],
            'content' => $data['content'] ?? '',
            'message_type' => (int)($data['message_type'] ?? 1),
            'file_url' => $data['file_url'] ?? null,
        ];

        $message = $this->messageService->save($messageData, $userId, $data['sender_type'] ?? 1);
        if (!$message) {
            return WsResponse::error('Failed to save message');
        }

        return WsResponse::success([
            'message_id' => $message->id,
            'created_at' => $message->created_at->toDateTimeString()
        ], 'Message sent successfully');
    }

    /**
     * 处理标记客服消息已读
     */
    public function kefuMessageRead(array $data, int $userId): WsResponse
    {
        return $this->handleWithErrorCatch(function () use ($data) {
            if ($error = $this->validateRequired($data, ['conversation_id'])) {
                return WsResponse::error($error);
            }

            $result = $this->messageService->batchRead([
                'message_ids' => is_array($data['message_ids'] ?? null) ? $data['message_ids'] : [],
                'conversation_id' => $data['conversation_id'],
                'sender_type' => $data['sender_type'] ?? 1
            ]);

            return WsResponse::success(['updated_count' => $result], 'Messages marked as read');
        }, 'mark messages as read');
    }

    /**
     * 结束会话
     */
    public function kefuMessageEnd(array $data, int $userId): WsResponse
    {
        return $this->handleWithErrorCatch(function () use ($data, $userId) {
            if ($error = $this->validateRequired($data, ['conversation_id'])) {
                return WsResponse::error($error);
            }

            $conversationId = (int)$data['conversation_id'];
            $result = $this->messageService->endConversation($conversationId, $userId);

            if (!$result) {
                return WsResponse::error('Failed to end conversation. Conversation not found or no permission.');
            }

            return WsResponse::success(['conversation_id' => $conversationId], 'Conversation ended successfully');
        }, 'end conversation');
    }

    /**
     * 处理游客发送消息
     */
    public function kefuMessageVisitorSend(array $data): WsResponse
    {
        return $this->handleWithErrorCatch(function () use ($data) {
            if ($error = $this->validateRequired($data, ['visitor_id', 'kefu_id', 'content'])) {
                return WsResponse::error($error);
            }

            $data['sender_type'] = $data['sender_type'] ?? 1;
            $message = $this->visitorService->save($data);

            if (!$message) {
                return WsResponse::error('Failed to save visitor message');
            }

            return WsResponse::success([
                'message_id' => $message->id,
                'created_at' => $message->created_at->toDateTimeString()
            ], 'Visitor message sent successfully');
        }, 'send visitor message');
    }

    /**
     * 结束游客会话
     */
    public function kefuMessageVisitorEnd(array $data): WsResponse
    {
        return $this->handleWithErrorCatch(function () use ($data) {
            if ($error = $this->validateRequired($data, ['visitor_id', 'kefu_id'])) {
                return WsResponse::error($error);
            }

            $data['sender_type'] = $data['sender_type'] ?? 1;
            $this->visitorService->endConversation($data);

            return WsResponse::success([], 'Visitor conversation ended successfully');
        }, 'end visitor conversation');
    }
}

