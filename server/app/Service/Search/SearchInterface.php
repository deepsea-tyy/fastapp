<?php

declare(strict_types=1);

namespace App\Service\Search;

/**
 * 搜索引擎接口
 *
 * 定义统一的搜索接口，支持多种搜索引擎实现
 * 后期可轻松切换到 Elasticsearch、Meilisearch 等
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
     *   - filters: array 额外筛选条件
     *   - sort: string 排序方式 'relevance'|'time'|'weight'
     * @return array 返回搜索结果
     *   - total: int 总数
     *   - list: array 结果列表
     *   - took: int 耗时(毫秒)
     */
    public function search(string $keyword, array $options = []): array;

    /**
     * 索引内容
     *
     * @param string $type 内容类型 article|feed|activity
     * @param int $id 内容ID
     * @param array $data 索引数据
     *   - title: string 标题
     *   - content: string 内容
     *   - author: string 作者
     *   - tags: array 标签
     *   - weight: int 权重
     *   - published_at: string 发布时间
     * @return bool 是否成功
     */
    public function index(string $type, int $id, array $data): bool;

    /**
     * 批量索引
     *
     * @param string $type 内容类型
     * @param array $items 批量数据 [['id' => 1, 'title' => '...'], ...]
     * @return bool 是否成功
     */
    public function bulkIndex(string $type, array $items): bool;

    /**
     * 删除索引
     *
     * @param string $type 内容类型
     * @param int $id 内容ID
     * @return bool 是否成功
     */
    public function delete(string $type, int $id): bool;

    /**
     * 更新索引
     *
     * @param string $type 内容类型
     * @param int $id 内容ID
     * @param array $data 更新数据
     * @return bool 是否成功
     */
    public function update(string $type, int $id, array $data): bool;

    /**
     * 清空指定类型的索引
     *
     * @param string $type 内容类型
     * @return bool 是否成功
     */
    public function clear(string $type): bool;

    /**
     * 获取搜索建议
     *
     * @param string $keyword 关键词前缀
     * @param int $limit 返回数量
     * @return array 建议列表
     */
    public function suggest(string $keyword, int $limit = 10): array;

    /**
     * 获取驱动名称
     *
     * @return string
     */
    public function getDriver(): string;
}
