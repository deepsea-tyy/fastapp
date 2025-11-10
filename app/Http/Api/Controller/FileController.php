<?php
/**
 * FastApp.
 * 文件访问控制器
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Http\Api\Controller;

use App\Common\AbstractController;
use App\Common\Tools;
use Hyperf\HttpServer\Contract\RequestInterface;
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\HyperfServer;
use Hyperf\Swagger\Annotation\QueryParameter;
use Psr\Http\Message\ResponseInterface;
use Hyperf\HttpMessage\Stream\SwooleStream;
use Hyperf\HttpServer\Contract\ResponseInterface as HttpResponse;

#[HyperfServer(name: 'http')]
class FileController extends AbstractController
{
    public function __construct(
        protected readonly HttpResponse $response
    ) {}

    #[Get(
        path: '/api/file',
        operationId: 'GetStorageFile',
        summary: '获取storage目录文件（测试阶段使用）',
        tags: ['文件访问'],
    )]
    #[QueryParameter(name: 'path', description: '文件路径，相对于storage目录', example: 'uploads/2025-10-29/example.jpg')]
    public function getFile(): ResponseInterface
    {
        $request = Tools::getContainer()->get(RequestInterface::class);
        $path = $request->query('path', '');
        $filePath = BASE_PATH . '/storage' . $path;
        if (!file_exists($filePath)) {
            return $this->response->withStatus(404)
                ->withHeader('Content-Type', 'application/json')
                ->withBody(new SwooleStream(json_encode([
                    'code' => 404,
                    'message' => '文件不存在'.$filePath,
                    'data' => []
                ],JSON_UNESCAPED_UNICODE)));
        }
        // 获取文件MIME类型
        $mimeType = $this->getMimeType($filePath);
        
        // 获取文件名
        $filename = basename($filePath);
        
        // 判断是否是视频文件
        $isVideo = $this->isVideoFile($filePath);
        
        // 检查客户端是否支持压缩
        $acceptEncoding = $request->getHeaderLine('Accept-Encoding');
        $hasCompression = !empty($acceptEncoding);
        
        // 如果是视频文件，只返回1M数据
        if ($isVideo) {
            $fileSize = filesize($filePath);
            $chunkSize = 1024 * 1024; // 1M
            $readSize = min($fileSize, $chunkSize);
            
            $fileHandle = fopen($filePath, 'rb');
            $fileContent = fread($fileHandle, $readSize);
            fclose($fileHandle);
            
            $response = $this->response->withHeader('Content-Type', $mimeType)
                ->withHeader('Content-Disposition', 'inline; filename="' . $filename . '"')
                ->withBody(new SwooleStream($fileContent));
            
            // 如果客户端不支持压缩，设置 Content-Length
            if (!$hasCompression) {
                $response = $response->withHeader('Content-Length', (string)$readSize);
            }
            
            return $response;
        }
        
        // 非视频文件，返回完整内容
        $fileContent = file_get_contents($filePath);
        
        // 对于文本类型文件，检测并转换编码为UTF-8
        if ($this->isTextFile($filePath)) {
            $fileContent = $this->convertToUtf8($fileContent);
        }
        
        $response = $this->response->withHeader('Content-Type', $mimeType)
            ->withHeader('Content-Disposition', 'inline; filename="' . $filename . '"')
            ->withBody(new SwooleStream($fileContent));
        
        // 如果客户端不支持压缩，设置 Content-Length
        if (!$hasCompression) {
            $response = $response->withHeader('Content-Length', (string)strlen($fileContent));
        }
        
        return $response;
    }
    
    /**
     * 获取文件的MIME类型
     */
    private function getMimeType(string $filePath): string
    {
        $extension = strtolower(pathinfo($filePath, PATHINFO_EXTENSION));
        
        $mimeTypes = [
            'jpg' => 'image/jpeg',
            'jpeg' => 'image/jpeg',
            'png' => 'image/png',
            'gif' => 'image/gif',
            'webp' => 'image/webp',
            'svg' => 'image/svg+xml',
            'pdf' => 'application/pdf',
            'doc' => 'application/msword',
            'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            'xls' => 'application/vnd.ms-excel',
            'xlsx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            'ppt' => 'application/vnd.ms-powerpoint',
            'pptx' => 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
            'zip' => 'application/zip',
            'rar' => 'application/x-rar-compressed',
            'mp4' => 'video/mp4',
            'mp3' => 'audio/mpeg',
            'wav' => 'audio/wav',
            'json' => 'application/json; charset=utf-8',
            'xml' => 'application/xml; charset=utf-8',
            'txt' => 'text/plain; charset=utf-8',
            'html' => 'text/html; charset=utf-8',
            'css' => 'text/css; charset=utf-8',
            'js' => 'application/javascript; charset=utf-8',
        ];
        
        return $mimeTypes[$extension] ?? 'application/octet-stream';
    }
    
    /**
     * 判断是否是视频文件
     */
    private function isVideoFile(string $filePath): bool
    {
        $extension = strtolower(pathinfo($filePath, PATHINFO_EXTENSION));
        
        $videoExtensions = ['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm', 'mkv', 'm4v', '3gp', 'ogv'];
        
        return in_array($extension, $videoExtensions);
    }
    
    /**
     * 判断是否是文本文件
     */
    private function isTextFile(string $filePath): bool
    {
        $extension = strtolower(pathinfo($filePath, PATHINFO_EXTENSION));
        
        $textExtensions = ['txt', 'html', 'htm', 'css', 'js', 'json', 'xml', 'csv', 'md', 'log', 'ini', 'conf', 'config', 'php'];
        
        return in_array($extension, $textExtensions);
    }
    
    /**
     * 将文件内容转换为UTF-8编码
     */
    private function convertToUtf8(string $content): string
    {
        // 检测当前编码
        $detectedEncoding = mb_detect_encoding($content, ['UTF-8', 'GBK', 'GB2312', 'ISO-8859-1', 'ASCII'], true);
        
        // 如果已经是UTF-8或者检测失败，直接返回
        if ($detectedEncoding === 'UTF-8' || $detectedEncoding === false) {
            // 验证是否为有效的UTF-8
            if (mb_check_encoding($content, 'UTF-8')) {
                return $content;
            }
            // 如果不是有效的UTF-8，尝试从GBK转换
            $detectedEncoding = 'GBK';
        }
        
        // 转换为UTF-8
        if ($detectedEncoding && $detectedEncoding !== 'UTF-8') {
            $content = mb_convert_encoding($content, 'UTF-8', $detectedEncoding);
        }
        
        return $content;
    }
}
