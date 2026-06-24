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
use App\Http\Admin\Service\AttachmentService;
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
        protected readonly HttpResponse $response,
        protected readonly AttachmentService $attachmentService,
    ) {}

    #[Get(
        path: '/api/file',
        operationId: 'GetStorageFile',
        summary: '文件访问',
        tags: ['文件管理'],
    )]
    #[QueryParameter(name: 'path', description: '文件路径，相对于storage目录', example: 'uploads/2025-10-29/example.jpg')]
    #[QueryParameter(name: 'id', description: 'attachment 表主键', example: '123')]
    public function getFile(): ResponseInterface
    {
        $request = Tools::getContainer()->get(RequestInterface::class);
        $id = (int) $request->query('id', 0);
        $path = $request->query('path', '');
        if ($id) {
            $attachment = $this->attachmentService->findById($id);
            if (!$attachment) {
                return $this->response->withStatus(404);
            }
            $path = $attachment->url;
        }
        $filePath = Tools::storage_path($path);
        if (!file_exists($filePath)) {
            return $this->response->withStatus(404);
        }

        $mimeType = $this->getMimeType($filePath);
        $filename = basename($filePath);

        if ($this->isTextFile($filePath)) {
            $fileContent = $this->convertToUtf8(file_get_contents($filePath));
            return $this->response->withHeader('Content-Type', $mimeType)
                ->withHeader('Content-Disposition', 'inline; filename="' . $filename . '"')
                ->withHeader('Content-Length', (string) strlen($fileContent))
                ->withBody(new SwooleStream($fileContent));
        }

        return $this->streamBinary($filePath, $mimeType, $filename, $request);
    }

    private function streamBinary(string $filePath, string $mimeType, string $filename, RequestInterface $request): ResponseInterface
    {
        $fileSize = filesize($filePath);
        $range = $request->getHeaderLine('Range');

        if ($range && preg_match('/bytes=(\d+)-(\d*)/', $range, $matches)) {
            $start = (int) $matches[1];
            $end = $matches[2] !== '' ? (int) $matches[2] : $fileSize - 1;
            $end = min($end, $fileSize - 1);

            if ($start > $end || $start >= $fileSize) {
                return $this->response->withStatus(416)
                    ->withHeader('Content-Range', 'bytes */' . $fileSize);
            }

            $length = $end - $start + 1;
            $handle = fopen($filePath, 'rb');
            fseek($handle, $start);
            $content = fread($handle, $length);
            fclose($handle);

            return $this->response->withStatus(206)
                ->withHeader('Content-Type', $mimeType)
                ->withHeader('Content-Disposition', 'inline; filename="' . $filename . '"')
                ->withHeader('Accept-Ranges', 'bytes')
                ->withHeader('Content-Range', 'bytes ' . $start . '-' . $end . '/' . $fileSize)
                ->withHeader('Content-Length', (string) $length)
                ->withBody(new SwooleStream($content));
        }

        $content = file_get_contents($filePath);

        return $this->response->withHeader('Content-Type', $mimeType)
            ->withHeader('Content-Disposition', 'inline; filename="' . $filename . '"')
            ->withHeader('Accept-Ranges', 'bytes')
            ->withHeader('Content-Length', (string) $fileSize)
            ->withBody(new SwooleStream($content));
    }

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
            'avi' => 'video/x-msvideo',
            'mov' => 'video/quicktime',
            'wmv' => 'video/x-ms-wmv',
            'flv' => 'video/x-flv',
            'mkv' => 'video/x-matroska',
            'webm' => 'video/webm',
            'mp3' => 'audio/mpeg',
            'wav' => 'audio/wav',
            'ogg' => 'audio/ogg',
            'aac' => 'audio/aac',
            'm4a' => 'audio/mp4',
            'flac' => 'audio/flac',
            'wma' => 'audio/x-ms-wma',
            'ape' => 'audio/ape',
            'json' => 'application/json; charset=utf-8',
            'xml' => 'application/xml; charset=utf-8',
            'txt' => 'text/plain; charset=utf-8',
            'html' => 'text/html; charset=utf-8',
            'css' => 'text/css; charset=utf-8',
            'js' => 'application/javascript; charset=utf-8',
        ];

        return $mimeTypes[$extension] ?? 'application/octet-stream';
    }

    private function isTextFile(string $filePath): bool
    {
        $extension = strtolower(pathinfo($filePath, PATHINFO_EXTENSION));

        $textExtensions = ['txt', 'html', 'htm', 'css', 'js', 'json', 'xml', 'csv', 'md', 'log', 'ini', 'conf', 'config', 'php'];

        return in_array($extension, $textExtensions);
    }

    private function convertToUtf8(string $content): string
    {
        $detectedEncoding = mb_detect_encoding($content, ['UTF-8', 'GBK', 'GB2312', 'ISO-8859-1', 'ASCII'], true);

        if ($detectedEncoding === 'UTF-8' || $detectedEncoding === false) {
            if (mb_check_encoding($content, 'UTF-8')) {
                return $content;
            }
            $detectedEncoding = 'GBK';
        }

        if ($detectedEncoding && $detectedEncoding !== 'UTF-8') {
            $content = mb_convert_encoding($content, 'UTF-8', $detectedEncoding);
        }

        return $content;
    }
}
