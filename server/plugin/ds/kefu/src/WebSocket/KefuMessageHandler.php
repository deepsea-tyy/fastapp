<?php
/**
 * FastApp.
 * 11/4/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace Plugin\Ds\Kefu\WebSocket;

use App\Websocket\WsMessageHandlerInterface;
use App\Websocket\WsResponse;
use Hyperf\Logger\LoggerFactory;
use Plugin\Ds\Kefu\Service\KefuMessageService;
use Plugin\Ds\Kefu\Service\KefuVisitorService;

class KefuMessageHandler implements WsMessageHandlerInterface
{

    public function __construct(
        protected LoggerFactory      $loggerFactory,
        protected KefuMessageService $messageService,
        protected KefuVisitorService $visitorService,
    )
    {
    }

    /**
     * 获取该处理器支持的所有action映射
     *
     * @return array<string, string>
     */
    public function getActions(): array
    {
        return [
            'kefu_message_send' => 'kefuMessageSend',
            'kefu_message_read' => 'kefuMessageRead',
            'kefu_message_end' => 'kefuMessageEnd',
            'kefu_message_visitor_send' => 'kefuMessageVisitorSend',
            'kefu_message_visitor_end' => 'kefuMessageVisitorEnd',
        ];
    }

    /**
     * 处理通过WebSocket发送客服消息
     */
    protected function kefuMessageSend(array $data, int $userId): WsResponse
    {
        // 验证必要字段
        if (empty($data['conversation_id'])) {
            return WsResponse::error('conversation_id is required');
        }

        if (empty($data['content']) && empty($data['file_url'])) {
            return WsResponse::error('content or file_url is required');
        }

        // 构建消息数据
        $messageData = [
            'conversation_id' => (int)$data['conversation_id'],
            'content' => $data['content'] ?? '',
            'message_type' => (int)($data['message_type'] ?? 1),
            'file_url' => $data['file_url'] ?? null,
        ];

        // 通过KefuMessageService发送消息（会自动触发推送）
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
    protected function kefuMessageRead(array $data, int $userId): WsResponse
    {
        try {
            if (empty($data['conversation_id'])) {
                return WsResponse::error('conversation_id is required');
            }

            // 通过KefuMessageService批量标记已读
            $result = $this->messageService->batchRead([
                'message_ids' => empty($data['message_ids']) ? [] : (is_array($data['message_ids']) ? $data['message_ids'] : []),
                'conversation_id' => $data['conversation_id'],
                'sender_type' => $data['sender_type'] ?? 1
            ]);

            return WsResponse::success([
                'updated_count' => $result
            ], 'Messages marked as read');
        } catch (\Throwable $e) {
            $this->loggerFactory->get('websocket')->error("Mark kefu message read error: " . $e->getMessage());
            return WsResponse::error('Failed to mark messages as read');
        }
    }

    /**
     * 结束会话
     */
    protected function kefuMessageEnd(array $data, int $userId): WsResponse
    {
        try {
            // 验证必要字段
            if (empty($data['conversation_id'])) {
                return WsResponse::error('conversation_id is required');
            }

            $conversationId = (int)$data['conversation_id'];
            $result = $this->messageService->endConversation($conversationId, $userId);

            if (!$result) {
                return WsResponse::error('Failed to end conversation. Conversation not found or no permission.');
            }
            return WsResponse::success([
                'conversation_id' => $conversationId
            ], 'Conversation ended successfully');
        } catch (\Throwable $e) {
            $this->loggerFactory->get('websocket')->error("End kefu conversation error: " . $e->getMessage());
            return WsResponse::error('Failed to end conversation');
        }
    }

    /**
     * 处理游客发送消息
     */
    protected function kefuMessageVisitorSend(array $data): WsResponse
    {
        try {
            if (empty($data['visitor_id'])) {
                return WsResponse::error('visitor_id is required');
            }
            if (empty($data['kefu_id'])) {
                return WsResponse::error('kefu_id is required');
            }

            if (empty($data['content'])) {
                return WsResponse::error('content is required');
            }
            $data['sender_type'] = $data['sender_type'] ?? 1;
            $message = $this->visitorService->save($data);
            if (!$message) {
                return WsResponse::error('Failed to save visitor message');
            }

            return WsResponse::success(['message_id' => $message->id], 'Visitor message sent successfully');
        } catch (\Throwable $e) {
            $this->loggerFactory->get('websocket')->error("Send visitor message error: " . $e->getMessage());
            return WsResponse::error('Failed to send visitor message');
        }
    }

    /**
     * 结束游客会话
     */
    protected function kefuMessageVisitorEnd(array $data): WsResponse
    {
        try {
            if (empty($data['visitor_id'])) {
                return WsResponse::error('visitor_id is required');
            }
            if (empty($data['kefu_id'])) {
                return WsResponse::error('kefu_id is required');
            }
            $data['sender_type'] = $data['sender_type'] ?? 1;
            $this->visitorService->endConversation($data);

            return WsResponse::success([], 'Visitor conversation ended successfully');
        } catch (\Throwable $e) {
            $this->loggerFactory->get('websocket')->error("End visitor conversation error: " . $e->getMessage());
            return WsResponse::error('Failed to end visitor conversation');
        }
    }
}

