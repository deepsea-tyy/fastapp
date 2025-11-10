<?php

declare(strict_types=1);


namespace App\Repository;

use App\Repository\Traits\BootTrait;
use App\Repository\Traits\RepositoryOrderByTrait;
use Hyperf\Collection\Collection;
use Hyperf\Contract\LengthAwarePaginatorInterface;
use Hyperf\Database\Model\Builder;
use Hyperf\DbConnection\Model\Model;
use Hyperf\DbConnection\Traits\HasContainer;
use Hyperf\Paginator\AbstractPaginator;

/**
 * @template T of Model
 * @property T $model
 */
abstract class IRepository
{
    use BootTrait;
    use HasContainer;
    use RepositoryOrderByTrait;

    public const PER_PAGE_PARAM_NAME = 'per_page';

    public function handleSearch(Builder $query, array $params): Builder
    {
        return $query;
    }

    public function handleItems(Collection $items): Collection
    {
        return $items;
    }

    public function handlePage(LengthAwarePaginatorInterface $paginator): array
    {
        $items = $paginator instanceof AbstractPaginator
            ? $paginator->getCollection()
            : Collection::make($paginator->items());

        return [
            'list' => $this->handleItems($items)->toArray(),
            'total' => $paginator->total(),
        ];
    }

    public function list(array $params = []): Collection
    {
        return $this->handleItems($this->perQuery($this->getQuery(), $params)->get());
    }

    public function count(array $params = []): int
    {
        return $this->perQuery($this->getQuery(), $params)->count();
    }

    public function page(array $params = [], ?int $page = null, ?int $pageSize = null): array
    {
        $result = $this->perQuery($this->getQuery(), $params)->paginate(
            perPage: $pageSize,
            pageName: static::PER_PAGE_PARAM_NAME,
            page: $page,
        );
        return $this->handlePage($result);
    }

    public function create(array $data): mixed
    {
        return $this->getQuery()->create($data);
    }

    public function updateById(mixed $id, array $data): bool
    {
        return (bool)$this->getQuery()->whereKey($id)->first()?->update($data);
    }

    public function saveById(mixed $id, array $data): mixed
    {
        $model = $this->getQuery()->whereKey($id)->first();
        if ($model) {
            $model->fill($data)->save();
            return $model;
        }
        return null;
    }

    public function deleteById(mixed $id, array $where = []): int
    {
        if ($where) {
            return (int)$this->getQuery()->where($where)->whereKey($id)->delete();
        }
        return $this->model::destroy($id);
    }

    public function forceDeleteById(mixed $id, array $where = []): bool
    {
        $query = $this->getQuery();
        if ($where) {
            $query->where($where);
        }
        return (bool)$query->whereKey($id)->forceDelete();
    }

    public function findById(mixed $id): mixed
    {
        return $this->getQuery()->whereKey($id)->first();
    }

    public function fvById(mixed $id, string $field): mixed
    {
        return $this->getQuery()->whereKey($id)->value($field);
    }

    public function findByFilter(array $params): mixed
    {
        return $this->perQuery($this->getQuery(), $params)->first();
    }

    public function perQuery(Builder $query, array $params): Builder
    {
        $this->startBoot($query, $params);
        return $this->handleSearch($query, $params);
    }

    public function getQuery(): Builder
    {
        return $this->model->newQuery();
    }

    public function existsById(mixed $id): bool
    {
        return $this->getQuery()->whereKey($id)->exists();
    }

    public function getModel()
    {
        return $this->model;
    }
}
