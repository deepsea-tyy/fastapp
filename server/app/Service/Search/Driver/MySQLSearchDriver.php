<?php

declare(strict_types=1);

namespace App\Service\Search\Driver;

use App\Model\Search\SearchIndex;
use App\Service\Search\SearchInterface;
use Hyperf\DbConnection\Db;
use Hyperf\Redis\Redis;
use Hyperf\Context\ApplicationContext;

/**
 * MySQL 全文搜索驱动
 *
 * 使用 MySQL 的 FULLTEXT 索引实现搜索
 * 支持中文分词（需配置 ngram）
 */
class MySQLSearchDriver implements SearchInterface
{
    /**
     * 缓存前缀
     */
    private const CACHE_PREFIX = 'search:mysql:';

    /**
     * 缓存过期时间（秒）
     */
    private const CACHE_TTL = 300;

    /**
     * 执行搜索
     */
    public function search(string $keyword, array $options = []): array
    {
        $startTime = microtime(true);

        // 解析选项
        $types = $options['types'] ?? [];
        $page = $options['page'] ?? 1;
        $pageSize = $options['page_size'] ?? 20;
        $filters = $options['filters'] ?? [];
        $sort = $options['sort'] ?? 'relevance';

        // 尝试从缓存获取
        $cacheKey = $this->getCacheKey($keyword, $options);
        $cached = $this->getCache($cacheKey);
        if ($cached !== null) {
            $cached['from_cache'] = true;
            return $cached;
        }

        // 构建查询
        $query = SearchIndex::query()->active();

        // 类型筛选
        if (!empty($types)) {
            $query->ofTypes($types);
        }

        // 额外筛选条件
        $this->applyFilters($query, $filters);

        // 全文搜索
        $this->applyFullTextSearch($query, $keyword);

        // 排序
        $this->applySort($query, $sort);

        // 获取总数
        $total = $query->count();

        // 分页
        $list = $query->offset(($page - 1) * $pageSize)
            ->limit($pageSize)
            ->get()
            ->map(function ($item) use ($keyword) {
                return [
                    'id' => $item->searchable_id,
                    'type' => $item->searchable_type,
                    'title' => $this->highlight($item->title, $keyword),
                    'content' => $this->highlight($this->truncate($item->content, 200), $keyword),
                    'author' => $item->author,
                    'tags' => $item->tags,
                    'weight' => $item->weight,
                    'view_count' => $item->view_count,
                    'like_count' => $item->like_count,
                    'published_at' => $item->published_at?->toDateTimeString(),
                    'extra' => $item->extra,
                ];
            })
            ->toArray();

        // 计算耗时
        $took = (int) ((microtime(true) - $startTime) * 1000);

        $result = [
            'total' => $total,
            'list' => $list,
            'took' => $took,
            'page' => $page,
            'page_size' => $pageSize,
            'from_cache' => false,
        ];

        // 缓存结果
        $this->setCache($cacheKey, $result);

        return $result;
    }

    /**
     * 应用全文搜索
     */
    private function applyFullTextSearch($query, string $keyword): void
    {
        // MySQL FULLTEXT BOOLEAN MODE 搜索
        // 注意：需要在 my.cnf 配置 ft_min_word_len=1 和 ngram_token_size=2
        $query->where(function ($q) use ($keyword) {
            // 方式1: FULLTEXT 搜索（主要）
            $q->whereRaw(
                "MATCH(title, content) AGAINST(? IN BOOLEAN MODE)",
                [$this->buildBooleanQuery($keyword)]
            );

            // 方式2: LIKE 模糊搜索（补充）
            $q->orWhere('title', 'like', "%{$keyword}%")
              ->orWhere('content', 'like', "%{$keyword}%")
              ->orWhere('author', 'like', "%{$keyword}%");
        });
    }

    /**
     * 构建布尔查询
     */
    private function buildBooleanQuery(string $keyword): string
    {
        // 将关键词分割并构建布尔查询
        // 例如: "比特币价格" -> "+比特币* +价格*"
        $words = preg_split('/\s+/u', trim($keyword));
        $terms = array_map(function ($word) {
            return '+' . $word . '*';
        }, $words);

        return implode(' ', $terms);
    }

    /**
     * 应用筛选条件
     */
    private function applyFilters($query, array $filters): void
    {
        // 作者筛选
        if (!empty($filters['author'])) {
            $query->where('author', $filters['author']);
        }

        // 标签筛选
        if (!empty($filters['tags'])) {
            $query->whereJsonContains('tags', $filters['tags']);
        }

        // 时间范围筛选
        if (!empty($filters['date_from'])) {
            $query->where('published_at', '>=', $filters['date_from']);
        }
        if (!empty($filters['date_to'])) {
            $query->where('published_at', '<=', $filters['date_to']);
        }

        // 权重筛选
        if (isset($filters['min_weight'])) {
            $query->where('weight', '>=', $filters['min_weight']);
        }
    }

    /**
     * 应用排序
     */
    private function applySort($query, string $sort): void
    {
        switch ($sort) {
            case 'time':
                $query->orderByPublished('desc');
                break;
            case 'weight':
                $query->orderByWeight('desc')->orderByPublished('desc');
                break;
            case 'hot':
                $query->orderByDesc('view_count')->orderByDesc('like_count');
                break;
            case 'relevance':
            default:
                // 相关度排序：权重 + 发布时间
                $query->orderByWeight('desc')->orderByPublished('desc');
                break;
        }
    }

    /**
     * 索引内容
     */
    public function index(string $type, int $id, array $data): bool
    {
        try {
            SearchIndex::query()->updateOrCreate(
                ['searchable_type' => $type, 'searchable_id' => $id],
                array_merge($data, [
                    'searchable_type' => $type,
                    'searchable_id' => $id,
                ])
            );

            // 清除相关缓存
            $this->clearCache();

            return true;
        } catch (\Throwable $e) {
            \Hyperf\Support\make(\Psr\Log\LoggerInterface::class)->error(
                'Search index failed: ' . $e->getMessage()
            );
            return false;
        }
    }

    /**
     * 批量索引
     */
    public function bulkIndex(string $type, array $items): bool
    {
        try {
            Db::beginTransaction();

            foreach ($items as $item) {
                $this->index($type, $item['id'], $item);
            }

            Db::commit();

            // 清除相关缓存
            $this->clearCache();

            return true;
        } catch (\Throwable $e) {
            Db::rollBack();
            \Hyperf\Support\make(\Psr\Log\LoggerInterface::class)->error(
                'Bulk search index failed: ' . $e->getMessage()
            );
            return false;
        }
    }

    /**
     * 删除索引
     */
    public function delete(string $type, int $id): bool
    {
        try {
            SearchIndex::query()
                ->where('searchable_type', $type)
                ->where('searchable_id', $id)
                ->delete();

            // 清除相关缓存
            $this->clearCache();

            return true;
        } catch (\Throwable $e) {
            return false;
        }
    }

    /**
     * 更新索引
     */
    public function update(string $type, int $id, array $data): bool
    {
        return $this->index($type, $id, $data);
    }

    /**
     * 清空指定类型的索引
     */
    public function clear(string $type): bool
    {
        try {
            SearchIndex::query()->where('searchable_type', $type)->delete();

            // 清除相关缓存
            $this->clearCache();

            return true;
        } catch (\Throwable $e) {
            return false;
        }
    }

    /**
     * 获取搜索建议
     */
    public function suggest(string $keyword, int $limit = 10): array
    {
        return SearchIndex::query()
            ->active()
            ->where(function ($q) use ($keyword) {
                $q->where('title', 'like', "{$keyword}%")
                  ->orWhere('content', 'like', "{$keyword}%");
            })
            ->select(['title', 'searchable_type'])
            ->distinct()
            ->limit($limit)
            ->get()
            ->map(function ($item) {
                return [
                    'text' => $item->title,
                    'type' => $item->searchable_type,
                ];
            })
            ->toArray();
    }

    /**
     * 获取驱动名称
     */
    public function getDriver(): string
    {
        return 'mysql';
    }

    /**
     * 关键词高亮
     */
    private function highlight(string $text, string $keyword): string
    {
        if (empty($text) || empty($keyword)) {
            return $text;
        }

        return preg_replace(
            '/(' . preg_quote($keyword, '/') . ')/iu',
            '<em>$1</em>',
            $text
        );
    }

    /**
     * 截断文本
     */
    private function truncate(?string $text, int $length): string
    {
        if (empty($text)) {
            return '';
        }

        if (mb_strlen($text) <= $length) {
            return $text;
        }

        return mb_substr($text, 0, $length) . '...';
    }

    /**
     * 获取缓存键
     */
    private function getCacheKey(string $keyword, array $options): string
    {
        return self::CACHE_PREFIX . md5($keyword . json_encode($options));
    }

    /**
     * 获取缓存
     */
    private function getCache(string $key): ?array
    {
        try {
            $redis = ApplicationContext::getContainer()->get(Redis::class);
            $cached = $redis->get($key);
            return $cached ? json_decode($cached, true) : null;
        } catch (\Throwable $e) {
            return null;
        }
    }

    /**
     * 设置缓存
     */
    private function setCache(string $key, array $data): void
    {
        try {
            $redis = ApplicationContext::getContainer()->get(Redis::class);
            $redis->setex($key, self::CACHE_TTL, json_encode($data));
        } catch (\Throwable $e) {
            // 忽略缓存错误
        }
    }

    /**
     * 清除所有搜索缓存
     */
    private function clearCache(): void
    {
        try {
            $redis = ApplicationContext::getContainer()->get(Redis::class);
            $keys = $redis->keys(self::CACHE_PREFIX . '*');
            if (!empty($keys)) {
                $redis->del(...$keys);
            }
        } catch (\Throwable $e) {
            // 忽略缓存错误
        }
    }
}
