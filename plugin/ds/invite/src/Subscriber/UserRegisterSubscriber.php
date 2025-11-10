<?php

declare(strict_types=1);

namespace Plugin\Ds\Invite\Subscriber;

use App\Common\Event\UserRegisterEvent;
use App\Common\Tools;
use Hyperf\Context\ApplicationContext;
use Hyperf\Engine\Coroutine;
use Hyperf\Event\Annotation\Listener;
use Hyperf\Event\Contract\ListenerInterface;
use Plugin\Ds\Invite\Model\UserRelation;
use Plugin\Ds\Invite\Repository\UserInviteCodeRepository;

#[Listener]
class UserRegisterSubscriber implements ListenerInterface
{
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

        Coroutine::create(static function () use ($event) {
            try {
                $user = $event->getUser();
                
                // 获取用户的邀请码（从 user 对象的 invite_code 属性）
                $inviteCode = $user->invite_code ?? null;
                
                if (empty($inviteCode)) {
                    return;
                }

                // 根据邀请码查找邀请人
                $container = ApplicationContext::getContainer();
                $inviteCodeRepository = $container->get(UserInviteCodeRepository::class);
                
                $inviteCodeModel = $inviteCodeRepository->getQuery()
                    ->where('invite_code', $inviteCode)
                    ->first();

                if (!$inviteCodeModel) {
                    return;
                }

                $parentUserId = $inviteCodeModel->user_id;
                $newUserId = $user->id;

                // 如果邀请人是自己，不建立关系
                if ($parentUserId === $newUserId) {
                    return;
                }

                // 检查是否已经存在关系
                $existingRelation = UserRelation::query()
                    ->where('user_id', $newUserId)
                    ->first();

                if ($existingRelation) {
                    return;
                }

                // 获取父级用户的路径和层级
                $parentRelation = UserRelation::query()
                    ->where('user_id', $parentUserId)
                    ->first();

                if ($parentRelation) {
                    // 父级有上级，新用户的层级是父级层级+1，路径是父级路径+新用户ID+/
                    $level = $parentRelation->level + 1;
                    $path = $parentRelation->path . $newUserId . '/';
                    $parentId = $parentUserId;
                } else {
                    // 父级没有上级，新用户的层级是1，路径是 /父级ID/新用户ID/
                    $level = 1;
                    $path = '/' . $parentUserId . '/' . $newUserId . '/';
                    $parentId = $parentUserId;
                }

                // 建立用户关系
                $data = [
                    'user_id' => $newUserId,
                    'parent_id' => $parentId,
                    'path' => $path,
                    'level' => $level,
                ];
                UserRelation::query()->create($data);
            } catch (\Exception $exception) {
                Tools::logAsync(
                    implode('|', [$exception->getMessage(), $exception->getFile(), json_encode($data)]),
                    'error',
                    'invite'
                );
            }
        });
    }
}

