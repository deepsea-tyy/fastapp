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
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\HyperfServer;
use App\Common\Swagger\ResultResponse;
use Hyperf\Swagger\Annotation\QueryParameter;
use Plugin\Ds\SysConfig\Helper\CacheConfigHelper;

#[HyperfServer(name: 'http')]
class SystemController extends AbstractController
{
    #[Get(
        path: '/api/system/config',
        operationId: 'ApiSystemConfig',
        summary: '系统配置',
        security: [['token' => []]],
        tags: ['全局接口'],
    )]
    #[ResultResponse(instance: new Result())]
    #[QueryParameter(name: 'code', description: '配置分组代码', required: true, example: 'system')]
    public function config(Request $request): Result
    {
        return $this->success(CacheConfigHelper::getConfigByGroupKey($request->query('code')));
    }
}