<?php
/**
 * FastApp.
 * 12/17/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

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
use Plugin\Ds\SysCms\Model\Article;
use Plugin\Ds\SysCms\Model\Category;
use Plugin\Ds\SysCms\Model\FeedCollect;
use Plugin\Ds\SysCms\Model\FeedLike;

#[HyperfServer(name: 'http')]
class FeedArticleController extends AbstractController
{
    public function __construct(
        private readonly CurrentUser           $currentUser,
        private readonly FeedService           $feedService,
        private readonly FeedUserFollowService $followService,
    )
    {
        // 设置为API场景
        $this->currentUser->setScene('api');
    }

    #[Get(
        path: '/api/feed/article/news',
        operationId: 'getArticleNews',
        summary: '获取新闻列表',
        tags: ['信息流-文章']
    )]
    #[QueryParameter(name: 'keyword', description: '搜索关键词', example: '')]
    #[QueryParameter(name: 'page', description: '页码', example: '1')]
    #[QueryParameter(name: 'page_size', description: '每页数量', example: '20')]
    #[ResultResponse(instance: new Result())]
    public function news(): Result
    {
        $page = $this->getPage();
        $pageSize = $this->getPageSize();
        $uid = $this->currentUser->id();
        $keyword = trim($this->getRequest()->input('keyword', ''));

        $list = $this->feedService->getCategoryArticleIds('news', $page, $pageSize, $keyword, $this->getLang());
        // 标记消息已读
        $this->feedService::readMessage($uid, 3);

        return $this->success(['list' => $list]);
    }

    #[Get(
        path: '/api/feed/article/notice',
        operationId: 'getArticleNotice',
        summary: '获取公告列表',
        tags: ['信息流-文章']
    )]
    #[QueryParameter(name: 'keyword', description: '搜索关键词', example: '')]
    #[QueryParameter(name: 'page', description: '页码', example: '1')]
    #[QueryParameter(name: 'page_size', description: '每页数量', example: '20')]
    #[ResultResponse(instance: new Result())]
    public function notice(): Result
    {
        $page = $this->getPage();
        $pageSize = $this->getPageSize();
        $uid = $this->currentUser->id();
        $keyword = trim($this->getRequest()->input('keyword', ''));

        $list = $this->feedService->getCategoryArticleIds('notice', $page, $pageSize, $keyword, $this->getLang());
        // 标记消息已读
        $this->feedService::readMessage($uid, 2);

        return $this->success(['list' => $list]);
    }

    #[Get(
        path: '/api/feed/article/helpManual',
        operationId: 'getArticleHelpManual',
        summary: '获取帮助手册分类列表',
        tags: ['信息流-文章']
    )]
    #[ResultResponse(instance: new Result())]
    public function helpManual(): Result
    {
        $list = Category::query()
            ->select(['id', 'name'])
            ->where(['code' => 'help_manual'])
            ->orderByDesc('sort')->get();
        return $this->success(['list' => $list]);
    }

    #[Get(
        path: '/api/feed/article/categoryList',
        operationId: 'getArticleCategoryList',
        summary: '获取分类文章列表',
        tags: ['信息流-文章']
    )]
    #[QueryParameter(name: 'category_id', description: '分类 id', example: '2')]
    #[ResultResponse(instance: new Result())]
    public function categoryList(): Result
    {
        $categoryId = (int)$this->getRequest()->input('category_id');
        $list = $this->feedService->getArticleIdsByCategoryId($categoryId);

        return $this->success(['list' => $list]);
    }

    #[Get(
        path: '/api/feed/article/list',
        operationId: 'getArticleList',
        summary: '获取文章列表',
        tags: ['信息流-文章']
    )]
    #[QueryParameter(name: 'keyword', description: '搜索关键词', example: '')]
    #[QueryParameter(name: 'page', description: '页码', example: '1')]
    #[QueryParameter(name: 'page_size', description: '每页数量', example: '20')]
    #[ResultResponse(instance: new Result())]
    public function list(): Result
    {
        $page = $this->getPage();
        $pageSize = $this->getPageSize();
        $keyword = trim($this->getRequest()->input('keyword', ''));
        $list = $this->feedService->getArticleSearch($keyword, $page, $pageSize, $this->getLang());
        return $this->success(['list' => $list]);
    }

    #[Get(
        path: '/api/feed/article/detail',
        operationId: 'feedArticleDetail',
        summary: '获取帖子详情',
        tags: ['信息流-帖子']
    )]
    #[QueryParameter(name: 'id', description: '帖子ID', example: '1')]
    #[ResultResponse(instance: new Result())]
    public function detail(): Result
    {
        $id = (int)$this->getRequest()->input('id');
        $article = $this->feedService->getArticle($id, $this->getLang());

        if (!$article) {
            return $this->error();
        }
        $this->feedService->incrementViewCount(2, $id);
        $userId = $this->currentUser->id();
        if ($userId) {
            $map['user_id'] = $userId;
            $article['is_liked'] = FeedLike::query()->where($map)->exists() ? 1 : 0;
            $article['is_collected'] = FeedCollect::query()->where($map)->exists() ? 1 : 0;
            $article['is_following'] = $this->followService->isFollowing($userId, $article['created_by']);
        }
        return $this->success($article);
    }
}