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
use Plugin\Ds\SysCms\Http\Api\Service\FeedService;
use Plugin\Ds\SysCms\Http\Api\Service\FeedUserFollowService;
use Plugin\Ds\SysCms\Http\Api\Service\FeedImpressionService;
use Swoole\Coroutine;

/**
 * 信息流列表API控制器
 */
#[HyperfServer(name: 'http')]
class FeedListController extends AbstractController
{
    public function __construct(
        private readonly FeedService           $cacheService,
        private readonly FeedUserFollowService $followService,
        private readonly FeedImpressionService $impressionService,
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
    #[QueryParameter(name: 'keyword', description: '搜索关键词', example: '')]
    #[QueryParameter(name: 'page', description: '页码', example: '1')]
    #[QueryParameter(name: 'page_size', description: '每页数量', example: '20')]
    #[ResultResponse(instance: new Result())]
    public function list(string $filter = 'latest'): Result
    {
        $page = $this->getPage();
        $pageSize = $this->getPageSize();
        $userId = $this->currentUser->id();
        $keyword = trim($this->getRequest()->input('keyword', ''));

        // 判断是否需要去重（推荐Feed需要去重）
        // 如果有keyword，则不去重
        $needDedup = in_array($filter, ['latest', 'hot']) && empty($keyword);

        if ($needDedup && $userId) {
            // 直接获取已去重的数据（SQL层面过滤）
            $list = $this->impressionService->getDeduplicatedFeed($userId, $filter, $page, $pageSize);

            // 如果去重后没数据，降级为不去重（确保有内容显示）
            if ($list->isEmpty()) {
                $list = collect($this->cacheService->getFeedList($filter, $page, $pageSize, $keyword));
            } else {
                // 异步记录曝光
                Coroutine::create(function () use ($list, $userId) {
                    $this->impressionService->recordImpressions(
                        $userId,
                        $list->pluck('id')->toArray(),
                        FeedImpressionService::CONTENT_TYPE_POST,
                        FeedImpressionService::FEED_TYPE_RECOMMEND
                    );
                });
            }

            // 格式化数据
            $list = $list->map(function ($item) {
                return FeedService::formatPost($item);
            });
        } else {
            // 不需要去重或用户未登录，直接获取列表
            $list = collect($this->cacheService->getFeedList($filter, $page, $pageSize, $keyword));
        }

        // 如果用户已登录，批量获取用户动作状态
        if ($userId && $list->isNotEmpty()) {
            // 转换为数组便于处理
            $listArray = $list->toArray();

            // 按 type 分组帖子ID
            $postIdsByType = [];
            foreach ($listArray as $item) {
                $postIdsByType[$item['type']][] = $item['id'];
            }

            // 批量查询点赞状态（按type分组查询）
            $allLikeStatuses = [];
            foreach ($postIdsByType as $type => $postIds) {
                $allLikeStatuses[$type] = $this->cacheService->batchGetUserLikeStatus($userId, $type, $postIds);
            }

            // 将状态添加到列表中
            foreach ($listArray as &$item) {
                $item['is_liked'] = in_array($item['id'], $allLikeStatuses[$item['type']]) ? 1 : 0;
            }

            return $this->success(['list' => $listArray]);
        }

        return $this->success(['list' => $list->toArray()]);
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
                $list[] = FeedService::formatPost($post);
            }
        }

        // 如果用户已登录，批量获取用户动作状态
        $userId = $this->currentUser->id();
        if ($userId && !empty($list)) {
            // 按 type 分组帖子ID
            $postIdsByType = [];
            foreach ($list as $item) {
                $type = $item['type'] ?? 1;
                $postIdsByType[$type][] = $item['id'];
            }

            // 批量查询点赞状态（按type分组查询）
            $allLikeStatuses = [];
            foreach ($postIdsByType as $type => $postIds) {
                $likeStatuses = $this->cacheService->batchGetUserLikeStatus($userId, $type, $postIds);
                foreach ($likeStatuses as $postId) {
                    $allLikeStatuses[$postId] = true;
                }
            }

            // 将状态添加到列表中
            foreach ($list as &$item) {
                $item['is_liked'] = isset($allLikeStatuses[$item['id']]) ? 1 : 0;
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

        // 如果有数据，批量获取用户动作状态
        if (!empty($posts)) {
            // 按 type 分组帖子ID
            $postIdsByType = [];
            foreach ($posts as $post) {
                $type = $post['type'] ?? 1;
                $postIdsByType[$type][] = $post['id'];
            }

            // 批量查询点赞状态（按type分组查询）
            $allLikeStatuses = [];
            foreach ($postIdsByType as $type => $postIds) {
                $likeStatuses = $this->cacheService->batchGetUserLikeStatus($userId, $type, $postIds);
                foreach ($likeStatuses as $postId) {
                    $allLikeStatuses[$postId] = true;
                }
            }

            // 将状态添加到列表中
            foreach ($posts as &$post) {
                $post['is_liked'] = isset($allLikeStatuses[$post['id']]) ? 1 : 0;
            }
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
        return $this->list('hot');
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
