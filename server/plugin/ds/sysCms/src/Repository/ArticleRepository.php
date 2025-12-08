<?php

declare(strict_types=1);


namespace Plugin\Ds\SysCms\Repository;

use App\Repository\IRepository;
use Hyperf\Collection\Arr;
use Hyperf\Collection\Collection;
use Hyperf\Database\Model\Builder;
use Plugin\Ds\SysCms\Model\Article as Model;
use Plugin\Ds\SysCms\Model\CategoryCorrelation;

class ArticleRepository extends IRepository
{
    public function __construct(protected readonly Model $model)
    {
    }

    public function handleSearch(Builder $query, array $params): Builder
    {
        if (Arr::has($params, 'category_id')) {
            $in = CategoryCorrelation::query()->where(['category_id' => $params['category_id']])->pluck('data_id');
            $query->whereIn('id', $in);
            unset($params['category_id']);
        }
        $query->with(['categories']);
        return parent::handleSearch($query, $params);
    }

    public function handleItems(Collection $items): Collection
    {
        foreach ($items as $item) {
            $item->category_id = collect($item->categories)->pluck('id')->toArray();
        }
        return parent::handleItems($items);
    }

    public function create(array $data): mixed
    {
        $categoryIds = $data['category_id'] ?? [];
        unset($data['category_id']);
        $md = parent::create($data);
        $this->syncCategories($md->id, $categoryIds);
        return $md;
    }

    public function updateById(mixed $id, array $data): bool
    {
        $s = parent::updateById($id, $data);
        if ($s) {
            $this->syncCategories($id, $data['category_id'] ?? []);
        }
        return $s;
    }

    public function deleteById(mixed $id, array $where = []): int
    {
        $this->deleteCategoryRelations($id);

        return parent::deleteById($id);
    }

    /**
     * 同步分类关联
     */
    private function syncCategories(int $articleId, array $categoryIds): void
    {
        $this->deleteCategoryRelations($articleId);

        if (!empty($categoryIds)) {
            $insertData = [];
            foreach ($categoryIds as $categoryId) {
                $insertData[] = [
                    'category_id' => $categoryId,
                    'data_id' => $articleId,
                    'type' => 1
                ];
            }
            CategoryCorrelation::query()->insert($insertData);
        }
    }

    /**
     * 删除分类关联
     */
    private function deleteCategoryRelations(int $articleId): void
    {
        CategoryCorrelation::query()
            ->where('data_id', $articleId)
            ->where('type', 1)
            ->delete();
    }
}