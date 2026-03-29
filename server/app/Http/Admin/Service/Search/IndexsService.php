<?php

declare(strict_types=1);
namespace App\Http\Admin\Service\Search;

use App\Common\IService;
use App\Repository\Search\IndexsRepository as Repository;

class IndexsService extends IService
{
    public function __construct(
        protected readonly Repository $repository
    ) {}
}
