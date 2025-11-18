<?php

declare(strict_types=1);


namespace App\Common\Swagger;

use Hyperf\Swagger\Annotation\Items;
use Hyperf\Swagger\Annotation\Property;

#[\Attribute(\Attribute::IS_REPEATABLE | \Attribute::TARGET_METHOD)]
class ListResponse extends ResultResponse
{
    protected function parserInstance(object|string $instance): array
    {
        $result[] = new Property(property: 'list', type: 'array', items: new Items(ref: $instance, description: '数据列表'));
        return $result;
    }
}
