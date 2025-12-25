<?php

declare(strict_types=1);

namespace App\Service\Search\Driver;

use App\Model\Search\SearchIndex;
use App\Service\Search\SearchInterface;
use Hyperf\Redis\Redis;
use Hyperf\Context\ApplicationContext;
use Hyperf\DbConnection\Db;

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

        // 尝试从缓存获取
        $cacheKey = $this->getCacheKey($keyword, $options);
        $cached = $this->getCache($cacheKey);
        if ($cached !== null) {
            $cached['from_cache'] = true;
            return $cached;
        }
        // 构建查询
        $query = SearchIndex::query()->select([
            'target_type', 'target_id', 'title',
            'content', 'tags', 'weight', 'click_count', 'last_at'
        ]);
        // 关键词搜索
        if (!empty($keyword)) {
            $keyword = strtolower($keyword);
            $query->where('title', 'like', "%{$keyword}%")
                ->orWhere('content', 'like', "%{$keyword}%")
                ->orWhereRaw("JSON_CONTAINS(keyword, '\"{$keyword}\"')");
        }
        if ($types) $query->whereIn('target_type', $types);
        // 分页
        $list = $query
            ->offset(($page - 1) * $pageSize)
            ->limit($pageSize)
            ->orderByDesc('last_at')
            ->get()->toArray();
        // 计算耗时
        $took = (int)((microtime(true) - $startTime) * 1000);

        // 缓存结果
        $result = [
            'list' => $list,
            'took' => $took,
        ];
        $this->setCache($cacheKey, $result);

        return $result;
    }

    /**
     * 获取搜索建议
     */
    public function suggest(string $keyword, int $limit = 10): array
    {
        return SearchIndex::query()
            ->where(function ($q) use ($keyword) {
                $q->where('title', 'like', "{$keyword}%")
                    ->orWhere('content', 'like', "{$keyword}%");
            })
            ->select([
                'target_type', 'target_id', 'title',
                'content', 'tags', 'weight', 'click_count', 'last_at'
            ])->distinct()
            ->limit($limit)
            ->orderByDesc('weight')
            ->get()
            ->toArray();
    }

    public function ranking(): array
    {
        return SearchIndex::query()
            ->select([
                'target_type', 'target_id', 'title',
                'content', 'tags', 'weight', 'click_count', 'last_at'
            ])
            ->orderByDesc('click_count')
            ->orderByDesc('weight')
            ->orderByDesc('last_at')
            ->limit(20)
            ->get()
            ->toArray();
    }

    /**
     * 记录搜索结果点击
     */
    public function recordClick(string $targetType, int $targetId): bool
    {
        try {
            SearchIndex::query()
                ->where('target_type', $targetType)
                ->where('target_id', $targetId)
                ->update(['click_count' => Db::raw('click_count + 1')]);
            return true;
        } catch (\Throwable $e) {
            return false;
        }
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
}
