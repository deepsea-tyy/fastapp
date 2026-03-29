<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Http\Admin\Service;

use App\Common\IService;
use Plugin\Ds\SysCms\Model\PlacementPositionContent;
use Plugin\Ds\SysCms\Repository\PlacementContentRepository as Repository;

class PlacementContentService extends IService
{
    public function __construct(
        protected readonly Repository $repository
    )
    {
    }

    public function create(array $data): mixed
    {
        $md = parent::create($data);
        if ($md->wasRecentlyCreated && is_array($data['position_id'])) {
            $this->upRelation($md->id, $data['position_id']);
        }
        return $md;
    }

    public function updateById(mixed $id, array $data): mixed
    {
        $s = parent::updateById($id, $data);
        if ($s && is_array($data['position_id'])) {
            $this->upRelation($id, $data['position_id']);
        }
        return $s;
    }

    private function upRelation(int $cId, array $position_id): void
    {
        PlacementPositionContent::query()->where(['content_id' => $cId])->delete();
        $in = [];
        foreach ($position_id as $pid) {
            $in[] = ['content_id' => $cId, 'position_id' => $pid];
        }
        if ($in) {
            PlacementPositionContent::insert($in);
        }
    }
}
