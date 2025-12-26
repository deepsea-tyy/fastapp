<?php

declare(strict_types=1);
namespace Plugin\Ds\SysKefu\Http\Admin\Service;

use App\Common\IService;
use Plugin\Ds\SysKefu\Repository\KefuAutoReplyRepository as Repository;

class KefuAutoReplyService extends IService
{
    public function __construct(
        protected readonly Repository $repository
    ) {}
}
