<?php

declare(strict_types=1);

namespace Plugin\Ds\Kefu\Http\Api;

use App\Common\AbstractController;
use App\Common\Middleware\TokenMiddleware;
use App\Common\Result;
use App\Common\Swagger\ResultResponse;
use App\Http\CurrentUser;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\HyperfServer;
use Hyperf\Swagger\Annotation\QueryParameter;
use Hyperf\HttpServer\Contract\RequestInterface;
use Plugin\Ds\Kefu\Service\KefuMessageService;

#[HyperfServer(name: 'http')]
final class KefuMessageController extends AbstractController
{
    public function __construct(
        private readonly KefuMessageService $service,
        private readonly CurrentUser        $currentUser
    )
    {
    }

    /**
     * 获取消息列表
     */
    #[Get(
        path: '/api/kefu/message/list',
        operationId: 'ApiKefuMessageList',
        summary: '获取消息列表',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['客服消息'],
    )]
    #[QueryParameter(name: 'conversation_id', description: '会话ID', required: true, example: '1')]
    #[QueryParameter(name: 'page', description: '页码', example: '1')]
    #[QueryParameter(name: 'page_size', description: '每页数量', example: '20')]
    #[ResultResponse(instance: new Result(), example: '{"code":200,"message":"成功","data":[{"id":1,"conversation_id":1,"sender_id":100,"sender_type":1,"content":"你好","message_type":1,"file_url":null,"is_read":0,"read_at":null,"created_at":"2025-01-01 10:00:00"}]}')]
    #[Middleware(middleware: TokenMiddleware::class, priority: 100)]
    public function list(RequestInterface $request): Result
    {
        return $this->success($this->service->list(array_merge(
            $request->all(),
            ['user_id' => $this->currentUser->id()]
        )));
    }

    /**
     * 获取或创建会话
     */
    #[Get(
        path: '/api/kefu/message/getConversation',
        operationId: 'ApiKefuMessageGetConversation',
        summary: '获取或创建会话',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['客服消息'],
    )]
    #[ResultResponse(instance: new Result(), example: '{"code":200,"message":"成功","data":{"id":1,"kefu_id":1,"user_id":100,"status":1,"last_message_at":null,"unread_count":0,"kefu_unread_count":0,"created_at":"2025-01-01 10:00:00"}}')]
    #[Middleware(middleware: TokenMiddleware::class, priority: 100)]
    public function getConversation(): Result
    {
        return $this->success(
            $this->service->getConversation($this->currentUser->id())
        );
    }

    /**
     * 获取访客客服
     */
    #[Get(
        path: '/api/kefu/message/getVisitorKefu',
        operationId: 'ApiKefuMessageGetConversation',
        summary: '获取或创建会话',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['客服消息'],
    )]
    #[ResultResponse(instance: new Result(), example: '{"code":200,"message":"成功","data":{"kefu_id":1,"visitor_id":"xxx"}}')]
    public function getVisitorKefu(): Result
    {
        return $this->success(
            $this->service->getVisitorKefu()
        );
    }
}
