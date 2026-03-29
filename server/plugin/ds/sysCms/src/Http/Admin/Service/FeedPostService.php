<?php

declare(strict_types=1);
namespace Plugin\Ds\SysCms\Http\Admin\Service;

use App\Common\IService;
use Plugin\Ds\SysCms\Repository\FeedPostRepository as Repository;

class FeedPostService extends IService
{
    public function __construct(
        protected readonly Repository $repository
    ) {}
}
