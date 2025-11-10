<?php

declare(strict_types=1);

namespace Plugin\Ds\SystemConfig\Helper;

use Hyperf\Collection\Collection;
use Plugin\Ds\SystemConfig\Repository\ConfigRepository;

class Helper
{
    /**
     * 获取所有分组数据.
     */
    public static function getSystemConfigGroup(?string $code = null): Collection
    {
        $repository = make(ConfigRepository::class);
        return $repository->list(['group_code' => $code]);
    }

    /**
     * 获取某个配置数据.
     */
    public static function getSystemConfig(string $typeCode): ?array
    {
        return make(ConfigRepository::class)
            ->getQuery()
            ->where('key', $typeCode)
            ->orderByDesc('created_at')
            ->first()?->toArray();
    }
}
