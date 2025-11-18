<?php

declare(strict_types=1);


namespace Plugin\Ds\SystemConfig\Service;

use App\Common\IService;
use Plugin\Ds\SystemConfig\Repository\ConfigGroupRepository as Repository;

/**
 * 参数配置分组表服务类.
 */
final class ConfigGroupService extends IService
{
    public function __construct(
        protected readonly Repository $repository
    ) {}
}
