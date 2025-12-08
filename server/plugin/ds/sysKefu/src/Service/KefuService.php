<?php

declare(strict_types=1);

namespace Plugin\Ds\SysKefu\Service;

use App\Common\IService;
use Plugin\Ds\SysKefu\Repository\KefuRepository;

class KefuService extends IService
{
    public function __construct(
        protected readonly KefuRepository $repository
    ) {
    }
}
