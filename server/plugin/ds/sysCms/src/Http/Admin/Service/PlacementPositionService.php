<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Http\Admin\Service;

use App\Common\IService;
use Plugin\Ds\SysCms\Repository\PlacementPositionRepository as Repository;

class PlacementPositionService extends IService
{
    public function __construct(
        protected readonly Repository $repository
    )
    {
    }


    public function selectPlacementPosition()
    {
        return $this->repository->getQuery()->get(['id', 'name', 'code'])->map(function ($item) {
            return ['label' => implode('|', [$item->name, $item->code]), 'value' => $item->id];
        });
    }
}
