<?php
/**
 * FastApp.
 * 10/17/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace Plugin\Ds\SystemConfig\Http\Api;

use App\Common\AbstractController;
use App\Common\Request\Request;
use App\Common\Result;
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\HyperfServer;
use App\Common\Swagger\ResultResponse;
use OpenApi\Attributes\QueryParameter;
use Plugin\Ds\SystemConfig\Helper\CacheConfig;

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
    #[QueryParameter(name: 'code')]
    public function config(Request $request): Result
    {
        return $this->success(CacheConfig::getConfigByGroupKey($request->query('code')));
    }
}