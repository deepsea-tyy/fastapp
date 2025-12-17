<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Http\Admin\Service;

use App\Common\IService;
use App\Common\Tools;
use App\Model\User;
use Plugin\Ds\SysCms\Repository\CategoryRepository as Repository;
use Plugin\Ds\SysConfig\Helper\CacheConfigHelper;


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

    public function selectCreator(): array
    {
        $in = [];
        foreach (CacheConfigHelper::getConfigByGroupKey('feed_config')->pluck('value') as $value) {
            $in = array_merge($in, explode(',', $value));
        }
        return User::query()->whereIn('id', $in)->get()->map(function ($item) {
            return [
                'label' => implode('|', array_filter([$item->id, $item->email, $item->mobile, $item->remark])),
                'value' => $item->id
            ];
        })->toArray();
    }
}
