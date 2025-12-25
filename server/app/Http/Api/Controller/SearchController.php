<?php

declare(strict_types=1);

namespace App\Http\Api\Controller;

use App\Common\AbstractController;
use App\Common\Result;
use App\Model\Search\SearchKeyword;
use App\Service\Search\SearchService;
use Hyperf\HttpServer\Annotation\Middleware;
use App\Common\Middleware\TokenMiddleware;
use Hyperf\Swagger\Annotation as OA;
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\Post;
use App\Common\Swagger\ResultResponse;
use OpenApi\Attributes\QueryParameter;
use OpenApi\Attributes\RequestBody;
use OpenApi\Attributes\JsonContent;
use OpenApi\Attributes\Property;
use Hyperf\DbConnection\Db;
use Swoole\Coroutine;

/**
 * 搜索控制器
 *
 * 提供全局搜索、搜索建议、热门关键词等功能
 * 支持搜索文章、信息流、活动等多种内容类型
 *
 * @author FastApp代码生成器
 * @date 2025-12-23 21:43:45
 */
#[OA\Tag('搜索')]
#[OA\HyperfServer('http')]
//#[Middleware(middleware: TokenMiddleware::class)]
class SearchController extends AbstractController
{

    public function __construct(public SearchService $searchService)
    {
    }

    /**
     * 全局搜索接口
     *
     * 支持搜索文章、信息流、活动等多种内容类型
     * 支持按类型筛选、排序、分页
     */
    #[Get(path: '/api/search', operationId: 'search', summary: '全局搜索', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['搜索'])]
    #[QueryParameter(name: 'keyword', description: '搜索关键词', required: true, example: 'BTC')]
    #[QueryParameter(name: 'type', description: '类型筛选: all|article|feed|activity', example: 'all')]
    #[QueryParameter(name: 'page', description: '页码', example: '1')]
    #[QueryParameter(name: 'page_size', description: '每页数量', example: '20')]
    #[ResultResponse(instance: new Result())]
    public function search(): Result
    {
        $keyword = trim($this->getRequest()->input('keyword', ''));

        if (empty($keyword)) {
            return $this->error('搜索关键词不能为空');
        }

        $type = $this->getRequest()->input('type', 'all');
        $sort = $this->getRequest()->input('sort', 'relevance');
        $page = $this->getPage();
        $pageSize = $this->getPageSize();

        Coroutine::create(function () use ($keyword) {
            SearchKeyword::query()->updateOrInsert(
                ['keyword' => $keyword],
                [
                    'keyword' => $keyword,
                    'hit_count' => Db::raw('hit_count + 1'),
                    'last_searched_at' => date('Y-m-d H:i:s'),
                ]
            );
        });

        // 构建搜索选项
        $options = [
            'page' => $page,
            'page_size' => $pageSize,
            'sort' => $sort,
        ];

        // 类型筛选
        if ($type !== 'all') {
            $options['types'] = [$type];
        }

        // 执行搜索
        return $this->success($this->searchService->search($keyword, $options));
    }

    /**
     * 搜索建议接口
     */
    #[Get(path: '/api/search/suggest', operationId: 'search:suggest', summary: '搜索建议', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['搜索'])]
    #[QueryParameter(name: 'keyword', description: '搜索关键词前缀', example: 'BT')]
    #[QueryParameter(name: 'limit', description: '返回数量', example: '10')]
    #[ResultResponse(instance: new Result())]
    public function suggest(): Result
    {
        $keyword = trim($this->getRequest()->input('keyword', ''));

        if (empty($keyword)) {
            return $this->success(['list' => []]);
        }

        $limit = (int)$this->getRequest()->input('limit', 10);

        $suggestions = $this->searchService->suggest($keyword, $limit);

        return $this->success(['list' => $suggestions]);
    }

    /**
     * 搜索排行
     */
    #[Get(path: '/api/search/ranking', operationId: 'search:ranking', summary: '搜索排行榜', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['搜索'])]
    #[ResultResponse(instance: new Result())]
    public function ranking(): Result
    {
        return $this->success(['list' => $this->searchService->ranking()]);
    }

    /**
     * 热门关键词列表
     *
     * 返回热门搜索关键词，用于搜索页面展示
     */
    #[Get(path: '/api/search/keywords/hot', operationId: 'keywords:hot', summary: '热门关键词', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['搜索'])]
    #[QueryParameter(name: 'limit', description: '返回数量', example: '10')]
    #[ResultResponse(instance: new Result())]
    public function hotKeywords(): Result
    {
        $limit = (int)$this->getRequest()->input('limit', 10);

        $list = SearchKeyword::query()
            ->select(['id', 'keyword', 'hit_count', 'icon', 'color', 'sort', 'last_searched_at'])
            ->where('source', '!=', 1) // 排除用户搜索，只显示推荐的
            ->orderByDesc('sort')
            ->orderByDesc('hit_count')
            ->limit($limit)
            ->get()
            ->map(function ($item, $index) {
                // 根据排名和热度添加徽章
                $badge = null;
                if ($index < 3 && $item->hit_count > 100) {
                    $badge = 'HOT';
                } elseif ($item->last_searched_at &&
                    (time() - $item->last_searched_at->getTimestamp()) < 86400) {
                    $badge = 'NEW';
                }

                return [
                    'id' => $item->id,
                    'keyword' => $item->keyword,
                    'hit_count' => $item->hit_count,
                    'icon' => $item->icon,
                    'color' => $item->color,
                    'sort' => $item->sort,
                    'badge' => $badge,
                ];
            });

        return $this->success(['list' => $list]);
    }

    /**
     * 记录搜索结果点击
     */
    #[Post(path: '/api/search/click', operationId: 'search:click', summary: '记录搜索结果点击', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['搜索'])]
    #[RequestBody(content: new JsonContent(required: ['target_type', 'target_id'], properties: [
        new Property(property: 'target_type', description: '内容类型', type: 'string', example: 'article'),
        new Property(property: 'target_id', description: '内容ID', type: 'integer', example: 1)
    ]))]
    #[ResultResponse(instance: new Result())]
    public function click(): Result
    {
        $targetType = $this->getRequest()->input('target_type');
        $targetId = (int)$this->getRequest()->input('target_id');

        if (empty($targetType) || empty($targetId)) {
            return $this->error('参数错误');
        }

        $this->searchService->recordClick($targetType, $targetId);

        return $this->success();
    }
}
