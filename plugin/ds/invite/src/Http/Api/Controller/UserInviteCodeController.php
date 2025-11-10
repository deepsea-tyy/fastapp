<?php

declare(strict_types=1);

namespace Plugin\Ds\Invite\Http\Api\Controller;

use App\Common\AbstractController;
use App\Common\Middleware\TokenMiddleware;
use App\Common\Result;
use App\Common\Swagger\PageResponse;
use App\Common\Swagger\ResultResponse;
use App\Http\CurrentUser;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\Swagger\Annotation\Delete;
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\Post;
use Hyperf\Swagger\Annotation\Put;
use Hyperf\Swagger\Annotation\HyperfServer;
use Hyperf\Swagger\Annotation\RequestBody;
use Hyperf\Swagger\Annotation\JsonContent;
use Hyperf\Swagger\Annotation\QueryParameter;
use Hyperf\Swagger\Annotation as OA;
use Plugin\Ds\Invite\Http\Api\Request\UserInviteCodeRequest as Request;
use Plugin\Ds\Invite\Service\UserInviteCodeService as Service;

#[HyperfServer(name: 'http')]
#[Middleware(middleware: TokenMiddleware::class)]
class UserInviteCodeController extends AbstractController
{
    public function __construct(
        protected readonly Service     $service,
        protected readonly CurrentUser $currentUser
    )
    {
    }

    /**
     * 获取默认邀请码
     */
    #[Get(
        path: '/api/invite/default',
        operationId: 'InviteGetDefault',
        summary: '获取默认邀请码',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['邀请码'],
    )]
    #[ResultResponse(instance: new Result())]
    public function getDefault(): Result
    {
        $userId = $this->currentUser->id();
        $inviteCode = $this->service->getDefaultInviteCode($userId);

        if (!$inviteCode) {
            // 如果不存在，自动创建
            $inviteCode = $this->service->createOrGetDefault($userId);
        }

        return $this->success($inviteCode->toArray(), '获取成功');
    }

    /**
     * 邀请码列表（支持按类型查询）
     */
    #[Get(
        path: '/api/invite/invite-code/list',
        operationId: 'InviteCodeList',
        summary: '邀请码列表',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['邀请码'],
    )]
    #[QueryParameter(name: 'type', description: '类型:1=默认', required: false)]
    #[QueryParameter(name: 'invite_code', description: '邀请码', required: false)]
    #[QueryParameter(name: 'page', description: '页码', required: false)]
    #[QueryParameter(name: 'per_page', description: '每页数量', required: false)]
    #[PageResponse(instance: new Result())]
    public function pageList(): Result
    {
        $params = $this->getRequestData();
        // 默认只查询当前用户的邀请码
        $params['user_id'] = $this->currentUser->id();

        return $this->success(
            $this->service->page(
                $params,
                $this->getCurrentPage(),
                $this->getPageSize()
            )
        );
    }

    /**
     * 创建邀请码
     */
    #[Post(
        path: '/api/invite/invite-code/create',
        operationId: 'InviteCodeCreate',
        summary: '创建邀请码',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['邀请码'],
    )]
    #[RequestBody(
        content: new JsonContent(
            properties: [
                new OA\Property(property: 'type', description: '类型', type: 'integer'),
                new OA\Property(property: 'config', description: '邀请码配置（JSON）', type: 'object'),
            ],
            example: '{"type": 1, "config": {"key": "value"}}'
        )
    )]
    #[ResultResponse(instance: new Result())]
    public function create(Request $request): Result
    {
        $data = $request->validated();
        $data['user_id'] = $this->currentUser->id();
        $data['invite_code'] = $this->service->generateInviteCode();
        $this->service->create($data);
        return $this->success(null, '创建成功');
    }

    /**
     * 更新邀请码
     */
    #[Put(
        path: '/api/invite/invite-code/save/{id}',
        operationId: 'InviteCodeSave',
        summary: '更新邀请码',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['邀请码'],
    )]
    #[RequestBody(
        content: new JsonContent(
            properties: [
                new OA\Property(property: 'id', description: '邀请码ID', type: 'integer'),
                new OA\Property(property: 'config', description: '邀请码配置（JSON）', type: 'object'),
            ],
            example: '{"id": 1, "config": {"key": "value"}}'
        )
    )]
    #[ResultResponse(instance: new Result())]
    public function save(int $id, Request $request): Result
    {
        // 验证是否属于当前用户
        $inviteCode = $this->service->findById($id);
        if (!$inviteCode || $inviteCode->user_id !== $this->currentUser->id()) {
            return $this->error('邀请码不存在或无权限');
        }

        // 只允许更新config字段
        $data = $request->validated();
        $this->service->updateById($id, ['config' => $data['config'] ?? null]);
        return $this->success(null, '更新成功');
    }

    /**
     * 删除邀请码（支持单个或批量删除）
     */
    #[Delete(
        path: '/api/invite/invite-code/delete',
        operationId: 'InviteCodeDelete',
        summary: '删除邀请码',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['邀请码'],
    )]
    #[RequestBody(
        content: new JsonContent(
            type: 'array',
            items: new OA\Items(type: 'integer'),
            example: '[1, 2, 3]'
        )
    )]
    #[ResultResponse(instance: new Result())]
    public function delete(): Result
    {
        $userId = $this->currentUser->id();
        $this->service->deleteById($this->getRequestData(), ['user_id' => $userId]);
        return $this->success(null, '删除成功');
    }
}

