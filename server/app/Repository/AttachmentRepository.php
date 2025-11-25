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
        return parent::handleSearch($query, $params);
    }
}
