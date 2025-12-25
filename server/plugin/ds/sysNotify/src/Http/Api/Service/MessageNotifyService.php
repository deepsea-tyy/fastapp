<?php

declare(strict_types=1);

namespace Plugin\Ds\SysNotify\Http\Api\Service;

use App\Common\Tools;
use Plugin\Ds\SysNotify\WebSocket\Event\MessageNotifyEvent;
use Plugin\Ds\SysNotify\Model\MessageNotify;
use Plugin\Ds\SysNotify\Model\MessageNotifyRead;
use Plugin\Ds\SysNotify\Repository\MessageNotifyRepository;
use Plugin\Ds\SysNotify\WebSocket\MessageNotifyFormat;

class MessageNotifyService
{
    public function __construct(
        protected readonly MessageNotifyRepository $repository
    )
    {
    }

    /**
     * 获取消息列表（自己和全局消息）
     *
     * @param int $userId 用户ID
     * @param array $params 查询参数
     * @param int $page 页码
     * @param int $pageSize 每页数量
     * @return array
     */
    public function getMessageList(int $userId, array $params = [], int $page = 1, int $pageSize = 10): array
    {
        $query = $this->repository->getQuery()
            ->where('type', 1)
            ->where(function ($q) use ($userId) {
                // 全局消息 (user_id=0) 或者个人消息 (user_id=当前用户)
                $q->where('user_id', 0)
                    ->orWhere('user_id', $userId);
            })
            ->orderBy('id', 'desc');

        // 处理搜索条件
        if (!empty($params['notify_type'])) {
            $query->where('notify_type', $params['notify_type']);
        }

        // 分页
        $paginator = $query->simplePaginate($pageSize, page: $page);

        // 获取已读状态
        $readStatus = $this->getReadStatus($userId);

        // 处理列表数据，添加已读状态
        $list = $paginator->getCollection()->map(function ($item) use ($readStatus) {
            $notifyType = $item->notify_type;
            $notifyId = $item->id;
            // 判断是否已读：如果该分类的最大已读ID >= 当前消息ID，则已读
            $isRead = isset($readStatus[$notifyType]) && $readStatus[$notifyType] >= $notifyId;

            $data = $item->toArray();
            $data['is_read'] = $isRead ? 1 : 0;
            return $data;
        })->toArray();

        return [
            'list' => $list,
        ];
    }

    /**
     * 获取分类未读统计
     *
     * @param int $userId 用户ID
     * @return array ['1' => ['unread_count' => int, 'title' => array, 'content' => array, 'created_at' => string], 'total' => int]
     */
    public function getUnreadStatistics(int $userId): array
    {
        // 使用一条 SQL 查询同时获取所有分类的未读数统计和最新消息
        $sql = "
            WITH notify_types AS (
                SELECT 1 AS notify_type UNION ALL
                SELECT 2 UNION ALL
                SELECT 3 UNION ALL
                SELECT 4 UNION ALL
                SELECT 5
            ),
            -- 未读统计
            unread_stats AS (
                SELECT
                    mn.notify_type,
                    COUNT(*) as unread_count
                FROM message_notify mn
                LEFT JOIN message_notify_read mnr ON mn.notify_type = mnr.notify_type
                    AND mnr.user_id = ?
                WHERE (mn.user_id = 0 OR mn.user_id = ?)
                  AND mn.id > COALESCE(mnr.notify_id, 0)
                GROUP BY mn.notify_type
            ),
            -- 每个分类最新消息
            latest_messages AS (
                SELECT
                    mn1.notify_type,
                    mn1.id,
                    mn1.title,
                    mn1.content,
                    mn1.created_at
                FROM message_notify mn1
                INNER JOIN (
                    SELECT notify_type, MAX(id) as max_id
                    FROM message_notify
                    WHERE user_id = 0 OR user_id = ?
                    GROUP BY notify_type
                ) mn2 ON mn1.notify_type = mn2.notify_type AND mn1.id = mn2.max_id
            )
            SELECT
                nt.notify_type,
                COALESCE(us.unread_count, 0) as unread_count,
                COALESCE(lm.id, 0) as latest_id,
                COALESCE(lm.title, '[]') as latest_title,
                COALESCE(lm.content, '[]') as latest_content,
                COALESCE(lm.created_at, '') as latest_created_at
            FROM notify_types nt
            LEFT JOIN unread_stats us ON nt.notify_type = us.notify_type
            LEFT JOIN latest_messages lm ON nt.notify_type = lm.notify_type
            ORDER BY nt.notify_type
        ";

        $results = \Hyperf\DbConnection\Db::select($sql, [$userId, $userId, $userId]);

        // 使用 array_reduce 处理结果
        $data = array_reduce($results, function ($carry, $row) {
            $title = json_decode($row->latest_title ?: '', true);
            $content = json_decode($row->latest_content ?: '', true);
            $carry[(string)$row->notify_type] = [
                'unread_count' => (int)$row->unread_count,
                'title' => Tools::formatLang($title ?: []),
                'content' => Tools::formatLang($content ?: []),
                'last_id' => (int)$row->latest_id,
                'created_at' => $row->latest_created_at ?? '',
            ];
            return $carry;
        }, []);

        // 计算总未读数
        $total = array_sum(array_column($data, 'unread_count'));
        $data['total'] = $total;

        return $data;
    }

    /**
     * 获取用户的已读状态
     *
     * @param int $userId 用户ID
     * @return array [notify_type => max_notify_id]
     */
    protected function getReadStatus(int $userId): array
    {
        $readRecords = MessageNotifyRead::query()
            ->where('user_id', $userId)
            ->get();

        $readStatus = [];
        foreach ($readRecords as $record) {
            $readStatus[$record->notify_type] = $record->notify_id;
        }

        return $readStatus;
    }

    /**
     * 更新已读状态
     *
     * @param int $userId 用户ID
     * @param int $notifyType 通知分类
     * @param int $notifyId 消息ID
     * @return bool
     */
    public function read(int $userId, int $notifyType, int $notifyId): bool
    {
        $readRecord = MessageNotifyRead::query()
            ->firstOrCreate(['user_id'=>$userId, 'notify_type'=>$notifyType]);
        $readRecord->notify_id = $notifyId;
        $readRecord->save();
        return true;
    }

    /**
     * 清除所有分类的未读消息
     *
     * @param int $userId 用户ID
     * @return bool
     */
    public function clearAllUnread(int $userId): bool
    {
        // 获取所有分类（1-5）
        $notifyTypes = [1, 2, 3, 4, 5];

        foreach ($notifyTypes as $notifyType) {
            // 获取该分类下的最大消息ID
            $maxNotifyId = MessageNotify::query()
                ->where('notify_type', $notifyType)
                ->where(function ($q) use ($userId) {
                    // 全局消息或个人消息
                    $q->where('user_id', 0)
                        ->orWhere('user_id', $userId);
                })
                ->max('id');
            if ($maxNotifyId) {
                $this->read($userId, $notifyType, $maxNotifyId);
            }
        }

        return true;
    }

    /**
     * 通知个人消息
     */
    public static function notifyToUser(int $userId, int $notifyType, string $content, string $title = ''): bool
    {
        $notify = MessageNotify::query()->create([
            'type' => 2,
            'user_id' => $userId,
            'notify_type' => $notifyType,
            'content' => $content,
            'title' => $title,
        ]);

        // 触发 WebSocket 推送
        self::pushNotify($notify);

        return true;
    }

    /**
     * 全局消息推送（推送给所有在线用户）
     *
     * @param int $notifyType 通知类型 1-系统通知,2-业务通知,3-其他
     * @param string $content 消息内容
     * @param string $title 消息标题
     * @return bool
     */
    public static function notifyToAll(int $notifyType, string $content, string $title = ''): bool
    {
        $notify = MessageNotify::query()->create([
            'type' => 1,
            'user_id' => 0,  // user_id = 0 表示全局消息
            'notify_type' => $notifyType,
            'content' => $content,
            'title' => $title,
        ]);

        // 触发 WebSocket 推送
        self::pushNotify($notify);

        return true;
    }

    /**
     * 推送通知消息
     */
    protected static function pushNotify($notify): void
    {
        $messageFormat = new MessageNotifyFormat();
        $messageFormat->fill([
            'id' => $notify->id,
            'user_id' => $notify->user_id ?? 0,
            'notify_type' => $notify->notify_type,
            'title' => $notify->title ?? '',
            'content' => $notify->content,
            'created_at' => $notify->created_at->toDateTimeString(),
        ]);
        Tools::eventDispatcher(new MessageNotifyEvent($messageFormat));
    }
}

