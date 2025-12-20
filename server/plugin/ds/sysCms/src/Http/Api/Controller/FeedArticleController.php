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
use Plugin\Ds\SysCms\Model\Category;

#[HyperfServer(name: 'http')]
class FeedArticleController extends AbstractController
{
    public function __construct(
        private readonly CurrentUser $currentUser,
        private readonly FeedService $feedService,
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
    #[QueryParameter(name: 'page', description: '页码', example: '1')]
    #[QueryParameter(name: 'page_size', description: '每页数量', example: '20')]
    #[ResultResponse(instance: new Result())]
    public function news(): Result
    {
        $page = $this->getPage();
        $pageSize = $this->getPageSize();
        $uid = $this->currentUser->id();

        // 从缓存获取文章ID列表
        $articleIds = $this->feedService->getCategoryArticleIds('news', $page, $pageSize);

        // 批量获取格式化后的文章（带缓存）
        $list = $this->feedService->batchGetArticlesFormatted($articleIds, $uid);

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
    #[QueryParameter(name: 'page', description: '页码', example: '1')]
    #[QueryParameter(name: 'page_size', description: '每页数量', example: '20')]
    #[ResultResponse(instance: new Result())]
    public function notice(): Result
    {
        $page = $this->getPage();
        $pageSize = $this->getPageSize();
        $uid = $this->currentUser->id();

        // 从缓存获取文章ID列表
        $articleIds = $this->feedService->getCategoryArticleIds('notice', $page, $pageSize);

        // 批量获取格式化后的文章（带缓存）
        $list = $this->feedService->batchGetArticlesFormatted($articleIds, $uid);

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
        $uid = $this->currentUser->id();

        // 从缓存获取文章ID列表
        $articleIds = $this->feedService->getArticleIdsByCategoryId($categoryId);

        // 批量获取格式化后的文章（带缓存）
        $list = $this->feedService->batchGetArticlesFormatted($articleIds, $uid);

        return $this->success(['list' => $list]);
    }
}