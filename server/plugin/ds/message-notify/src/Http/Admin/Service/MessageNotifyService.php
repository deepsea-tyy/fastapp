<?php

declare(strict_types=1);

namespace Plugin\Ds\MessageNotify\Http\Admin\Service;

use App\Common\IService;
use Plugin\Ds\MessageNotify\Repository\MessageNotifyRepository as Repository;



class MessageNotifyService extends IService
{
    public function __construct(
        protected readonly Repository $repository
    ) {}
}
