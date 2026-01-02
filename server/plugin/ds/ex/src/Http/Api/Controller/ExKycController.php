<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Http\Api\Controller;

use App\Common\AbstractController;
use App\Common\Middleware\TokenMiddleware;
use App\Common\Result;
use App\Common\Swagger\ResultResponse;
use App\Http\CurrentUser;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\Swagger\Annotation\{Get, Post, HyperfServer};
use Plugin\Ds\Ex\Http\Api\Request\ExKycRequest as Request;
use Plugin\Ds\Ex\Http\Api\Service\ExKycService as Service;

#[HyperfServer(name: 'http')]
#[Middleware(middleware: TokenMiddleware::class)]
class ExKycController extends AbstractController
{
    public function __construct(
        protected readonly Service $service,
        protected readonly CurrentUser $currentUser
    ) {}

    #[Post(path: '/api/ex/kyc/submit', operationId: 'ExKycSubmit', summary: '提交KYC认证申请', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['KYC认证'])]
    #[ResultResponse(instance: new Result())]
    public function submit(Request $request): Result
    {
        $kyc = $this->service->submit([...$request->validated(), 'user_id' => $this->currentUser->id()]);
        return $this->success($kyc, '提交成功');
    }

    #[Get(path: '/api/ex/kyc/detail', operationId: 'ExKycDetail', summary: '获取KYC详情', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['KYC认证'])]
    #[ResultResponse(instance: new Result())]
    public function detail(): Result
    {
        return $this->success($this->service->getUserKyc($this->currentUser->id()));
    }
}

