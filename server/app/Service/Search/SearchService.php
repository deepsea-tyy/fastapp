<?php

declare(strict_types=1);

namespace App\Service\Search;

use App\Service\Search\Driver\MySQLSearchDriver;
use Hyperf\Contract\ConfigInterface;
use Hyperf\Context\ApplicationContext;
use Psr\Container\ContainerInterface;

/**
 * 搜索服务工厂
 *
 * 统一的搜索服务入口，支持多种搜索引擎切换
 * 通过配置文件切换驱动：mysql, elasticsearch, meilisearch
 */
class SearchService
{
    /**
     * 驱动实例缓存
     */
    private static ?SearchInterface $driver = null;

    /**
     * 容器实例
     */
    private ContainerInterface $container;

    /**
     * 配置实例
     */
    private ConfigInterface $config;

    public function __construct()
    {
        $this->container = ApplicationContext::getContainer();
        $this->config = $this->container->get(ConfigInterface::class);
    }

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

        $driverName = $this->config->get('search.driver', 'mysql');

        self::$driver = match ($driverName) {
            'mysql' => new MySQLSearchDriver(),
            // 'elasticsearch' => new ElasticsearchDriver(),
            // 'meilisearch' => new MeilisearchDriver(),
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
     * 索引内容
     *
     * @param string $type 内容类型
     * @param int $id 内容ID
     * @param array $data 索引数据
     * @return bool
     */
    public function index(string $type, int $id, array $data): bool
    {
        return $this->driver()->index($type, $id, $data);
    }

    /**
     * 批量索引
     *
     * @param string $type 内容类型
     * @param array $items 批量数据
     * @return bool
     */
    public function bulkIndex(string $type, array $items): bool
    {
        return $this->driver()->bulkIndex($type, $items);
    }

    /**
     * 删除索引
     *
     * @param string $type 内容类型
     * @param int $id 内容ID
     * @return bool
     */
    public function delete(string $type, int $id): bool
    {
        return $this->driver()->delete($type, $id);
    }

    /**
     * 更新索引
     *
     * @param string $type 内容类型
     * @param int $id 内容ID
     * @param array $data 更新数据
     * @return bool
     */
    public function update(string $type, int $id, array $data): bool
    {
        return $this->driver()->update($type, $id, $data);
    }

    /**
     * 清空指定类型的索引
     *
     * @param string $type 内容类型
     * @return bool
     */
    public function clear(string $type): bool
    {
        return $this->driver()->clear($type);
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

    /**
     * 获取当前驱动名称
     *
     * @return string
     */
    public function getDriverName(): string
    {
        return $this->driver()->getDriver();
    }

    /**
     * 强制重新加载驱动
     *
     * @return void
     */
    public function reloadDriver(): void
    {
        self::$driver = null;
    }
}
