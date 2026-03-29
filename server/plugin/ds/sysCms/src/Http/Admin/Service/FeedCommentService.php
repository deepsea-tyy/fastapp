<?php

declare(strict_types=1);
namespace Plugin\Ds\SysCms\Http\Admin\Service;

use App\Common\IService;
use Plugin\Ds\SysCms\Repository\FeedCommentRepository as Repository;

class FeedCommentService extends IService
{
    public function __construct(
        protected readonly Repository $repository
    ) {}
}
