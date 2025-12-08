<?php

declare(strict_types=1);

namespace Plugin\Ds\SysNotify\Http\Admin\Service;

use App\Common\IService;
use Plugin\Ds\SysNotify\Repository\MessageNotifyRepository as Repository;



class MessageNotifyService extends IService
{
    public function __construct(
        protected readonly Repository $repository
    ) {}
}
