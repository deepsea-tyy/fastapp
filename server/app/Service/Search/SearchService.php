<?php

declare(strict_types=1);

namespace App\Service\Search;

use App\Service\Search\Driver\MySQLSearchDriver;
use Plugin\Ds\SysConfig\Helper\CacheConfigHelper;

/**
 * 搜索服务工厂
 *
 * 统一的搜索服务入口，支持多种搜索引擎切换
 * 通过配置文件切换驱动：mysql, elasticsearch
 */
class SearchService
{
    /**
     * 驱动实例缓存
     */
    private static ?SearchInterface $driver = null;

    /**
     * 获取搜索驱动实例
     *
     * @return SearchInterface
     */
    public function driver(): SearchInterface
    {
        if (self::$driver !== null) {
            return self::$driver;
        }

        $driverName = CacheConfigHelper::getConfigByKey('search_driver')['value'] ?? 'mysql';

        self::$driver = match ($driverName) {
            'mysql' => new MySQLSearchDriver(),
            // 'elasticsearch' => new ElasticsearchDriver()
            default => throw new \RuntimeException("Unsupported search driver: {$driverName}"),
        };

        return self::$driver;
    }

    /**
     * 执行搜索
     *
     * @param string $keyword 搜索关键词
     * @param array $options 搜索选项
     * @return array
     */
    public function search(string $keyword, array $options = []): array
    {
        return $this->driver()->search($keyword, $options);
    }

    /**
     * 获取搜索建议
     *
     * @param string $keyword 关键词前缀
     * @param int $limit 返回数量
     * @return array
     */
    public function suggest(string $keyword, int $limit = 10): array
    {
        return $this->driver()->suggest($keyword, $limit);
    }

    public function ranking(): array
    {
        return $this->driver()->ranking();
    }
}
