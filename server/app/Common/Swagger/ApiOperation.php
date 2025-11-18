<?php

declare(strict_types=1);


namespace App\Common\Swagger;

use OpenApi\Annotations\Operation;
use OpenApi\Attributes\OperationTrait;

#[\Attribute(\Attribute::TARGET_METHOD)]
class ApiOperation extends Operation
{
    use OperationTrait;
}
