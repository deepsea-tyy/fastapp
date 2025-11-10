<?php

declare(strict_types=1);


namespace App\Http\Admin\Service\Permission;

use App\Common\IService;
use App\Model\Permission\Department;
use App\Repository\Permission\DepartmentRepository;

/**
 * @extends IService<Department>
 */
final class DepartmentService extends IService
{
    public function __construct(
        protected readonly DepartmentRepository $repository
    ) {}

    /**
     * 获取部门选择
     */
    public function selectDept(): array
    {
        return $this->repository->selectDept();
    }

    /**
     * 获取部门的所有子部门ID（包括自己）
     */
    public function getAllChildrenIds(int $departmentId): array
    {
        return $this->repository->getAllChildrenIds($departmentId);
    }
}
