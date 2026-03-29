<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Crontab;

use Hyperf\Crontab\Annotation\Crontab;
use Plugin\Ds\SysCms\Http\Api\Service\FeedImpressionService;

/**
 * 清理过期的信息流曝光记录
 *
 * 每天凌晨3点执行，清理7天前的曝光记录
 */
#[Crontab(
    name: 'CleanFeedImpressions',
    rule: '0 3 * * *',
    memo: '清理过期的信息流曝光记录（保留7天）',
    enable: true
)]
class CleanFeedImpressionsCrontab
{
    public function execute(): void
    {
        $service = new FeedImpressionService();
        $deletedCount = $service->cleanOldImpressions(7);
    }
}
