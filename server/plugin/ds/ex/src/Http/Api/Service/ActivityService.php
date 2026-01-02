<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Http\Api\Service;

use App\Common\Tools;
use Plugin\Ds\Ex\Model\ExActivity;
use Plugin\Ds\Ex\Model\ExUserActivity;

class ActivityService
{
    /**
     * 获取活动列表
     */
    public function getActivityList(array $params, string $lang = ''): array
    {
        $query = ExActivity::query()
            ->where('status', '>=', 1)
            ->where('deleted_at', null);

        if (isset($params['type'])) {
            $query->where('type', $params['type']);
        }

        if (isset($params['status'])) {
            $query->where('status', $params['status']);
        }

        if (isset($params['is_hot']) && $params['is_hot']) {
            $query->where('is_hot', 1);
        }

        if (isset($params['is_recommend']) && $params['is_recommend']) {
            $query->where('is_recommend', 1);
        }

        $query->orderByDesc('sort_order')
            ->orderByDesc('created_at');

        $page = (int)($params['page'] ?? 1);
        $limit = (int)($params['limit'] ?? 20);

        $total = $query->count();
        $list = $query
            ->offset(($page - 1) * $limit)
            ->limit($limit)
            ->get()
            ->map(function (ExActivity $item) use ($lang) {
                $item->title = Tools::formatLang($item->title, $lang);
                $item->subtitle = Tools::formatLang($item->subtitle, $lang);
                $item->description = Tools::formatLang($item->description, $lang);
                return $item;
            })
            ->toArray();

        return [
            'items' => $list,
            'total' => $total,
            'page' => $page,
            'limit' => $limit,
        ];
    }

    /**
     * 获取活动详情
     */
    public function getActivityDetail(int $activityId, string $lang = '', ?int $uid = null): ?array
    {
        $activity = ExActivity::query()
            ->where('id', $activityId)
            ->where('status', '>=', 1)
            ->whereNull('deleted_at')
            ->first();

        if (!$activity) {
            return null;
        }

        $data = $activity->toArray();
        $data['title'] = Tools::formatLang($activity->title, $lang);
        $data['subtitle'] = Tools::formatLang($activity->subtitle, $lang);
        $data['description'] = Tools::formatLang($activity->description, $lang);

        if ($uid) {
            $userActivity = ExUserActivity::query()
                ->where('uid', $uid)
                ->where('activity_id', $activityId)
                ->first();

            $data['user_status'] = $userActivity ? $userActivity->status : 0;
            $data['user_progress'] = $userActivity ? $userActivity->progress_data : null;
            $data['user_ranking'] = $userActivity ? $userActivity->ranking : null;
        }

        return $data;
    }

    /**
     * 参与活动
     */
    public function joinActivity(int $uid, int $activityId): bool
    {
        $activity = ExActivity::query()->find($activityId);

        if (!$activity || $activity->status != 2) {
            return false;
        }

        if ($activity->participate_limit && $activity->participated_count >= $activity->participate_limit) {
            return false;
        }

        $exists = ExUserActivity::query()
            ->where('uid', $uid)
            ->where('activity_id', $activityId)
            ->exists();

        if ($exists) {
            return false;
        }

        ExUserActivity::query()->create([
            'uid' => $uid,
            'activity_id' => $activityId,
            'status' => 1,
            'join_time' => now(),
        ]);

        $activity->increment('participated_count');

        return true;
    }

    /**
     * 获取用户参与的活动列表
     */
    public function getUserActivities(int $uid, int $page = 1, int $pageSize = 20): array
    {
        $query = ExUserActivity::query()
            ->where('uid', $uid)
            ->orderByDesc('created_at');

        $total = $query->count();
        $list = $query
            ->offset(($page - 1) * $pageSize)
            ->limit($pageSize)
            ->get()
            ->toArray();

        return [
            'list' => $list,
            'total' => $total,
            'page' => $page,
            'page_size' => $pageSize,
        ];
    }
}
