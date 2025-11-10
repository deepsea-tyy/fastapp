<?php

declare(strict_types=1);


namespace App\Http\Admin\Service\Logstash;

use App\Common\IService;
use App\Repository\Logstash\UserAdminOperationLogRepository;

final class UserAdminOperationLogService extends IService
{
    public function __construct(
        protected readonly UserAdminOperationLogRepository $repository
    ) {}
}
