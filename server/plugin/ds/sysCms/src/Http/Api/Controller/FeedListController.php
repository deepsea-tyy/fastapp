<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Http\Api\Controller;

use App\Common\AbstractController;
use App\Common\Result;
use App\Common\Swagger\ResultResponse;
use App\Http\CurrentUser;
use App\Service\Feed\FeedCacheService;
use App\Service\Feed\FeedUserFollowService;
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\HyperfServer;
use Hyperf\Swagger\Annotation\QueryParameter;

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
        operationId: 'getFeedList',
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
    #[QueryParameter(name: 'page', description: '页码', example: '1')]
    #[QueryParameter(name: 'page_size', description: '每页数量', example: '20')]
    #[ResultResponse(instance: new Result())]
    public function byTag(): Result
    {
        $page = $this->getPage();
        $pageSize = $this->getPageSize();
        $offset = ($page - 1) * $pageSize;

        // 查询带有该标签的内容
        $posts = \Hyperf\DbConnection\Db::table('feed_content_tag')
            ->join('feed_post', function ($join) {
                $join->on('feed_content_tag.target_id', '=', 'feed_post.id')
                    ->where('feed_content_tag.target_type', '=', 1);
            })
            ->where('feed_content_tag.tag_id', $this->getRequest()->input('tag_id'))
            ->where('feed_post.status', 1)
            ->where('feed_post.audit_status', 1)
            ->orderBy('feed_post.created_at', 'desc')
            ->offset($offset)
            ->limit($pageSize)
            ->select([
                'feed_post.id',
                'feed_post.user_id',
                'feed_post.title',
                'feed_post.content',
                'feed_post.images',
                'feed_post.like_count',
                'feed_post.comment_count',
                'feed_post.created_at',
            ])
            ->get();

        $list = $posts->map(function ($post) {
            return [
                'id' => $post->id,
                'user_id' => $post->user_id,
                'title' => $post->title,
                'content' => $post->content,
                'images' => json_decode($post->images ?? '[]', true),
                'like_count' => $post->like_count,
                'comment_count' => $post->comment_count,
                'created_at' => $post->created_at,
            ];
        })->toArray();

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
        operationId: 'getFollowingFeedList',
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
        if (!$userId) {
            return $this->success();
        }
        // 获取关注用户的帖子
        $posts = $this->followService->getFollowingUserPosts($userId, $page, $pageSize);

        // 批量获取用户动作状态
        foreach ($posts as &$post) {
            $post['is_liked'] = $this->cacheService->getUserLikeStatus($userId, 1, $post['id']);
            $post['is_collected'] = $this->cacheService->getUserCollectStatus($userId, 1, $post['id']);
        }

        return $this->success($posts);
    }

    #[Get(
        path: '/api/feed/list/hot',
        operationId: 'getHotFeedList',
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
        operationId: 'getHotTags',
        summary: '获取热门标签',
        tags: ['信息流-列表']
    )]
    #[QueryParameter(name: 'limit', description: '数量限制', example: '10')]
    #[ResultResponse(instance: new Result())]
    public function hotTags(int $limit = 10): Result
    {
        $tags = $this->cacheService->getHotTags($limit);
        return $this->success(['list' => $tags]);
    }
}
