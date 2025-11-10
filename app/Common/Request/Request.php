<?php
/**
 * FastApp.
 * 10/17/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Common\Request;

use App\Common\Request\Traits\ClientIpRequestTrait;
use App\Common\Request\Traits\ClientOsTrait;
use Hyperf\HttpServer\Contract\RequestInterface;

class Request extends \Hyperf\HttpServer\Request implements RequestInterface
{
    use ClientIpRequestTrait;
    use ClientOsTrait;
}