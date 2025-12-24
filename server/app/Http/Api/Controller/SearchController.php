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
use App\Common\Swagger\ResultResponse;
use OpenApi\Attributes\QueryParameter;
use Hyperf\DbConnection\Db;

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
#[Middleware(middleware: TokenMiddleware::class)]
class SearchController extends AbstractController
{
    /**
     * 全局搜索接口
     *
     * 支持搜索文章、信息流、活动等多种内容类型
     * 支持按类型筛选、排序、分页
     */
    #[Get(path: '/api/search', operationId: 'search', summary: '全局搜索', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['搜索'])]
    #[QueryParameter(name: 'keyword', description: '搜索关键词', required: true, example: 'BTC')]
    #[QueryParameter(name: 'type', description: '类型筛选: all|article|feed|activity', example: 'all')]
    #[QueryParameter(name: 'sort', description: '排序方式: relevance|time|weight|hot', example: 'relevance')]
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

        // 记录搜索关键词
        $this->recordKeyword($keyword);

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
        $searchService = new SearchService();
        $result = $searchService->search($keyword, $options);

        return $this->success([
            'list' => $result['list'],
            'total' => $result['total'],
            'page' => $result['page'],
            'page_size' => $result['page_size'],
            'took' => $result['took'],
            'driver' => $searchService->getDriverName(),
        ]);
    }

    /**
     * 搜索建议接口
     *
     * 根据用户输入前缀，返回搜索建议
     */
    #[Get(path: '/api/search/suggest', operationId: 'search:suggest', summary: '搜索建议', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['搜索'])]
    #[QueryParameter(name: 'keyword', description: '搜索关键词前缀', required: true, example: 'BT')]
    #[QueryParameter(name: 'limit', description: '返回数量', example: '10')]
    #[ResultResponse(instance: new Result())]
    public function suggest(): Result
    {
        $keyword = trim($this->getRequest()->input('keyword', ''));

        if (empty($keyword)) {
            return $this->success(['list' => []]);
        }

        $limit = (int)$this->getRequest()->input('limit', 10);

        $searchService = new SearchService();
        $suggestions = $searchService->suggest($keyword, $limit);

        return $this->success(['list' => $suggestions]);
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
            ->select(['keyword', 'hit_count', 'icon', 'color'])
            ->where('source', '!=', 1) // 排除用户搜索，只显示推荐的
            ->orderByDesc('sort')
            ->orderByDesc('hit_count')
            ->limit($limit)
            ->get();

        return $this->success(['list' => $list]);
    }

    /**
     * 搜索历史记录
     *
     * 返回当前用户的搜索历史
     */
    #[Get(path: '/api/search/history', operationId: 'search:history', summary: '搜索历史', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['搜索'])]
    #[QueryParameter(name: 'limit', description: '返回数量', example: '10')]
    #[ResultResponse(instance: new Result())]
    public function history(): Result
    {
        $limit = (int)$this->getRequest()->input('limit', 10);

        // TODO: 这里应该从用户的搜索历史表中获取
        // 目前先返回用户搜索过的关键词
        $list = SearchKeyword::query()
            ->select(['keyword', 'last_searched_at'])
            ->where('source', 1) // 用户搜索
            ->orderByDesc('last_searched_at')
            ->limit($limit)
            ->get();

        return $this->success(['list' => $list]);
    }

    /**
     * 关键词列表（兼容旧接口）
     */
    #[Get(path: '/api/keyword/list', operationId: 'Keyword:list', summary: '搜索关键词记录列表', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['搜索'])]
    #[QueryParameter(name: 'page', description: '页码', example: '1')]
    #[QueryParameter(name: 'page_size', description: '每页数量', example: '20')]
    #[ResultResponse(instance: new Result())]
    public function list(): Result
    {
        $page = $this->getPage();
        $pageSize = $this->getPageSize();
        $list = SearchKeyword::query()
            ->select(['keyword', 'hit_count', 'icon', 'color'])
            ->orderByDesc('sort')
            ->offset(($page - 1) * $pageSize)
            ->limit($pageSize)
            ->get();
        return $this->success(['list' => $list]);
    }

    /**
     * 记录搜索关键词
     *
     * @param string $keyword
     */
    private function recordKeyword(string $keyword): void
    {
        try {
            SearchKeyword::query()->updateOrInsert(
                ['keyword' => $keyword],
                [
                    'keyword' => $keyword,
                    'hit_count' => Db::raw('hit_count + 1'),
                    'last_searched_at' => date('Y-m-d H:i:s'),
                    'source' => 1, // 用户搜索
                ]
            );
        } catch (\Throwable $e) {
            // 记录失败不影响搜索
        }
    }
}
