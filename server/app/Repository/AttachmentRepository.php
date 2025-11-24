<?php

declare(strict_types=1);


namespace App\Repository;

use App\Model\Attachment;
use Hyperf\Collection\Arr;
use Hyperf\Database\Model\Builder;

/**
 * @extends IRepository<Attachment>
 */
final class AttachmentRepository extends IRepository
{
    public function __construct(
        protected readonly Attachment $model
    ) {}

    public function findByHash(string $hash): ?Attachment
    {
        return $this->model->newQuery()->where('hash', $hash)->first();
    }

    public function handleSearch(Builder $query, array $params): Builder
    {
        if (Arr::has($params, 'suffix')) {
            $query->whereIn('suffix', Arr::wrap($params['suffix']));
            unset($params['suffix']);
        }
        
        if (Arr::has($params, 'mime_type')) {
            $query->whereIn('mime_type', Arr::wrap($params['mime_type']));
            unset($params['mime_type']);
        }
        
        if (Arr::has($params, 'storage_mode')) {
            $query->whereIn('storage_mode', Arr::wrap($params['storage_mode']));
            unset($params['storage_mode']);
        }
        
        return parent::handleSearch($query, $params);
    }
}
