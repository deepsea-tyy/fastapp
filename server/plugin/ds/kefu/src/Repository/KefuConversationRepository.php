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

    /**
     * 搜索处理器
     * @param Builder $query
     * @param array $params
     * @return Builder
     */
    public function handleSearch(Builder $query, array $params): Builder
    {
        if (isset($params['kefu_id'])) {
            $query->where('kefu_id', '=', $params['kefu_id']);
        }

        if (isset($params['user_id'])) {
            $query->where('user_id', '=', $params['user_id']);
        }

        if (isset($params['status'])) {
            $query->where('status', '=', $params['status']);
        }

        return $query->with(['profile:user_id,avatar,nickname', 'kefu:id,avatar,nickname']);
    }
}
