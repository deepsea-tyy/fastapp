<?php

declare(strict_types=1);


namespace App\Http;

use App\Http\Admin\Service\Permission\MenuService;
use App\Http\Admin\Service\Permission\UserService;
use App\Model\Enums\User\Status;
use App\Model\User;
use Hyperf\Context\RequestContext;
use Lcobucci\JWT\Token\RegisteredClaims;
use Lcobucci\JWT\UnencryptedToken;

final class CurrentUser
{
    public function __construct(
        private readonly PassportService $service,
        private readonly UserService     $userService,
        private readonly MenuService     $menuService
    )
    {
    }

    public function adminUser(): ?User
    {
        return $this->userService->getInfo($this->id());
    }

    public function user(): ?User
    {
        return $this->service->getInfo($this->id());
    }

    public function refresh(): array
    {
        return $this->service->refreshToken($this->getToken());
    }

    public function isSuperAdmin(): bool
    {
        return $this->adminUser()->isSuperAdmin();
    }

    public function getToken(): ?UnencryptedToken
    {
        return RequestContext::get()->getAttribute('token');
    }


    public function id(): int
    {
        return (int)$this->getToken()->claims()->get(RegisteredClaims::ID);
    }

    public function filterCurrentUser(): array
    {
        $permissions = $this->adminUser()
            ->getPermissions()
            ->pluck('name')
            ->unique();
        $menuList = $permissions->isEmpty()
            ? []
            : $this->menuService
                ->getList(['status' => Status::Normal, 'name' => $permissions->toArray()])
                ->toArray();
        $tree = [];
        $map = [];
        foreach ($menuList as &$menu) {
            $menu['children'] = [];
            $map[$menu['id']] = &$menu;
        }
        unset($menu);
        foreach ($menuList as &$menu) {
            $pid = $menu['parent_id'];
            if ($pid === 0 || !isset($map[$pid])) {
                $tree[] = &$menu;
            } else {
                $map[$pid]['children'][] = &$menu;
            }
        }
        unset($menu);
        return $tree;
    }
}
