<?php
/**
 * FastApp.
 * 10/17/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace Plugin\Ds\SysConfig\Http\Api;

use App\Common\AbstractController;
use App\Common\Request\Request;
use App\Common\Result;
use Hyperf\HttpServer\Annotation\Controller;
use Hyperf\HttpServer\Annotation\GetMapping;
use Plugin\Ds\SysConfig\Helper\CacheConfigHelper;

#[Controller]
class SystemController extends AbstractController
{
    #[GetMapping(path: '/api/system/config')]
    public function config(Request $request): Result
    {
        return $this->success(CacheConfigHelper::getConfigByGroupKey($request->query('code')));
    }
}