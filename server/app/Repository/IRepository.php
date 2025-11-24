<?php

declare(strict_types=1);


namespace App\Repository;

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
    use HasContainer;

    public const PER_PAGE_PARAM_NAME = 'per_page';
    
    private const SKIP_PARAMS = ['page', 'per_page', 'order_by', 'order_by_direction', 'order', 'sort'];
    private const INTEGER_TYPES = ['integer', 'int', 'bigint', 'smallint', 'tinyint', 'mediumint'];
    private const FLOAT_TYPES = ['float', 'double', 'decimal', 'numeric'];
    private const DATETIME_TYPES = ['datetime', 'timestamp'];
    private const JSON_TYPES = ['json', 'jsonb'];
    private const BOOLEAN_TYPES = ['boolean', 'bool', 'bit'];

    public function handleSearch(Builder $query, array $params): Builder
    {
        $tableColumns = $this->getTableColumns();
        $casts = $this->model->getCasts();
        
        foreach ($params as $key => $value) {
            if (in_array($key, self::SKIP_PARAMS, true) 
                || !isset($tableColumns[$key]) 
                || ($value === null || $value === '')) {
                continue;
            }
            
            $this->applyWhereByType(
                $query, 
                $key, 
                $value, 
                $casts[$key] ?? null, 
                $tableColumns[$key]['type'] ?? null
            );
        }
        
        return $query;
    }
    
    protected function getTableColumns(): array
    {
        static $cache = [];
        $tableName = $this->model->getTable();
        
        if (isset($cache[$tableName])) {
            return $cache[$tableName];
        }
        
        try {
            $tableDetails = $this->model->getConnection()
                ->getDoctrineSchemaManager()
                ->listTableDetails($tableName);
            
            foreach ($tableDetails->getColumns() as $column) {
                $cache[$tableName][$column->getName()] = [
                    'type' => $column->getType()->getName(),
                ];
            }
        } catch (\Exception $e) {
            foreach ($this->model->getFillable() as $field) {
                $cache[$tableName][$field] = ['type' => null];
            }
        }
        
        return $cache[$tableName];
    }
    
    protected function applyWhereByType(Builder $query, string $field, mixed $value, ?string $castType, ?string $dbType = null): void
    {
        $type = $dbType ?? $this->normalizeCastType($castType) ?? 'string';
        
        // 日期时间类型且值为数组时，使用范围查询
        if (is_array($value) && (in_array($type, self::DATETIME_TYPES, true) || $type === 'date')) {
            $this->handleDateRangeWhere($query, $field, $value);
            return;
        }
        
        if (is_array($value)) {
            $query->whereIn($field, $value);
            return;
        }
        
        match (true) {
            in_array($type, self::INTEGER_TYPES, true) => $query->where($field, (int)$value),
            in_array($type, self::FLOAT_TYPES, true) => $query->where($field, (float)$value),
            in_array($type, self::DATETIME_TYPES, true) || $type === 'date' => $this->handleDateRangeWhere($query, $field, $value),
            in_array($type, self::JSON_TYPES, true) || $type === 'array' => $query->whereJsonContains($field, $value),
            in_array($type, self::BOOLEAN_TYPES, true) => $query->where($field, (bool)$value),
            default => $query->where($field, 'like', "%{$value}%"),
        };
    }
    
    private function normalizeCastType(?string $castType): ?string
    {
        return match (true) {
            $castType === null => null,
            str_contains($castType, 'int') => 'integer',
            str_contains($castType, 'float') || str_contains($castType, 'decimal') => 'float',
            str_contains($castType, 'datetime') || str_contains($castType, 'timestamp') => 'datetime',
            str_contains($castType, 'date') => 'date',
            str_contains($castType, 'json') || str_contains($castType, 'array') => 'json',
            str_contains($castType, 'bool') => 'boolean',
            default => 'string',
        };
    }
    
    protected function handleDateRangeWhere(Builder $query, string $field, mixed $value): void
    {
        if (is_array($value) && count($value) === 2) {
            $query->whereBetween($field, [
                $value[0] . ' 00:00:00',
                $value[1] . ' 23:59:59',
            ]);
        } elseif (is_string($value) && preg_match('/^(.+?)[~-](.+)$/', $value, $matches)) {
            $query->whereBetween($field, [
                trim($matches[1]) . ' 00:00:00',
                trim($matches[2]) . ' 23:59:59',
            ]);
        } else {
            $query->where($field, $value);
        }
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
        return $model && $model->fill($data)->save() ? $model : null;
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
        return $this->handleSearch($this->handleOrderBy($query, $params), $params);
    }
    
    public function handleOrderBy(Builder $query, array $params): Builder
    {
        if ($this->enablePageOrderBy()) {
            $query->orderBy(
                $params[$this->getOrderByParamName()] ?? $query->getModel()->getKeyName(),
                $params[$this->getOrderByDirectionParamName()] ?? 'desc'
            );
        }
        return $query;
    }
    
    protected function enablePageOrderBy(): bool
    {
        return true;
    }
    
    protected function getOrderByParamName(): string
    {
        return 'order_by';
    }
    
    protected function getOrderByDirectionParamName(): string
    {
        return 'order_by_direction';
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
