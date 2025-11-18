<?php

declare(strict_types=1);

namespace Plugin\Ds\Article\Service;

use App\Common\IService;
use Plugin\Ds\Article\Repository\ArticleRepository as Repository;


class ArticleService extends IService
{
    public function __construct(
        protected readonly Repository $repository
    ) {}
}
