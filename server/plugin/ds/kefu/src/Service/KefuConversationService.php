<?php

declare(strict_types=1);

namespace Plugin\Ds\Kefu\Service;

use App\Common\IService;
use Plugin\Ds\Kefu\Model\Kefu;
use Plugin\Ds\Kefu\Model\KefuMessage;
use Plugin\Ds\Kefu\Repository\KefuConversationRepository;

/**
 * 客服会话表服务类
 */
final class KefuConversationService extends IService
{

    public function __construct(
        protected readonly KefuConversationRepository $repository,
        protected readonly KefuMessageService         $kefuMessageService,
        protected readonly KefuVisitorService         $visitorService,
    )
    {
    }

    public function message(array $params): array
    {
        $paginate = KefuMessage::query()
            ->where(['conversation_id' => $params['conversation_id']])
            ->orderBy('id', 'desc')
            ->paginate(perPage: (int)$params['page_size'], page: (int)$params['page']);

        return [
            'list' => array_reverse($paginate->items()),
            'total' => $paginate->total(),
        ];
    }

    public function messageVisitor(array $params): array
    {
        return [
            'list' => $this->visitorService->list($params),
        ];
    }

    public function chatTree(int $userId)
    {
        return Kefu::query()->where(['created_by' => $userId])->with(['conversation' => function ($query) {
            $query->with(['profile:user_id,nickname'])->where(['status' => 1]);
        }])->get();
    }
    public function chatVisitorTree(int $userId)
    {
        return Kefu::query()->where(['created_by' => $userId])->with(['visitor'])->get();
    }
}
