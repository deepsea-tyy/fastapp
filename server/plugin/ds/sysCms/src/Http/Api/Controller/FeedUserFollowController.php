<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Http\Api\Controller;

use App\Common\AbstractController;
use App\Common\Result;
use App\Http\CurrentUser;
use App\Service\Feed\FeedUserFollowService;
use Hyperf\HttpServer\Annotation\Controller;
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\Post;
use Hyperf\Swagger\Annotation\HyperfServer;
use Hyperf\Swagger\Annotation\PathParameter;
use Hyperf\Swagger\Annotation\QueryParameter;
use Hyperf\Swagger\Annotation\JsonContent;
use Hyperf\Swagger\Annotation\RequestBody;

/**
 * 用户关注API控制器
 */
#[HyperfServer(name: 'http')]
#[Controller(prefix: '/api/feed/user')]
class FeedUserFollowController extends AbstractController
{
    public function __construct(
        private readonly FeedUserFollowService $followService,
        private readonly CurrentUser $currentUser
    ) {
        // 设置为API场景
        $this->currentUser->setScene('api');
    }

    #[Post(
        path: '/follow-toggle',
        operationId: 'toggleUserFollow',
        summary: '切换关注状态',
        tags: ['信息流-用户关注']
    )]
    #[RequestBody(content: new JsonContent(
        required: ['follow_user_id'],
        properties: [
            'follow_user_id' => ['type' => 'integer', 'description' => '被关注用户ID', 'example' => 1],
        ]
    ))]
    public function toggleFollow(): Result
    {
        $userId = $this->currentUser->id();
        if (!$userId) {
            return $this->error('请先登录', 401);
        }

        $data = $this->getRequestData();
        $followUserId = (int)$data['follow_user_id'];

        try {
            $isFollowing = $this->followService->toggleFollow($userId, $followUserId);

            return $this->success([
                'is_following' => $isFollowing,
                'message' => $isFollowing ? '关注成功' : '已取消关注'
            ]);
        } catch (\InvalidArgumentException $e) {
            return $this->error($e->getMessage(), 400);
        }
    }

    #[Get(
        path: '/my-following',
        operationId: 'getUserFollowingList',
        summary: '获取关注列表',
        tags: ['信息流-用户关注']
    )]
    #[QueryParameter(name: 'page', description: '页码', example: '1')]
    #[QueryParameter(name: 'page_size', description: '每页数量', example: '20')]
    public function getFollowing(): Result
    {
        $page = $this->getPage();
        $pageSize = $this->getPageSize();

        $userId = $this->currentUser->id();
        if (!$userId) {
            return $this->error('请先登录', 401);
        }

        $followUserIds = $this->followService->getFollowingList($userId, $page, $pageSize);

        // TODO: 批量获取用户信息
        $list = [];
        foreach ($followUserIds as $followUserId) {
            $list[] = [
                'user_id' => $followUserId,
                // TODO: 添加用户详细信息
            ];
        }

        return $this->success($list);
    }

    #[Get(
        path: '/my-followers',
        operationId: 'getUserFollowersList',
        summary: '获取粉丝列表',
        tags: ['信息流-用户关注']
    )]
    #[QueryParameter(name: 'page', description: '页码', example: '1')]
    #[QueryParameter(name: 'page_size', description: '每页数量', example: '20')]
    public function getFollowers(): Result
    {
        $page = $this->getPage();
        $pageSize = $this->getPageSize();

        $userId = $this->currentUser->id();
        if (!$userId) {
            return $this->error('请先登录', 401);
        }

        $followerUserIds = $this->followService->getFollowersList($userId, $page, $pageSize);

        // 批量检查是否互相关注
        $mutualFollowing = $this->followService->batchCheckFollowing($userId, $followerUserIds);

        // TODO: 批量获取用户信息
        $list = [];
        foreach ($followerUserIds as $followerUserId) {
            $list[] = [
                'user_id' => $followerUserId,
                'is_mutual' => $mutualFollowing[$followerUserId] ?? false, // 是否互相关注
                // TODO: 添加用户详细信息
            ];
        }

        return $this->success($list);
    }

    #[Get(
        path: '/stats/{userId}',
        operationId: 'getUserFollowStats',
        summary: '获取用户关注统计',
        tags: ['信息流-用户关注']
    )]
    #[PathParameter(name: 'userId', description: '用户ID', example: '1')]
    public function stats(int $userId): Result
    {
        $followingCount = $this->followService->getFollowingCount($userId);
        $followersCount = $this->followService->getFollowersCount($userId);

        return $this->success([
            'following_count' => $followingCount,  // 关注数
            'followers_count' => $followersCount,  // 粉丝数
        ]);
    }

    #[Get(
        path: '/follow/status/{followUserId}',
        operationId: 'checkUserFollowStatus',
        summary: '检查是否关注某用户',
        tags: ['信息流-用户关注']
    )]
    #[PathParameter(name: 'followUserId', description: '被关注用户ID', example: '1')]
    public function checkStatus(int $followUserId): Result
    {
        $userId = $this->currentUser->id();
        if (!$userId) {
            return $this->error('请先登录', 401);
        }

        $isFollowing = $this->followService->isFollowing($userId, $followUserId);

        return $this->success([
            'is_following' => $isFollowing
        ]);
    }
}
