<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Repository;

use Hyperf\Collection\Collection;
use Plugin\Ds\SysCms\Model\AppPageContentSync as Model;
use App\Repository\IRepository;
use Hyperf\Database\Model\Builder;

class AppPageContentSyncRepository extends IRepository
{
    public function __construct(protected readonly Model $model)
    {
    }


    /**
     * 获取最新版本（统一使用JSON格式）
     */
    public function getLatestVersion(int $platform): ?Model
    {
        return $this->model::query()
            ->where('platform', $platform)
            ->orderBy('id', 'desc')
            ->first();
    }
}

