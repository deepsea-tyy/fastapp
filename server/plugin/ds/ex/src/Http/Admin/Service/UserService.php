<?php

declare(strict_types=1);
namespace Plugin\Ds\Ex\Http\Admin\Service;

use App\Common\IService;
use Plugin\Ds\Ex\Repository\UserRepository as Repository;

class UserService extends IService
{
    public function __construct(
        protected readonly Repository $repository
    ) {}
}
