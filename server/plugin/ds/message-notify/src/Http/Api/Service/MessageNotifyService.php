<?php

declare(strict_types=1);

namespace Plugin\Ds\MessageNotify\Http\Api\Service;

use Plugin\Ds\MessageNotify\Model\MessageNotify;
use Plugin\Ds\MessageNotify\Model\MessageNotifyRead;
use Plugin\Ds\MessageNotify\Repository\MessageNotifyRepository;

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
        $paginator = $query->simplePaginate($pageSize, ['*'], 'page', $page);

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
     * 更新已读状态
     *
     * @param int $userId 用户ID
     * @param int $notifyType 通知分类
     * @param int $notifyId 消息ID
     * @return bool
     */
    public function updateReadStatus(int $userId, int $notifyType, int $notifyId): bool
    {
        // 查询已读记录
        $readRecord = MessageNotifyRead::query()
            ->where('user_id', $userId)
            ->where('notify_type', $notifyType)
            ->first();

        if ($readRecord) {
            // 更新已读最大ID（取较大值）
            if ($notifyId > $readRecord->notify_id) {
                $readRecord->notify_id = $notifyId;
                $readRecord->save();
            }
        } else {
            // 创建新记录
            MessageNotifyRead::query()->create([
                'user_id' => $userId,
                'notify_type' => $notifyType,
                'notify_id' => $notifyId,
            ]);
        }

        return true;
    }

    /**
     * 获取分类未读统计
     *
     * @param int $userId 用户ID
     * @return array [['notify_type' => int, 'unread_count' => int], ...]
     */
    public function getUnreadStatistics(int $userId): array
    {
        // 使用 LEFT JOIN 和 CASE WHEN 一次性查询所有分类的未读数
        $results = $this->repository->getQuery()
            ->from('message_notify as mn')
            ->leftJoin('message_notify_read as mnr', function ($join) use ($userId) {
                $join->on('mn.notify_type', '=', 'mnr.notify_type')
                    ->where('mnr.user_id', '=', $userId);
            })
            ->where(function ($q) use ($userId) {
                // 全局消息 (user_id=0) 或者个人消息 (user_id=当前用户)
                $q->where('mn.user_id', 0)
                    ->orWhere('mn.user_id', $userId);
            })
            ->whereRaw('mn.id > COALESCE(mnr.notify_id, 0)')
            ->selectRaw('mn.notify_type, COUNT(*) as unread_count')
            ->groupBy('mn.notify_type')
            ->get();

        // 转换为数组格式
        $result = [];
        foreach ($results as $item) {
            $result[] = [
                'notify_type' => $item->notify_type,
                'unread_count' => (int) $item->unread_count,
            ];
        }

        // 确保所有分类都有结果（即使未读数为0）
        $notifyTypes = [1, 2, 3]; // 1-系统通知,2-业务通知,3-其他
        $existingTypes = array_column($result, 'notify_type');
        foreach ($notifyTypes as $notifyType) {
            if (!in_array($notifyType, $existingTypes)) {
                $result[] = [
                    'notify_type' => $notifyType,
                    'unread_count' => 0,
                ];
            }
        }

        return $result;
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
     * 通知个人消息
    */
    public static function notifyToUser(int $userId, int $notifyType, string $content, string $title = ''): bool
    {
        MessageNotify::query()->create([
            'type' => 2,
            'user_id' => $userId,
            'notify_type' => $notifyType,
            'content' => $content,
            'title' => $title,
        ]);
        return true;
    }
}

