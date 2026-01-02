<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Http\Api\Controller;

use App\Common\AbstractController;
use App\Common\Middleware\TokenMiddleware;
use App\Common\Result;
use App\Common\Swagger\ResultResponse;
use App\Http\CurrentUser;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\Swagger\Annotation\{Get, Post, HyperfServer, QueryParameter};
use Plugin\Ds\Ex\Http\Api\Service\SignInService as Service;

/**
 * 签到API控制器
 */
#[HyperfServer(name: 'http')]
class SignInController extends AbstractController
{
    public function __construct(
        protected readonly Service $service,
        protected readonly CurrentUser $currentUser
    ) {}

    #[Post(path: '/api/ex/sign-in', operationId: 'ExSignIn', summary: '每日签到', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['交易所签到'])]
    #[ResultResponse(instance: new Result())]
    #[Middleware(middleware: TokenMiddleware::class)]
    public function signIn(): Result
    {
        $uid = $this->currentUser->id();
        $result = $this->service->signIn($uid);

        return $result['success'] ? $this->success($result['data']) : $this->error($result['message']);
    }

    #[Get(path: '/api/ex/sign-in/history', operationId: 'ExSignInHistory', summary: '获取签到历史', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['交易所签到'])]
    #[QueryParameter(name: 'month', description: '月份（格式：YYYY-MM）', required: false)]
    #[ResultResponse(instance: new Result())]
    #[Middleware(middleware: TokenMiddleware::class)]
    public function history(): Result
    {
        $params = $this->getRequestData();
        $month = $params['month'] ?? null;
        $uid = $this->currentUser->id();

        $data = $this->service->getSignInHistory($uid, $month);
        return $this->success($data);
    }

    #[Get(path: '/api/ex/sign-in/status', operationId: 'ExSignInStatus', summary: '获取签到状态', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['交易所签到'])]
    #[ResultResponse(instance: new Result())]
    #[Middleware(middleware: TokenMiddleware::class)]
    public function status(): Result
    {
        $uid = $this->currentUser->id();
        $hasSignedToday = $this->service->hasSignedInToday($uid);

        return $this->success(['has_signed_today' => $hasSignedToday]);
    }
}
