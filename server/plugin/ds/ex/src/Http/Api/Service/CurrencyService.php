<?php

declare(strict_types=1);
namespace Plugin\Ds\Ex\Http\Api\Service;

use App\Common\IService;
use Plugin\Ds\Ex\Repository\CurrencyRepository as Repository;

class CurrencyService extends IService
{
    public function __construct(
        protected readonly Repository $repository
    ) {}
}
