<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Http\Admin\Controller;

use App\Http\Admin\Controller\AbstractController;
use App\Common\Result;
use App\Http\CurrentUser;
use Plugin\Ds\Ex\Http\Admin\Request\ExKycRequest as Request;
use Plugin\Ds\Ex\Http\Admin\Service\ExKycService as Service;
use Hyperf\HttpServer\Annotation\Middleware;
use App\Http\Admin\Permission;
use App\Http\Admin\Middleware\PermissionMiddleware;
use App\Common\Middleware\AccessTokenMiddleware;
use App\Common\Middleware\OperationMiddleware;
use Hyperf\HttpServer\Annotation\Controller;
use Hyperf\HttpServer\Annotation\GetMapping;
use Hyperf\HttpServer\Annotation\PostMapping;
use Hyperf\HttpServer\Annotation\PutMapping;
use Hyperf\HttpServer\Annotation\DeleteMapping;


/**
 * KYC认证申请控制器
 *
 * @author FastApp代码生成器
 * @date 2025-12-13 08:53:50
 */
#[Controller]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
class ExKycController extends AbstractController
{
    public function __construct(
        private readonly Service     $service,
        private readonly CurrentUser $currentUser
    )
    {
    }

    #[GetMapping(path: '/admin/ds/ex/ex_kyc/list')]
    #[Permission(code: 'ds:ex:ex_kyc:list')]
    public function pageList(): Result
    {
        return $this->success(
            $this->service->page(
                array_merge($this->getRequestData(), [
                    'created_by' => $this->currentUser->id(),
                ]),
                $this->getPage(),
                $this->getPageSize()
            )
        );
    }

    #[PostMapping(path: '/admin/ds/ex/ex_kyc/create')]
    #[Permission(code: 'ds:ex:ex_kyc:create')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function create(Request $request): Result
    {
        $this->service->create(array_merge($this->getRequestData(), [
            'created_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[PutMapping(path: '/admin/ds/ex/ex_kyc/save/{id}')]
    #[Permission(code: 'ds:ex:ex_kyc:save')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function save(int $id, Request $request): Result
    {
        $this->service->updateById($id, array_merge($this->getRequestData(), [
            'updated_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[DeleteMapping(path: '/admin/ds/ex/ex_kyc/delete')]
    #[Permission(code: 'ds:ex:ex_kyc:delete')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function delete(): Result
    {
        $this->service->deleteById($this->getRequestData(), []);
        return $this->success();
    }

    #[PutMapping(path: '/admin/ds/ex/ex_kyc/approve/{id}')]
    #[Permission(code: 'ds:ex:ex_kyc:approve')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function approve(int $id): Result
    {
        $request = $this->getRequest();
        // 获取真实 IP 地址（考虑代理情况）
        $ipAddress = $request->getHeaderLine('x-forwarded-for') 
            ?: $request->getHeaderLine('x-real-ip') 
            ?: ($request->getServerParams()['remote_addr'] ?? '0.0.0.0');
        // 如果是多个 IP，取第一个
        if (strpos($ipAddress, ',') !== false) {
            $ipAddress = trim(explode(',', $ipAddress)[0]);
        }
        $userAgent = $request->getHeaderLine('user-agent') ?: '';
        
        $this->service->approve(
            $id,
            $this->currentUser->id(),
            $ipAddress,
            $userAgent
        );
        return $this->success();
    }

    #[PutMapping(path: '/admin/ds/ex/ex_kyc/reject/{id}')]
    #[Permission(code: 'ds:ex:ex_kyc:reject')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function reject(int $id): Result
    {
        $request = $this->getRequest();
        $reason = $request->input('remark', '');
        
        if (empty($reason)) {
            return $this->error('拒绝原因不能为空');
        }
        
        // 获取真实 IP 地址（考虑代理情况）
        $ipAddress = $request->getHeaderLine('x-forwarded-for') 
            ?: $request->getHeaderLine('x-real-ip') 
            ?: ($request->getServerParams()['remote_addr'] ?? '0.0.0.0');
        // 如果是多个 IP，取第一个
        if (strpos($ipAddress, ',') !== false) {
            $ipAddress = trim(explode(',', $ipAddress)[0]);
        }
        $userAgent = $request->getHeaderLine('user-agent') ?: '';
        
        $this->service->reject(
            $id,
            $reason,
            $this->currentUser->id(),
            $ipAddress,
            $userAgent
        );
        return $this->success();
    }
}
