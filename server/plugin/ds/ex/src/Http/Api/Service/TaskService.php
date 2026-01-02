<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Http\Api\Service;

use App\Common\Tools;
use Carbon\Carbon;
use Plugin\Ds\Ex\Model\ExTask;
use Plugin\Ds\Ex\Model\ExUserTask;
use Plugin\Ds\Ex\Model\ExRewardLog;

class TaskService
{
    /**
     * 获取任务列表
     */
    public function getTaskList(?string $category = null, ?int $activityId = null, string $lang = '', ?int $uid = null): array
    {
        $query = ExTask::query()
            ->where('status', 1)
            ->whereNull('deleted_at');

        if ($category) {
            $query->where('category', $category);
        }

        if ($activityId) {
            $query->where('activity_id', $activityId);
        }

        $query->orderByDesc('priority');

        $tasks = $query->get()->map(function (ExTask $task) use ($lang, $uid) {
            $data = $task->toArray();
            $data['title'] = Tools::formatLang($task->title, $lang);
            $data['description'] = Tools::formatLang($task->description, $lang);

            if ($uid) {
                $userTask = ExUserTask::query()
                    ->where('uid', $uid)
                    ->where('task_id', $task->id)
                    ->where('date', Carbon::today())
                    ->first();

                $data['user_status'] = $userTask ? $userTask->status : 0;
                $data['progress'] = [
                    'current' => $userTask ? $userTask->progress : 0,
                    'target' => $userTask ? $userTask->target : 0,
                ];
            }

            return $data;
        })->toArray();

        return $tasks;
    }

    /**
     * 获取任务详情
     */
    public function getTaskDetail(int $taskId, string $lang = '', ?int $uid = null): ?array
    {
        $task = ExTask::query()
            ->where('id', $taskId)
            ->where('status', 1)
            ->whereNull('deleted_at')
            ->first();

        if (!$task) {
            return null;
        }

        $data = $task->toArray();
        $data['title'] = Tools::formatLang($task->title, $lang);
        $data['description'] = Tools::formatLang($task->description, $lang);

        if ($uid) {
            $userTask = ExUserTask::query()
                ->where('uid', $uid)
                ->where('task_id', $taskId)
                ->where('date', Carbon::today())
                ->first();

            $data['user_status'] = $userTask ? $userTask->status : 0;
            $data['progress'] = [
                'current' => $userTask ? $userTask->progress : 0,
                'target' => $userTask ? $userTask->target : 0,
            ];
        }

        return $data;
    }

    /**
     * 领取任务奖励
     */
    public function claimTaskReward(int $uid, int $taskId): array
    {
        $userTask = ExUserTask::query()
            ->where('uid', $uid)
            ->where('task_id', $taskId)
            ->where('date', Carbon::today())
            ->whereIn('status', [2])
            ->first();

        if (!$userTask) {
            return ['success' => false, 'message' => '任务未完成或不存在'];
        }

        $task = ExTask::query()->find($taskId);
        if (!$task) {
            return ['success' => false, 'message' => '任务不存在'];
        }

        $userTask->update([
            'status' => 3,
            'claimed_at' => now(),
        ]);

        ExRewardLog::query()->create([
            'uid' => $uid,
            'source_type' => 2,
            'source_id' => $taskId,
            'reward_type' => $task->reward_type,
            'reward_name' => is_array($task->title) ? ($task->title['zh'] ?? $task->title['en'] ?? 'Task Reward') : 'Task Reward',
            'reward_amount' => $task->reward_config['amount'] ?? null,
            'symbol' => $task->reward_config['symbol'] ?? null,
            'reward_config' => $task->reward_config,
            'status' => 0,
        ]);

        return [
            'success' => true,
            'data' => [
                'reward_type' => $task->reward_type,
                'reward_amount' => $task->reward_config['amount'] ?? null,
                'symbol' => $task->reward_config['symbol'] ?? null,
            ],
        ];
    }

    /**
     * 更新任务进度
     */
    public function updateTaskProgress(int $uid, int $taskId, int $progress, ?array $progressData = null): bool
    {
        $task = ExTask::query()->find($taskId);
        if (!$task) {
            return false;
        }

        $userTask = ExUserTask::query()
            ->where('uid', $uid)
            ->where('task_id', $taskId)
            ->where('date', Carbon::today())
            ->first();

        $target = $task->task_config['required_count'] ?? 1;

        if (!$userTask) {
            $userTask = ExUserTask::query()->create([
                'uid' => $uid,
                'task_id' => $taskId,
                'activity_id' => $task->activity_id,
                'status' => 1,
                'progress' => $progress,
                'target' => $target,
                'progress_data' => $progressData,
                'date' => Carbon::today(),
            ]);
        } else {
            $userTask->update([
                'progress' => $progress,
                'progress_data' => $progressData,
            ]);
        }

        if ($progress >= $target && $userTask->status < 2) {
            $userTask->update([
                'status' => 2,
                'completed_at' => now(),
            ]);
        }

        return true;
    }
}
