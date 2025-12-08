<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Repository;

use Hyperf\Collection\Collection;
use Plugin\Ds\SysCms\Model\AppPageContent as Model;
use App\Repository\IRepository;
use Hyperf\Database\Model\Builder;
use App\Http\Admin\Service\Permission\DataScopeTool;

class AppPageContentRepository extends IRepository
{
    public function __construct(protected readonly Model $model)
    {
    }

    public function handleSearch(Builder $query, array $params): Builder
    {
        if (isset($params['created_by'])) {
            DataScopeTool::applyUserDataScope($params['created_by'], $query);
        }
        
        if (isset($params['include_expired']) && $params['include_expired'] == 0) {
            $this->applyTimeFilter($query, time());
        }
        
        return $query;
    }

    /**
     * 获取启用的内容（用于文件生成）
     */
    public function getEnabledContents(int $platform): Collection
    {
        return $this->model::query()
            ->where('status', 1)
            ->where(function ($query) use ($platform) {
                $query->where('platform', $platform)->orWhere('platform', 3);
            })
            ->where(function ($q) {
                $this->applyTimeFilter($q, time());
            })
            ->orderBy('sort')
            ->orderBy('id')
            ->get();
    }

    /**
     * 应用时间过滤条件
     */
    private function applyTimeFilter(Builder $query, int $now): void
    {
        $query->where(function ($q) use ($now) {
            $q->where('fixed', 1)
              ->orWhere(function ($q2) use ($now) {
                  $q2->where(function ($q3) use ($now) {
                      $q3->whereNull('start_at')->orWhere('start_at', '<=', $now);
                  })
                  ->where(function ($q3) use ($now) {
                      $q3->whereNull('end_at')->orWhere('end_at', '>=', $now);
                  });
              });
        });
    }
}

