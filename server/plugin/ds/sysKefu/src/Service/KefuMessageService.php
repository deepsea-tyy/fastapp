<?php

declare(strict_types=1);

namespace Plugin\Ds\SysKefu\Service;

use App\Common\Tools;
use Hyperf\DbConnection\Db;
use Hyperf\Stringable\Str;
use Plugin\Ds\SysKefu\Event\MessageEndEvent;
use Plugin\Ds\SysKefu\Event\MessageSendEvent;
use Plugin\Ds\SysKefu\Model\Kefu;
use Plugin\Ds\SysKefu\Model\KefuConversation;
use Plugin\Ds\SysKefu\Model\KefuMessage;
use Plugin\Ds\SysKefu\WebSocket\KefuMessageEndFormat;
use Plugin\Ds\SysKefu\WebSocket\KefuMessageSendFormat;
use Hyperf\Context\ApplicationContext;
use Hyperf\Coroutine\Coroutine;

class KefuMessageService
{
    /**
     * 获取会话分配
     *
     * @param int $userId
     * @return array
     */
    public function getConversation(int $userId): array
    {
        $c = KefuConversation::query()->where(['user_id' => $userId])->first();
        if ($c) {
            $kefu = Kefu::query()->where(['id' => $c->kefu_id])->first();
        } else {
            $kefu = Kefu::query()->orderBy('current_concurrent')->first();
            $c = new KefuConversation();
            $c->fill([
                'user_id' => $userId,
                'kefu_id' => $kefu->id,
            ]);
            $c->save();
            Kefu::query()->where(['id' => $kefu->id])->increment('current_concurrent');
        }
        return [
            'id' => $c->id,
            'kefu_id' => $c->kefu_id,
            'user_id' => $c->user_id,
            'status' => $c->status,
            'kefu_info' => [
                'id' => $kefu->id,
                'nickname' => $kefu->nickname,
                'avatar' => $kefu->avatar,
                'is_online' => $kefu->status == 1,
            ],
            'help' => array_column(KefuAutoReplyService::getEnabledRules(Tools::lang($userId)),'title')
        ];
    }

    /**
     * 获取消息列表
     */
    public function list(array $params): array
    {
        $paginate = KefuMessage::query()
            ->where(['conversation_id' => $params['conversation_id']])
            ->orderByDesc('id')
            ->simplePaginate(perPage: (int)$params['page_size'] ?? 10, page: (int)$params['page'] ?? 1);
        return ['list' => array_reverse($paginate->items())];
    }

    /**
     * 保存消息
     */
    public function save(array $data, int $userId, int $senderType): ?KefuMessage
    {
        $conversationId = (int)($data['conversation_id'] ?? 0);
        if (!$conversationId) return null;
        $conversation = KefuConversation::query()->find($conversationId);
        if (!$conversation) return null;
        if ($senderType == 1 && $conversation->user_id != $userId) {
            return null;
        }

        Db::beginTransaction();
        try {
            $data['sender_type'] = $senderType;
            // 更新会话的最后消息时间和未读消息数
            $conversation->last_message_at = date('Y-m-d H:i:s');
            if ($senderType == 1) {
                $formUid = $data['sender_id'] = $userId;
                $toUid = Kefu::query()->where(['id' => $conversation->kefu_id])->value('created_by');
                if (!$toUid) return null;
                $conversation->kefu_unread_count = $conversation->kefu_unread_count + 1;
            } else {
                $data['sender_id'] = $conversation->kefu_id;
                $conversation->unread_count = $conversation->unread_count + 1;
                $toUid = $conversation->user_id;
                $formUid = 0;
            }
            $message = KefuMessage::query()->create($data);
            $conversation->save();

            Db::commit();
            // 构建WebSocket消息
            $messageFormat = new KefuMessageSendFormat();
            $messageFormat->fill(array_merge(
                $message->toArray(),
                [
                    'form_uid' => $formUid,
                    'to_uid' => $toUid,
                    'kefu_id' => $conversation->kefu_id,
                    'message_id' => $message->id,
                ]
            ));
            Tools::eventDispatcher(new MessageSendEvent($messageFormat));

            // 如果是用户消息，异步处理自动回复
            if ($senderType == 1 && !empty($data['content'])) {
                $this->triggerAutoReply($conversationId, $userId, $data['content']);
            }

            return $message;
        } catch (\Throwable $th) {
            Db::rollBack();
            return null;
        }
    }

    /**
     * 触发自动回复（异步）
     *
     * @param int $conversationId 会话ID
     * @param int $userId 用户ID
     * @param string $userMessage 用户消息内容
     */
    private function triggerAutoReply(int $conversationId, int $userId, string $userMessage): void
    {
        // 使用协程异步处理自动回复，不阻塞消息发送
        Coroutine::create(function () use ($conversationId, $userId, $userMessage) {
            try {
                ApplicationContext::getContainer()->get(KefuAutoReplyService::class)->handleUserMessage($conversationId, $userId, $userMessage);
            } catch (\Throwable $e) {
                Tools::logAsync($e->getMessage());
            }
        });
    }

    /**
     * 批量标记消息已读
     *
     * @param array $data 消息数据
     * @return int
     */
    public function batchRead(array $data): int
    {
        $query = KefuMessage::query()->where(['conversation_id' => $data['conversation_id'], 'sender_type' => $data['sender_type']]);
        if (!empty($data['message_ids'])) $query->whereIn('id', $data['message_ids']);
        $updated = $query->update([
            'is_read' => 1,
            'read_at' => date('Y-m-d H:i:s'),
        ]);
        if ($data['sender_type'] == 1) {
            $up['unread_count'] = 0;
        } else {
            $up['kefu_unread_count'] = 0;
        }
        KefuConversation::query()->where(['id' => $data['conversation_id']])->update($up);
        return $updated;
    }

    /**
     * 结束会话
     *
     * @param int $conversationId 会话ID
     * @param int $userId 操作者ID
     * @return bool
     */
    public function endConversation(int $conversationId, int $userId): bool
    {
        $conversation = KefuConversation::query()->find($conversationId);
        if (!$conversation) return false;
        if ($conversation->status == 2) return true;

        $operatorType = 1;// 默认用户操作
        $kfUid = Kefu::query()->where(['id' => $conversation->kefu_id])->value('created_by');
        // 情况1：userId是普通用户ID，验证会话是否属于该用户
        if ($conversation->user_id == $userId) {
            $toUid = $kfUid;
            if (!$toUid) return false;
            $fromUid = $userId;
            $conversation->unread_count = 0;
        } else {
            if ($kfUid != $userId) return false;
            $operatorType = 2; //客服操作
            $fromUid = 0;
            $toUid = $conversation->user_id;
            $conversation->kefu_unread_count = 0;
        }
        $conversation->status = 2;

        try {
            Db::beginTransaction();
            $conversation->save();
            Kefu::query()->where('id', $conversation->kefu_id)->decrement('current_concurrent');
            Db::commit();

            // 推送结束会话消息
            $endFormat = new KefuMessageEndFormat();
            $endFormat->fill([
                'form_uid' => $fromUid,
                'to_uid' => $toUid,
                'conversation_id' => $conversation->id,
                'kefu_id' => $conversation->kefu_id,
                'operator_id' => $userId,
                'operator_type' => $operatorType,
            ]);
            Tools::eventDispatcher(new MessageEndEvent($endFormat));
            return true;
        } catch (\Throwable) {
            Db::rollBack();
            return false;
        }
    }


    public function getVisitorKefu(): array
    {
        $kefuId = Kefu::query()->orderBy('current_concurrent')->value('id');
        return ['kefu_id' => $kefuId, 'visitor_id' => KefuVisitorService::ID_KEY . Str::random(8)];
    }
}
