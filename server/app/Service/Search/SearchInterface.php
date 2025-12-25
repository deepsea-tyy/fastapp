<?php

declare(strict_types=1);

namespace App\Service\Search;

/**
 * 搜索引擎接口
 *
 * 定义统一的搜索接口，支持多种搜索引擎实现
 * 后期可轻松切换到 Elasticsearch 等
 */
interface SearchInterface
{
    /**
     * 执行搜索
     *
     * @param string $keyword 搜索关键词
     * @param array $options 搜索选项
     *   - types: array 内容类型筛选 ['article', 'feed', 'activity']
     *   - page: int 页码
     *   - page_size: int 每页数量
     * @return array 返回搜索结果
     *   - list: array 结果列表
     */
    public function search(string $keyword, array $options = []): array;

    /**
     * 获取搜索建议
     *
     * @return array 建议列表
     */
    public function suggest(string $keyword, int $limit = 10): array;

    /**
     * 获取搜索排行榜
     *
     * @return array 排行榜列表
     */
    public function ranking(): array;

    /**
     * 记录搜索结果点击
     *
     * @param string $targetType 内容类型
     * @param int $targetId 内容ID
     * @return bool
     */
    public function recordClick(string $targetType, int $targetId): bool;
}
