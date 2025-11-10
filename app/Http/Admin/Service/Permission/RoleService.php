<?php

declare(strict_types=1);


namespace App\Http\Admin\Service\Permission;

use App\Common\IService;
use App\Model\Permission\Role;
use App\Repository\Permission\MenuRepository;
use App\Repository\Permission\RoleRepository;
use Hyperf\Collection\Collection;

/**
 * @extends IService<Role>
 */
final class RoleService extends IService
{
    public function __construct(
        protected readonly RoleRepository $repository,
        protected readonly MenuRepository $menuRepository
    ) {}

    public function getRolePermission(int $id): Collection
    {
        return $this->repository->findById($id)->menus()->get();
    }

    public function batchGrantPermissionsForRole(int $id, array $permissionsCode): void
    {
        if (\count($permissionsCode) === 0) {
            $this->repository->findById($id)->menus()->detach();
            return;
        }
        $this->repository->findById($id)
            ->menus()
            ->sync(
                $this->menuRepository
                    ->list([
                        'code' => $permissionsCode,
                    ])
                    ->map(static fn ($item) => $item->id)
                    ->toArray()
            );
    }

    public function getRoleDepartments(int $id): Collection
    {
        return $this->repository->findById($id)->departments()->get();
    }

    public function batchGrantDepartmentsForRole(int $id, array $departmentIds): void
    {
        if (\count($departmentIds) === 0) {
            $this->repository->findById($id)->departments()->detach();
            return;
        }
        $this->repository->findById($id)->departments()->sync($departmentIds);
    }
}
