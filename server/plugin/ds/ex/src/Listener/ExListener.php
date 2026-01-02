<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Listener;

use App\Common\Event\UserRegisterEvent;
use App\Common\Tools;
use Hyperf\Engine\Coroutine;
use Hyperf\Event\Annotation\Listener;
use Hyperf\Event\Contract\ListenerInterface;
use Plugin\Ds\Ex\Http\Api\Service\InvitationService;

#[Listener]
class ExListener implements ListenerInterface
{
    public function __construct(
        protected readonly InvitationService $invitationService
    ) {}

    public function listen(): array
    {
        return [
            UserRegisterEvent::class,
        ];
    }

    public function process(object $event): void
    {
        if (!$event instanceof UserRegisterEvent) {
            return;
        }

        Coroutine::create(function () use ($event) {
            try {
                $user = $event->getUser();
                $newUserId = $user->id;

                // 检查是否有邀请码
                if (empty($event->inviteCode)) {
                    return;
                }

                // 根据邀请码查找邀请人
                $inviteCodeModel = $this->invitationService->findByInviteCode($event->inviteCode);

                if (!$inviteCodeModel) {
                    return;
                }

                $parentUserId = $inviteCodeModel->uid;

                // 如果邀请人是自己，不建立关系
                if ($parentUserId === $newUserId) {
                    return;
                }

                // 建立用户关系
                $this->invitationService->createUserRelation($newUserId, $parentUserId);

                // 同时记录到 ex_user_invitations 表（保持与原有系统兼容）
                $this->invitationService->recordInvitation($parentUserId, $newUserId, $event->inviteCode);

            } catch (\Exception $exception) {
                Tools::logAsync(
                    implode('|', [$exception->getMessage(), $exception->getFile(), $exception->getLine()]),
                    'error',
                    'ex_invite'
                );
            }
        });
    }
}
