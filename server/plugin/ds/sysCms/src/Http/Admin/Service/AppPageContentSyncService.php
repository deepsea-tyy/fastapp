<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Http\Admin\Service;

use App\Common\IService;
use Plugin\Ds\SysCms\Repository\AppPageContentSyncRepository as Repository;

class AppPageContentSyncService extends IService
{
    public function __construct(
        protected readonly Repository $repository
    )
    {
    }

    /**
     * 删除记录并删除对应的文件
     */
    public function deleteById(mixed $id, array $where = []): int
    {
        // 先查询要删除的记录，获取文件路径
        $query = $this->repository->getQuery();
        if ($where) {
            $query->where($where);
        }
        $records = $query->whereKey($id)->get();

        // 删除对应的物理文件
        foreach ($records as $record) {
            if ($record->file_path) {
                $filePath = BASE_PATH . '/' . $record->file_path;
                if (file_exists($filePath)) {
                    @unlink($filePath);
                }
            }
        }

        // 删除数据库记录
        return parent::deleteById($id, $where);
    }
}

