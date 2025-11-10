<?php
/**
 * FastApp.
 * 10/17/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace Plugin\Ds\SystemConfig\Helper;

use Hyperf\Cache\Annotation\Cacheable;
use Hyperf\Cache\Annotation\CacheEvict;
use Hyperf\Collection\Collection;

class CacheConfig
{
    #[Cacheable(prefix: 'syscfg:group', value: '_#{key}')]
    public static function getConfigByGroupKey(string $key): Collection
    {
        return Helper::getSystemConfigGroup($key)->columns(['name', 'key', 'value', 'remark', 'input_type', 'config_select_data']);
    }

    #[Cacheable(prefix: 'syscfg:config', value: '_#{key}')]
    public static function getDictByKey(string $key): ?array
    {
        return Helper::getSystemConfig($key);
    }

    /**
     * 清除缓存.
     */
    #[CacheEvict(prefix: 'syscfg', all: true)]
    public static function clear(): void
    {
    }
}