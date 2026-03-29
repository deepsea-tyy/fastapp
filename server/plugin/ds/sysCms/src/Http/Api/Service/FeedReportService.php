<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Http\Api\Service;

use App\Exception\BusinessException;
use Plugin\Ds\SysCms\Model\FeedReport;

class FeedReportService
{
    /**
     * 提交举报
     *
     * @param array $data
     * @return int 返回举报ID，失败返回false
     */
    public function submitReport(array $data = []): int
    {
        // 检查是否已经举报过（可选：限制重复举报）
        $existingReport = FeedReport::query()
            ->where('user_id', $data['user_id'])
            ->where('target_type', $data['target_type'])
            ->where('target_id', $data['target_id'])
            ->where('handle_status', 0) // 待处理
            ->first();
        if ($existingReport) {
            throw new BusinessException(message: '已举报');
        }
        $report = new FeedReport();
        $report->fill($data);
        $report->save();
        return $report->id;
    }

}
