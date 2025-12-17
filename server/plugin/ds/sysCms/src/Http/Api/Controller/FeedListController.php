<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Http\Api\Controller;

use App\Common\AbstractController;
use App\Common\Result;
use App\Common\Swagger\ResultResponse;
use App\Http\CurrentUser;
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\HyperfServer;
use Hyperf\Swagger\Annotation\QueryParameter;
use Plugin\Ds\SysCms\Http\Api\Service\FeedCacheService;
use Plugin\Ds\SysCms\Http\Api\Service\FeedUserFollowService;
use Plugin\Ds\SysCms\Http\Api\Service\FeedService;

/**
 * 信息流列表API控制器
 */
#[HyperfServer(name: 'http')]
class FeedListController extends AbstractController
{
    public function __construct(
        private readonly FeedCacheService      $cacheService,
        private readonly FeedUserFollowService $followService,
        private readonly CurrentUser           $currentUser
    )
    {
        // 设置为API场景
        $this->currentUser->setScene('api');
    }

    #[Get(
        path: '/api/feed/list',
        operationId: 'feedFeedList',
        summary: '获取信息流列表',
        tags: ['信息流-列表']
    )]
    #[QueryParameter(name: 'filter', description: '筛选条件：latest最新 hot热门', example: 'latest')]
    #[QueryParameter(name: 'page', description: '页码', example: '1')]
    #[QueryParameter(name: 'page_size', description: '每页数量', example: '20')]
    #[ResultResponse(instance: new Result())]
    public function getList(string $filter = 'latest'): Result
    {
        $page = $this->getPage();
        $pageSize = $this->getPageSize();

        // 获取列表（自动使用缓存）
        $list = $this->cacheService->getFeedList($filter, $page, $pageSize);

        // 如果用户已登录，批量获取用户动作状态
        $userId = $this->currentUser->id();
        if ($userId) {
            foreach ($list as &$item) {
                $item['is_liked'] = $this->cacheService->getUserLikeStatus($userId, 1, $item['id']);
                $item['is_collected'] = $this->cacheService->getUserCollectStatus($userId, 1, $item['id']);
            }
        }
        return $this->success(['list' => $list]);
    }

    #[Get(
        path: '/api/feed/list/byTag',
        operationId: 'feedListByTag',
        summary: '获取指定标签的信息流',
        tags: ['信息流-列表']
    )]
    #[QueryParameter(name: 'tag_id', description: '标签ID', required: true, example: '1')]
    #[QueryParameter(name: 'page', description: '页码', example: '1')]
    #[QueryParameter(name: 'page_size', description: '每页数量', example: '20')]
    #[ResultResponse(instance: new Result())]
    public function byTag(): Result
    {
        $page = $this->getPage();
        $pageSize = $this->getPageSize();
        $offset = ($page - 1) * $pageSize;
        $tagId = (int)$this->getRequest()->input('tag_id');

        // 获取带有该标签的帖子ID列表
        $postIds = \Hyperf\DbConnection\Db::table('feed_content_tag')
            ->where('tag_id', $tagId)
            ->where('target_type', 1)
            ->orderByDesc('target_id')
            ->offset($offset)
            ->limit($pageSize)
            ->pluck('target_id')
            ->toArray();

        if (empty($postIds)) {
            return $this->success(['list' => []]);
        }

        // 使用模型查询以便加载关联和自动处理JSON字段
        $posts = \Plugin\Ds\SysCms\Model\FeedPost::query()
            ->with(['profile:user_id,nickname,avatar'])
            ->whereIn('id', $postIds)
            ->where('status', 1)
            ->where('audit_status', 1)
            ->get()
            ->keyBy('id');

        // 按照原始顺序组装结果
        $list = [];
        foreach ($postIds as $postId) {
            $post = $posts->get($postId);
            if ($post) {
                $list[] = [
                    'type' => 'post',
                    'id' => $post->id,
                    'profile' => $post->profile,
                    'user_id' => $post->user_id,
                    'title' => $post->title ?? '',
                    'content' => $post->content ?? '',
                    'images' => $post->images ?? [],
                    'like_count' => $post->like_count ?? 0,
                    'comment_count' => $post->comment_count ?? 0,
                    'created_at' => $post->created_at->toDateTimeString(),
                ];
            }
        }

        // 如果用户已登录，批量获取用户动作状态
        $userId = $this->currentUser->id();
        if ($userId) {
            foreach ($list as &$item) {
                $item['is_liked'] = $this->cacheService->getUserLikeStatus($userId, 1, $item['id']);
                $item['is_collected'] = $this->cacheService->getUserCollectStatus($userId, 1, $item['id']);
            }
        }

        return $this->success(['list' => $list]);
    }

    #[Get(
        path: '/api/feed/list/byFollowing',
        operationId: 'feedFollowingFeedList',
        summary: '获取关注用户的信息流',
        tags: ['信息流-列表']
    )]
    #[QueryParameter(name: 'page', description: '页码', example: '1')]
    #[QueryParameter(name: 'page_size', description: '每页数量', example: '20')]
    #[ResultResponse(instance: new Result())]
    public function byFollowing(): Result
    {
        $page = $this->getPage();
        $pageSize = $this->getPageSize();

        $userId = $this->currentUser->id();
        $posts = $this->followService->getFollowingUserPosts($userId, $page, $pageSize);

        // 批量获取用户动作状态
        foreach ($posts as &$post) {
            $post['is_liked'] = $this->cacheService->getUserLikeStatus($userId, 1, $post['id']);
            $post['is_collected'] = $this->cacheService->getUserCollectStatus($userId, 1, $post['id']);
        }
        FeedService::readMessage($userId, 1);
        return $this->success(['list' => $posts]);
    }

    #[Get(
        path: '/api/feed/list/hot',
        operationId: 'feedHotFeedList',
        summary: '获取热门信息流',
        tags: ['信息流-列表']
    )]
    #[QueryParameter(name: 'page', description: '页码', example: '1')]
    #[QueryParameter(name: 'page_size', description: '每页数量', example: '20')]
    #[ResultResponse(instance: new Result())]
    public function hot(): Result
    {
        return $this->getList('hot');
    }

    #[Get(
        path: '/api/feed/tags/hot',
        operationId: 'feedHotTags',
        summary: '获取热门标签',
        tags: ['信息流-列表']
    )]
    #[QueryParameter(name: 'limit', description: '数量限制', example: '10')]
    #[ResultResponse(instance: new Result())]
    public function hotTags(): Result
    {
        $tags = $this->cacheService->getHotTags((int)$this->getRequest()->input('limit', 10));
        return $this->success(['list' => $tags]);
    }

    #[Get(
        path: '/api/feed/mayInterested',
        operationId: 'feedMayInterested',
        summary: '可能感兴趣的人',
        tags: ['信息流-列表']
    )]
    #[QueryParameter(name: 'page', description: '页码', example: '1')]
    #[QueryParameter(name: 'page_size', description: '每页数量', example: '20')]
    #[ResultResponse(instance: new Result())]
    public function mayInterested(): Result
    {
        return $this->success(['list' => (new FeedUserFollowService())->mayInterestedList($this->getPage(), $this->getPageSize(), $this->currentUser->id())]);
    }
}
