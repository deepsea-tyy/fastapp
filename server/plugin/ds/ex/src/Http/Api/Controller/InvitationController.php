<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Http\Api\Controller;

use App\Common\AbstractController;
use App\Common\Middleware\TokenMiddleware;
use App\Common\Result;
use App\Common\Swagger\ResultResponse;
use App\Http\CurrentUser;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\Swagger\Annotation\{Get, Post, Put, Delete, HyperfServer, QueryParameter, RequestBody, JsonContent};
use Hyperf\Swagger\Annotation as OA;
use Plugin\Ds\Ex\Http\Api\Service\InvitationService as Service;

/**
 * 邀请返佣API控制器
 */
#[HyperfServer(name: 'http')]
class InvitationController extends AbstractController
{
    public function __construct(
        protected readonly Service $service,
        protected readonly CurrentUser $currentUser
    ) {}

    #[Get(path: '/api/ex/invitation/info', operationId: 'ExInvitationInfo', summary: '获取邀请信息', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['交易所邀请'])]
    #[ResultResponse(instance: new Result())]
    #[Middleware(middleware: TokenMiddleware::class)]
    public function info(): Result
    {
        $uid = $this->currentUser->id();
        $data = $this->service->getInvitationInfo($uid);
        return $this->success($data);
    }

    #[Get(path: '/api/ex/invitation/list', operationId: 'ExInvitationList', summary: '邀请列表', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['交易所邀请'])]
    #[QueryParameter(name: 'status', description: '状态筛选', required: false)]
    #[QueryParameter(name: 'page', description: '页码', required: false, example: '1')]
    #[QueryParameter(name: 'limit', description: '每页数量', required: false, example: '20')]
    #[ResultResponse(instance: new Result())]
    #[Middleware(middleware: TokenMiddleware::class)]
    public function list(): Result
    {
        $params = $this->getRequestData();
        $uid = $this->currentUser->id();
        $status = isset($params['status']) ? (int)$params['status'] : null;
        $page = (int)($params['page'] ?? 1);
        $limit = (int)($params['limit'] ?? 20);

        $data = $this->service->getInvitationList($uid, $status, $page, $limit);
        return $this->success($data);
    }

    #[Get(path: '/api/ex/invitation/commission-logs', operationId: 'ExCommissionLogs', summary: '返佣记录', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['交易所邀请'])]
    #[QueryParameter(name: 'start_date', description: '开始日期', required: false)]
    #[QueryParameter(name: 'end_date', description: '结束日期', required: false)]
    #[QueryParameter(name: 'page', description: '页码', required: false, example: '1')]
    #[QueryParameter(name: 'limit', description: '每页数量', required: false, example: '20')]
    #[ResultResponse(instance: new Result())]
    #[Middleware(middleware: TokenMiddleware::class)]
    public function commissionLogs(): Result
    {
        $params = $this->getRequestData();
        $uid = $this->currentUser->id();
        $startDate = $params['start_date'] ?? null;
        $endDate = $params['end_date'] ?? null;
        $page = (int)($params['page'] ?? 1);
        $limit = (int)($params['limit'] ?? 20);

        $data = $this->service->getCommissionLogs($uid, $startDate, $endDate, $page, $limit);
        return $this->success($data);
    }

    // ========== 邀请码管理接口 ==========

    #[Get(path: '/api/ex/invitation/code/default', operationId: 'ExInviteCodeDefault', summary: '获取默认邀请码', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['交易所邀请'])]
    #[ResultResponse(instance: new Result())]
    #[Middleware(middleware: TokenMiddleware::class)]
    public function getDefaultCode(): Result
    {
        $uid = $this->currentUser->id();
        $inviteCode = $this->service->getDefaultInviteCode($uid);

        if (!$inviteCode) {
            // 如果不存在，自动创建
            $inviteCode = $this->service->createOrGetDefault($uid);
        }

        return $this->success($inviteCode->toArray());
    }

    #[Get(path: '/api/ex/invitation/code/list', operationId: 'ExInviteCodeList', summary: '邀请码列表', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['交易所邀请'])]
    #[QueryParameter(name: 'type', description: '类型:1=默认', required: false)]
    #[QueryParameter(name: 'invite_code', description: '邀请码', required: false)]
    #[QueryParameter(name: 'page', description: '页码', required: false, example: '1')]
    #[QueryParameter(name: 'per_page', description: '每页数量', required: false, example: '20')]
    #[ResultResponse(instance: new Result())]
    #[Middleware(middleware: TokenMiddleware::class)]
    public function codeList(): Result
    {
        $params = $this->getRequestData();
        $uid = $this->currentUser->id();
        $type = isset($params['type']) ? (int)$params['type'] : null;
        $code = $params['invite_code'] ?? null;
        $page = (int)($params['page'] ?? 1);
        $perPage = (int)($params['per_page'] ?? 20);

        $data = $this->service->getInviteCodePage($uid, $type, $code, $page, $perPage);
        return $this->success($data);
    }

    #[Post(path: '/api/ex/invitation/code/create', operationId: 'ExInviteCodeCreate', summary: '创建邀请码', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['交易所邀请'])]
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
    #[Middleware(middleware: TokenMiddleware::class)]
    public function createCode(): Result
    {
        $params = $this->getRequestData();
        $uid = $this->currentUser->id();

        $data = [
            'uid' => $uid,
            'type' => (int)($params['type'] ?? 1),
            'invite_code' => $this->service->generateUniqueInviteCode(),
            'config' => $params['config'] ?? null,
        ];

        $this->service->createInviteCode($data);
        return $this->success(null, '创建成功');
    }

    #[Put(path: '/api/ex/invitation/code/update', operationId: 'ExInviteCodeUpdate', summary: '更新邀请码', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['交易所邀请'])]
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
    #[Middleware(middleware: TokenMiddleware::class)]
    public function updateCode(): Result
    {
        $params = $this->getRequestData();
        $id = (int)($params['id'] ?? 0);
        $uid = $this->currentUser->id();

        // 验证是否属于当前用户
        $inviteCode = $this->service->findInviteCodeById($id);
        if (!$inviteCode || $inviteCode->uid !== $uid) {
            return $this->error('邀请码不存在或无权限');
        }

        // 只允许更新config字段
        $this->service->updateInviteCodeById($id, ['config' => $params['config'] ?? null]);
        return $this->success(null, '更新成功');
    }

    #[Delete(path: '/api/ex/invitation/code/delete', operationId: 'ExInviteCodeDelete', summary: '删除邀请码', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['交易所邀请'])]
    #[RequestBody(
        content: new JsonContent(
            type: 'array',
            items: new OA\Items(type: 'integer'),
            example: '[1, 2, 3]'
        )
    )]
    #[ResultResponse(instance: new Result())]
    #[Middleware(middleware: TokenMiddleware::class)]
    public function deleteCode(): Result
    {
        $ids = $this->getRequestData();
        $uid = $this->currentUser->id();

        if (!is_array($ids) || empty($ids)) {
            return $this->error('请提供要删除的邀请码ID');
        }

        $this->service->deleteInviteCodes($ids, $uid);
        return $this->success(null, '删除成功');
    }
}
