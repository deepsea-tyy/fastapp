<?php
/**
 * FastApp.
 * 10/16/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Common\Upload;

use App\Common\Tools;
use Hyperf\Filesystem\Adapter\AliyunOssAdapterFactory;
use Hyperf\Filesystem\Adapter\CosAdapterFactory;
use Hyperf\Filesystem\Adapter\LocalAdapterFactory;
use Hyperf\Filesystem\Adapter\QiniuAdapterFactory;
use Hyperf\Filesystem\Contract\AdapterFactoryInterface;
use Hyperf\Stringable\Str;
use League\Flysystem\Filesystem;
use Plugin\Ds\SysConfig\Helper\CacheConfigHelper;
use Psr\Http\Message\UploadedFileInterface;
use Ramsey\Uuid\Uuid;

class UploadFactory
{

    private Filesystem $filesystem;
    private string $adapterName;

    public function __construct()
    {
        $this->filesystem = $this->get();
    }

    public function get(): Filesystem
    {
        $config = CacheConfigHelper::getConfigByGroupKey('sys_storage')->pluck('value', 'key');
        $options = [
            'local' => [
                'driver' => LocalAdapterFactory::class,
                'root' => BASE_PATH . '/storage/uploads',
                'public_url' => env('APP_URL', 'http://127.0.0.1:9501') . '/uploads',
            ],
            'oss' => [
                'driver' => AliyunOssAdapterFactory::class,
                'accessId' => $config->get('oss_access_id'),
                'accessSecret' => $config->get('oss_access_secret'),
                'bucket' => $config->get('oss_bucket'),
                'endpoint' => $config->get('oss_endpoint'),
                'domain' => $config->get('oss_domain'),
                'schema' => 'http://',
                'isCName' => false,
                // 'timeout'        => 3600,
                // 'connectTimeout' => 10,
                // 'token'          => '',
            ],
            'qiniu' => [
                'driver' => QiniuAdapterFactory::class,
                'accessKey' => $config->get('qiniu_access_key'),
                'secretKey' => $config->get('qiniu_secret_key'),
                'bucket' => $config->get('qiniu_bucket'),
                'domain' => $config->get('qiniu_domain'),
                'schema' => 'http://',
            ],
            'cos' => [
                'driver' => CosAdapterFactory::class,
                'app_id' => $config->get('cos_app_id'),
                'secret_id' => $config->get('cos_secret_id'),
                'secret_key' => $config->get('cos_secret_key'),
                'bucket' => $config->get('cos_bucket'),
                'domain' => $config->get('cos_domain'),
                'region' => $config->get('cos_region'),
                'schema' => 'http://',
                'read_from_cdn' => false,
                // 可选，如果 bucket 为私有访问请打开此项
                // 'signed_url' => false,
                // 'timeout'         => 60,
                // 'connect_timeout' => 60,
                // 'cdn'             => '',
                // 'scheme'          => 'https',
            ],
        ];
        $this->adapterName = $config->get('storage_mode', 'local');
        $c = $options[$this->adapterName];
        /** @var AdapterFactoryInterface $driver */
        $driver = Tools::getContainer()->get($c['driver']);
        $adapter = $driver->make($c);
        return new Filesystem($adapter, $c);
    }

    public function upload(UploadedFileInterface $fileInfo): Upload
    {
        try {
            $path = $this->generatorPath();
            $filename = $this->generatorId() . '.' . Str::lower($fileInfo->getExtension());
            $filePath = $path . '/' . $filename;

            $fileContent = file_get_contents($fileInfo->getRealPath());
            if ($fileContent === false) {
                throw new UploadFailException('Failed to read file content');
            }

            $this->filesystem->write($filePath, $fileContent);

            $mimeType = mime_content_type($fileInfo->getRealPath()) ?: 'application/octet-stream';
            $hash = md5_file($fileInfo->getRealPath());
            $size = $fileInfo->getSize();
            $url = $this->filesystem->publicUrl($filePath);

            return new Upload(
                $this->adapterName,
                $filename,
                $mimeType,
                $path,
                $hash,
                Str::lower($fileInfo->getExtension()),
                $size,
                $url
            );
        } catch (\Exception $e) {
            throw new UploadFailException('Upload failed: ' . $e->getMessage(), 0, $e);
        }
    }

    protected function generatorPath(): string
    {
        return '/' . date('Y-m-d');
    }

    protected function generatorId(): string
    {
        return Uuid::uuid4()->toString();
    }

    public function uploadChunk(string $hash, int $chunkIndex, UploadedFileInterface $chunkFile): bool
    {
        try {
            $tmpPath = $this->generatorChunkPath($hash, $chunkIndex);
            $this->filesystem->write($tmpPath, file_get_contents($chunkFile->getRealPath()));
            return true;
        } catch (\Exception $e) {
            throw new UploadFailException('Chunk upload failed: ' . $e->getMessage(), 0, $e);
        }
    }

    public function mergeChunks(string $hash, string $filename, int $totalChunks): Upload
    {
        try {
            $path = $this->generatorPath();
            $filePath = $path . '/' . $filename;

            $tempFile = tmpfile();

            for ($i = 0; $i < $totalChunks; $i++) {
                $chunkPath = $this->generatorChunkPath($hash, $i);
                if ($this->filesystem->fileExists($chunkPath)) {
                    $chunkContent = $this->filesystem->read($chunkPath);
                    fwrite($tempFile, $chunkContent);
                }
            }

            rewind($tempFile);
            $this->filesystem->writeStream($filePath, $tempFile);
            fclose($tempFile);
            $url = $this->filesystem->publicUrl($filePath);
            $this->cleanupChunks($hash, $totalChunks);
            $realPath = BASE_PATH . '/storage' . parse_url($url, PHP_URL_PATH);

            $mimeType = mime_content_type($realPath) ?: 'application/octet-stream';
            $fileHash = md5_file($realPath);
            $size = filesize($realPath);
            $extension = pathinfo($filename, PATHINFO_EXTENSION);

            return new Upload(
                $this->adapterName,
                $filename,
                $mimeType,
                $path,
                $fileHash,
                Str::lower($extension),
                $size,
                $url
            );
        } catch (\Exception $e) {
            throw new UploadFailException('Merge chunks failed: ' . $e->getMessage(), 0, $e);
        }
    }

    protected function generatorChunkPath(string $hash, int $chunkIndex): string
    {
        return '/tmp/' . $hash . '/' . $chunkIndex . '.tmp';
    }

    protected function cleanupChunks(string $hash, int $totalChunks): void
    {
        for ($i = 0; $i < $totalChunks; $i++) {
            $chunkPath = $this->generatorChunkPath($hash, $i);
            if ($this->filesystem->fileExists($chunkPath)) {
                $this->filesystem->delete($chunkPath);
            }
        }
    }
}