<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Repository;

use Plugin\Ds\SysCms\Model\AppPageContentSync as Model;
use App\Repository\IRepository;

class AppPageContentSyncRepository extends IRepository
{
    public function __construct(protected readonly Model $model)
    {
    }
}

