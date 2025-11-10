<?php

declare(strict_types=1);


namespace Plugin\Ds\Article\Repository;

use App\Repository\IRepository;
use Hyperf\Collection\Arr;
use Hyperf\Collection\Collection;
use Hyperf\Database\Model\Builder;
use Plugin\Ds\Article\Model\Article as Model;
use Plugin\Ds\Article\Model\CategoryCorrelation;

class ArticleRepository extends IRepository
{
    public function __construct(protected readonly Model $model)
    {
    }

    public function handleSearch(Builder $query, array $params): Builder
    {
        if (Arr::has($params, 'status')) {
            if (\is_array($params['status'])) {
                $query->whereIn('status', $params['status']);
            } else {
                $query->where('status', $params['status']);
            }
        }
        if (Arr::has($params, 'category_id')) {
            $in = CategoryCorrelation::query()->where(['category_id' => $params['category_id']])->pluck('data_id');
            $query->whereIn('id', $in);
        }
        if (Arr::has($params, 'created_at')) {
            if (\is_array($params['created_at'])) {
                $query->whereBetween('created_at', $params['created_at']);
            } else {
                $query->where('created_at', $params['created_at']);
            }
        }
        return $query->with(['categories']);
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