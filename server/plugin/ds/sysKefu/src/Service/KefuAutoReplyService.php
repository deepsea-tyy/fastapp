<?php

declare(strict_types=1);

namespace Plugin\Ds\SysKefu\Service;

use App\Common\Tools;
use Hyperf\DbConnection\Db;
use Hyperf\Redis\Redis;
use Plugin\Ds\SysConfig\Helper\CacheConfigHelper;
use Plugin\Ds\SysKefu\Event\MessageSendEvent;
use Plugin\Ds\SysKefu\Model\KefuAutoReply;
use Plugin\Ds\SysKefu\Model\KefuAutoReplyLog;
use Plugin\Ds\SysKefu\Model\KefuConversation;
use Plugin\Ds\SysKefu\Model\KefuMessage;
use Plugin\Ds\SysKefu\Model\Kefu;
use Plugin\Ds\SysKefu\WebSocket\KefuMessageSendFormat;
use Psr\Container\ContainerExceptionInterface;
use Psr\Container\NotFoundExceptionInterface;

class KefuAutoReplyService
{
    /**
     * Redis 缓存 Key 前缀
     */
    private const CACHE_PREFIX = 'kefu:auto_reply:';

    /**
     * 规则缓存 Key
     */
    private const RULES_CACHE_KEY = self::CACHE_PREFIX . 'rules:';

    /**
     * 节流缓存 Key
     */
    private const THROTTLE_CACHE_KEY = self::CACHE_PREFIX . 'throttle:';

    /**
     * 检查是否启用自动回复
     */
    public function isEnabled(): bool
    {
        return !empty(CacheConfigHelper::getConfigByKey('auto_reply_enabled')['value']);
    }

    public function getConfig(): array
    {
        $res = CacheConfigHelper::getConfigByGroupKey('kefu_config')->toArray();
        $data = [];

        foreach ($res as $v) {
            if (in_array($v['input_type'], ['keyValuePair', 'select'])) {
                $data[$v['key']] = array_column($v['config_select_data'], 'label', 'value');
            } else
                $data[$v['key']] = $v['value'];
        }
        return $data;
    }

    /**
     * 检查是否在工作时间
     */
    public function isWorkTime(): bool
    {
        $now = date('H:i');
        $start = $this->getConfig()['work_time_start'] ?: '09:00';
        $end = $this->getConfig()['work_time_end'] ?: '22:00';
        return $now >= $start && $now <= $end;
    }

    /**
     * 处理用户消息，尝试自动回复
     *
     * @param int $conversationId 会话ID
     * @param int $userId 用户ID
     * @param string $userMessage 用户消息内容
     * @return bool 是否发送了自动回复
     * @throws ContainerExceptionInterface
     * @throws NotFoundExceptionInterface
     * @throws \RedisException
     * @throws \Throwable
     */
    public function handleUserMessage(int $conversationId, int $userId, string $userMessage): bool
    {
        $lang = Tools::lang($userId);
        // 1. 检查是否启用自动回复
        if (!$this->isEnabled()) {
            return false;
        }
        // 2. 获取会话信息
        $conversation = KefuConversation::query()->find($conversationId);
        if (!$conversation) {
            return false;
        }
        // 3. 检查是否在工作时间，非工作时间发送离线提示
        if (!$this->isWorkTime()) {
            $this->sendOfflineMessage($conversation, $userId, $lang);
            return true;
        }
        // 4. 匹配规则
        $rule = $this->matchRule($userMessage, $lang);
        if (!$rule) {
            return false;
        }
        // 5. 检查节流（防止重复回复）
        if (!$this->checkThrottle($conversationId, $rule['id'])) {
            return false;
        }
        // 6. 延迟发送（模拟真人）
        $delay = (int)$this->getConfig()['auto_reply_delay'];
        if ($delay > 0) {
            sleep($delay);
        }

        // 7. 发送自动回复
        $this->sendAutoReply($conversation, $userId, $rule, $userMessage, $lang);

        return true;
    }

    /**
     * 匹配规则
     *
     * @param string $userMessage 用户消息
     * @param string $lang 语言
     * @return array|null 匹配的规则
     */
    public function matchRule(string $userMessage, string $lang = 'zh_CN'): ?array
    {
        $rules = self::getEnabledRules($lang);
        foreach ($rules as $rule) {
            if ($this->isMatch($rule, $userMessage)) {
                return $rule;
            }
        }

        return null;
    }

    /**
     * 获取启用的规则（带缓存）
     *
     * @param string $lang 语言
     * @return array
     */
    public static function getEnabledRules(string $lang = 'zh_CN'): array
    {
        $redis = Tools::getContainer()->get(Redis::class);
        $cacheKey = self::RULES_CACHE_KEY . $lang;

        // 尝试从缓存获取
        $cached = $redis->get($cacheKey);
        if ($cached) {
            return json_decode($cached, true);
        }

        // 从数据库查询
        $rules = KefuAutoReply::query()
            ->where('status', KefuAutoReply::STATUS_ENABLED)
            ->where('lang', $lang)
            ->orderByDesc('priority')
            ->orderBy('id')
            ->get()
            ->toArray();

        // 缓存规则（5分钟）
        $redis->setex($cacheKey, 300, json_encode($rules));

        return $rules;
    }

    /**
     * 清除规则缓存
     *
     * @param string|null $lang 语言，null 表示清除所有语言
     */
    public function clearRulesCache(?string $lang = null): void
    {
        $redis = Tools::getContainer()->get(Redis::class);

        if ($lang) {
            $redis->del(self::RULES_CACHE_KEY . $lang);
        } else {
            // 清除所有语言的缓存
            $keys = $redis->keys(self::RULES_CACHE_KEY . '*');
            if ($keys) {
                $redis->del(...$keys);
            }
        }
    }

    /**
     * 判断是否匹配
     *
     * @param array|KefuAutoReply $rule 规则
     * @param string $userMessage 用户消息
     * @return bool
     */
    private function isMatch($rule, string $userMessage): bool
    {
        if (is_array($rule)) {
            $triggerType = $rule['trigger_type'];
            $keywords = $rule['keywords'];
        } else {
            $triggerType = $rule->trigger_type;
            $keywords = $rule->keywords;
        }

        switch ($triggerType) {
            case KefuAutoReply::TRIGGER_TYPE_EXACT:
                // 精确匹配
                return in_array($userMessage, $keywords, true);

            case KefuAutoReply::TRIGGER_TYPE_FUZZY:
                // 模糊匹配
                foreach ($keywords as $keyword) {
                    if (stripos($userMessage, $keyword) !== false) {
                        return true;
                    }
                }
                return false;

            case KefuAutoReply::TRIGGER_TYPE_REGEX:
                // 正则匹配
                foreach ($keywords as $pattern) {
                    if (@preg_match($pattern, $userMessage)) {
                        return true;
                    }
                }
                return false;

            default:
                return false;
        }
    }

    /**
     * 检查节流（防止重复回复）
     *
     * @param int $conversationId 会话ID
     * @param int $ruleId 规则ID
     * @return bool 是否可以回复
     */
    private function checkThrottle(int $conversationId, int $ruleId): bool
    {
        $redis = Tools::getContainer()->get(Redis::class);
        $throttleKey = self::THROTTLE_CACHE_KEY . "{$conversationId}:{$ruleId}";

        // 检查是否存在
        if ($redis->exists($throttleKey)) {
            return false;
        }

        // 设置节流标记
        $throttleTime = (int)$this->getConfig()['auto_reply_throttle'];
        $redis->setex($throttleKey, $throttleTime, 1);

        return true;
    }

    /**
     * 发送自动回复
     *
     * @param KefuConversation $conversation 会话
     * @param int $userId 用户ID
     * @param array|KefuAutoReply $rule 规则
     * @param string $userMessage 用户消息
     * @param string $lang 语言
     */
    private function sendAutoReply($conversation, int $userId, $rule, string $userMessage, string $lang): void
    {
        Db::beginTransaction();
        try {
            $ruleId = is_array($rule) ? $rule['id'] : $rule->id;
            $replyContent = $rule['reply_content'];

            // 1. 创建消息记录
            $message = new KefuMessage();
            $message->conversation_id = $conversation->id;
            $message->sender_id = $conversation->kefu_id;
            $message->sender_type = 2; // 客服
            $message->content = $replyContent['text'] ?? '';
            $message->message_type = 1; // 文本
            $message->is_read = 0;
            $message->is_auto_reply = 1;
            $message->auto_reply_rule_id = $ruleId;
            $message->save();

            // 2. 更新会话未读数
            $conversation->unread_count = $conversation->unread_count + 1;
            $conversation->last_message_at = date('Y-m-d H:i:s');
            $conversation->save();

            // 3. 更新规则命中次数
            KefuAutoReply::query()->where('id', $ruleId)->increment('hit_count');

            // 4. 记录日志
            (new KefuAutoReplyLog)->fill([
                'conversation_id' => $conversation->id,
                'user_id' => $userId,
                'kefu_id' => $conversation->kefu_id,
                'rule_id' => $ruleId,
                'user_message' => $userMessage,
                'reply_content' => $replyContent,
                'lang' => $lang,
            ])->save();

            Db::commit();

            // 5. 推送 WebSocket 消息
            $this->pushWebSocketMessage($conversation, $message, $userId);
        } catch (\Throwable $e) {
            Db::rollBack();
            throw $e;
        }
    }

    /**
     * 发送离线提示
     *
     * @param KefuConversation $conversation 会话
     * @param int $userId 用户ID
     * @param string $lang 语言
     */
    private function sendOfflineMessage(KefuConversation $conversation, int $userId, string $lang): void
    {
        $offlineMessage = $this->getConfig()['offline_message'][$lang];

        Db::beginTransaction();
        try {
            $message = new KefuMessage();
            $message->conversation_id = $conversation->id;
            $message->sender_id = $conversation->kefu_id;
            $message->sender_type = 2;
            $message->content = $offlineMessage;
            $message->message_type = 1;
            $message->is_read = 0;
            $message->is_auto_reply = 1;
            $message->save();

            $conversation->unread_count = $conversation->unread_count + 1;
            $conversation->last_message_at = date('Y-m-d H:i:s');
            $conversation->save();

            Db::commit();

            $this->pushWebSocketMessage($conversation, $message, $userId);
        } catch (\Throwable $e) {
            Db::rollBack();
            throw $e;
        }
    }

    /**
     * 推送 WebSocket 消息
     *
     * @param KefuConversation $conversation 会话
     * @param KefuMessage $message 消息
     * @param int $userId 用户ID
     */
    private function pushWebSocketMessage(KefuConversation $conversation, KefuMessage $message, int $userId): void
    {
        $kfUid = Kefu::query()->where('id', $conversation->kefu_id)->value('created_by');
        if (!$kfUid) {
            return;
        }

        $messageFormat = new KefuMessageSendFormat();
        $messageFormat->fill(array_merge(
            $message->toArray(),
            [
                'form_uid' => 0,
                'to_uid' => $userId,
                'kefu_id' => $conversation->kefu_id,
                'message_id' => $message->id,
            ]
        ));

        Tools::eventDispatcher(new MessageSendEvent($messageFormat));
    }

    /**
     * 获取统计数据
     *
     * @param string $lang 语言
     * @return array
     */
    public function getStats(string $lang = ''): array
    {
        $query = KefuAutoReply::query();
        if ($lang) {
            $query->where('lang', $lang);
        }

        $totalRules = $query->count();
        $enabledRules = (clone $query)->where('status', KefuAutoReply::STATUS_ENABLED)->count();
        $totalHits = (clone $query)->sum('hit_count');

        $topRules = (clone $query)
            ->where('hit_count', '>', 0)
            ->orderByDesc('hit_count')
            ->limit(10)
            ->get(['id', 'title', 'hit_count', 'lang']);

        return [
            'total_rules' => $totalRules,
            'enabled_rules' => $enabledRules,
            'total_hits' => $totalHits,
            'top_rules' => $topRules,
        ];
    }
}
