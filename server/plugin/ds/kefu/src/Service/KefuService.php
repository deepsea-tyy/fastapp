<?php

declare(strict_types=1);

namespace Plugin\Ds\Kefu\Service;

use App\Common\IService;
use Plugin\Ds\Kefu\Repository\KefuRepository;

class KefuService extends IService
{
    public function __construct(
        protected readonly KefuRepository $repository
    ) {
    }
}
