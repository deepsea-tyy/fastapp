<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Repository;

use Plugin\Ds\Ex\Model\MarketPair as Model;
use App\Repository\IRepository;

class MarketPairRepository extends IRepository
{
    public function __construct(protected readonly Model $model)
    {
    }

}
