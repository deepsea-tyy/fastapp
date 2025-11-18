<?php

declare(strict_types=1);

namespace Plugin\Ds\Article\Service;

use App\Common\IService;
use App\Common\Tools;
use Plugin\Ds\Article\Repository\CategoryRepository as Repository;


class CategoryService extends IService
{
    public function __construct(
        protected readonly Repository $repository
    )
    {
    }

    public function selectCategory(array $params = []): array
    {
        $res = $this->repository->getQuery()->with(['children'])->where(['parent_id' => 0])->get();
        $data = [];
        foreach ($res as $item) {
            $l1Name = Tools::formatLang($item->name);
            $data[] = ['label' => $l1Name, 'value' => $item->id];
            foreach ($item->children as $child) {
                $l2Name = Tools::formatLang($child->name);
                $data[] = ['label' => "$l1Name/$l2Name", 'value' => $child->id];
            }
        }
        return $data;
    }
}
