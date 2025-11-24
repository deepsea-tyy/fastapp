<?php

declare(strict_types=1);

namespace Plugin\Ds\Kefu\Repository;

use App\Repository\IRepository;
use Hyperf\Collection\Arr;
use Hyperf\Database\Model\Builder;
use Plugin\Ds\Kefu\Model\KefuConversation as Model;

/**
 * 客服会话表 Repository类
 */
class KefuConversationRepository extends IRepository
{
    public function __construct(
        protected readonly Model $model
    ) {
    }

    public function handleSearch(Builder $query, array $params): Builder
    {
        $query->with(['profile:user_id,avatar,nickname', 'kefu:id,avatar,nickname']);
        return parent::handleSearch($query, $params);
    }
}
