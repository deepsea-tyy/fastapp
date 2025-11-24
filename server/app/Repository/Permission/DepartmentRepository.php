<?php

declare(strict_types=1);


namespace App\Repository\Permission;

use App\Model\Permission\Department;
use App\Repository\IRepository;
use Hyperf\Collection\Arr;
use Hyperf\Database\Model\Builder;

final class DepartmentRepository extends IRepository
{
    public function __construct(
        protected readonly Department $model
    )
    {
    }

    public function handleSearch(Builder $query, array $params): Builder
    {
        $query->with(['children' => function ($query) {
            $query->where('status', 1)->orderByDesc('sort');
        }])->where('parent_id', 0);
        return parent::handleSearch($query, $params);
    }

    public function selectDept(): array
    {
        $query = $this->getQuery()->with(['children' => function ($query) {
            $query->where('status', 1)->orderByDesc('sort');
        }]);
        $departments = $query->where(['parent_id' => 0, 'status' => 1])->orderBy('sort')->get();
        $data = [];
        foreach ($departments as $item) {
            $l1Name = $item->name;
            $data[] = ['label' => $l1Name, 'value' => $item->id];
            foreach ($item->children as $child) {
                $l2Name = $child->name;
                $data[] = ['label' => "$l1Name/$l2Name", 'value' => $child->id];
            }
        }
        return $data;
    }


    /**
     * 获取部门的所有子部门ID（包括自己）
     * 优化版：使用一次查询 + 内存递归，减少数据库访问
     */
    public function getAllChildrenIds(int $departmentId): array
    {
        $department = $this->findById($departmentId);
        if (!$department) {
            return [];
        }

        // 一次性查询所有部门，避免递归查询数据库
        $allDepartments = $this->getQuery()->get()->keyBy('id');
        if (!$allDepartments->has($departmentId)) {
            return [];
        }

        return $this->getChildrenIdsRecursive($departmentId, $allDepartments);
    }

    /**
     * 递归获取子部门ID（内存操作，不查询数据库）
     */
    private function getChildrenIdsRecursive(int $deptId, $allDepartments): array
    {
        $ids = [$deptId];
        foreach ($allDepartments as $dept) {
            if ($dept->parent_id == $deptId) {
                $ids = array_merge($ids, $this->getChildrenIdsRecursive($dept->id, $allDepartments));
            }
        }
        return $ids;
    }
}
