<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Http\Api\Controller;

use App\Common\AbstractController;
use App\Common\Tools;
use Plugin\Ds\SysCms\Http\Api\Service\AppPageContentService;
use Hyperf\HttpServer\Annotation\Controller;
use Hyperf\HttpServer\Contract\ResponseInterface as HttpResponse;
use Hyperf\HttpMessage\Stream\SwooleStream;
use Psr\Http\Message\ResponseInterface;
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\HyperfServer;
use Hyperf\Swagger\Annotation\QueryParameter;

/**
 * App页面内容API控制器
 *
 * @author FastApp代码生成器
 * @date 2025-12-08
 */
#[HyperfServer(name: 'http')]
#[Controller]
class AppPageContentController extends AbstractController
{
    public function __construct(
        private readonly AppPageContentService $service,
        private readonly HttpResponse          $response
    )
    {
    }

    #[Get(
        path: '/api/app/page-content/download',
        operationId: 'DownloadAppPageContentFile',
        summary: '下载页面内容文件',
        tags: ['App页面内容'],
    )]
    #[QueryParameter(name: 'platform', description: '平台：1Web 2App', example: '2')]
    public function download(): ResponseInterface
    {
        $params = $this->getRequestData();
        $platform = (int)($params['platform'] ?? 2);

        // 直接使用固定文件名格式
        $relativePath = $this->service->getFixedFilePath($platform);
        $filePath = BASE_PATH . '/' . $relativePath;

        if (!file_exists($filePath)) {
            return $this->jsonResponse(404, '文件不存在');
        }

        $mimeType = 'application/json; charset=utf-8';
        $fileContent = Tools::getRedis()->get('app:init' . $platform);
        return $this->response->withHeader('Content-Type', $mimeType)
            ->withHeader('Content-Disposition', 'attachment; filename="' . basename($filePath) . '"')
            ->withHeader('Content-Length', (string)strlen($fileContent))
            ->withBody(new SwooleStream($fileContent));
    }

    /**
     * 返回JSON错误响应
     */
    private function jsonResponse(int $code, string $message): ResponseInterface
    {
        return $this->response->withStatus($code)
            ->withHeader('Content-Type', 'application/json')
            ->withBody(new SwooleStream(json_encode([
                'code' => $code,
                'message' => $message,
                'data' => []
            ], JSON_UNESCAPED_UNICODE)));
    }
}

