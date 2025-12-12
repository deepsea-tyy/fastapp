<?php

declare(strict_types=1);


namespace App\Common\Subscriber;

use App\Common\Event\RequestOperationEvent;
use App\Common\Event\UserAdminLoginEvent;
use App\Common\Event\UserAccountEvent;
use App\Common\Event\UserRegisterEvent;
use App\Common\Service\IpLocationService;
use App\Common\Tools;
use App\Http\Admin\Service\Logstash\UserAdminLoginLogService;
use App\Http\Admin\Service\Logstash\UserAdminOperationLogService;
use App\Http\Admin\Service\Permission\AdminUserService;
use App\Model\UserAccountLog;
use Hyperf\Engine\Coroutine;
use Hyperf\Event\Annotation\Listener;
use Hyperf\Event\Contract\ListenerInterface;

#[Listener]
class UserSubscriber implements ListenerInterface
{
    public function __construct(
        private readonly UserAdminLoginLogService     $adminLoginLogService,
        private readonly UserAdminOperationLogService $logService,
        private readonly AdminUserService             $userService,
        private readonly IpLocationService            $ipLocationService
    )
    {
    }

    public function listen(): array
    {
        return [
            UserAccountEvent::class,
            UserRegisterEvent::class,
            UserAdminLoginEvent::class,
            RequestOperationEvent::class,
        ];
    }

    public function process(object $event): void
    {
        Coroutine::create(function () use ($event) {
            try {
                if ($event instanceof UserAccountEvent) {
                    $user = $event->getUser();
                    if (\Hyperf\Config\config('env') == 'prod') $res = $this->ipLocationService->query($event->getIp(), Tools::lang($user->id, true));
                    $res['user_id'] = $user->id;
                    $res['ip'] = $event->getIp();
                    $res['os'] = $event->getOs(); // 操作系统
                    $res['device_id'] = $event->getDeviceId();
                    $res['type'] = $event->getType();
                    UserAccountLog::create($res);
                } else if ($event instanceof RequestOperationEvent) {
                    $userId = $event->getUserId();
                    $user = $this->userService->findById($userId);
                    if (empty($user)) {
                        return;
                    }
                    $this->logService->save([
                        'username' => $user->username,
                        'method' => $event->getMethod(),
                        'router' => $event->getPath(),
                        'ip' => $event->getIp(),
                        'service_name' => $event->getOperation(),
                        'request_params' => $event->getRequestParams(),
                    ]);
                } else if ($event instanceof UserAdminLoginEvent) {
                    $user = $event->getUser();
                    $this->adminLoginLogService->save([
                        'username' => $user->username,
                        'ip' => $event->getIp(),
                        'os' => $event->getOs(),
                        'browser' => $event->getBrowser(),
                        'status' => $event->isLogin() ? 1 : 2,
                    ]);
                }
            } catch (\Exception $exception) {
                Tools::logAsync(implode('|', [$exception->getMessage(), $exception->getFile(), $exception->getLine()]), 'error', 'event');
            }
        });
    }
}
