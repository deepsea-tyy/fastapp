<?php

declare(strict_types=1);

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

class FileStorage
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
                'root' => Tools::storage_path('uploads'),
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
            ],
        ];
        $this->adapterName = $config->get('storage_mode', 'local');
        $c = $options[$this->adapterName];
        /** @var AdapterFactoryInterface $driver */
        $driver = Tools::getContainer()->get($c['driver']);
        $adapter = $driver->make($c);

        return new Filesystem($adapter, $c);
    }

    public function putUploaded(UploadedFileInterface $fileInfo, ?string $hash = null): StoredFile
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
            $hash = $hash ?: md5_file($fileInfo->getRealPath());
            $size = $fileInfo->getSize();
            $url = $this->filesystem->publicUrl($filePath);

            return new StoredFile(
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

    public function stagingPath(string $basenamePrefix, string $extension): string
    {
        $ext = strtolower(ltrim($extension, '.'));
        $dir = $this->localUploadDirForToday();

        return $dir . '/' . $basenamePrefix . '_' . bin2hex(random_bytes(12)) . '.' . $ext;
    }

    public function putLocal(string $absolutePath, ?string $objectName = null, bool $move = false): StoredFile
    {
        $realFile = $this->requireReadableRealPath($absolutePath);
        $path = $this->generatorPath();

        $objectName = $objectName ?: basename($absolutePath);
        $target = $this->localUploadDirForToday() . '/' . $objectName;
        $filePath = $this->placeLocalFile($realFile, $target, $move);
        $url = '/uploads/' . ltrim($path, '/') . '/' . $objectName;

        $mimeType = mime_content_type($filePath) ?: 'application/octet-stream';
        $hash = md5_file($filePath) ?: '';
        $size = (int) (filesize($filePath) ?: 0);
        $suffix = strtolower(pathinfo($filePath, PATHINFO_EXTENSION) ?: 'bin');
        $publicUrl = env('APP_URL', 'http://127.0.0.1:9501') . $url;

        return new StoredFile(
            'local',
            $objectName,
            $mimeType,
            $path,
            $hash,
            $suffix,
            $size,
            $publicUrl
        );
    }

    public function putChunk(string $hash, int $chunkIndex, UploadedFileInterface $chunkFile): void
    {
        try {
            $tmpPath = $this->generatorChunkPath($hash, $chunkIndex);
            $this->filesystem->write($tmpPath, file_get_contents($chunkFile->getRealPath()));
        } catch (\Exception $e) {
            throw new UploadFailException('Chunk upload failed: ' . $e->getMessage(), 0, $e);
        }
    }

    public function mergeChunks(string $hash, string $filename, int $totalChunks): StoredFile
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
            $realPath = Tools::storage_path(parse_url($url, PHP_URL_PATH));

            $mimeType = mime_content_type($realPath) ?: 'application/octet-stream';
            $size = filesize($realPath);
            $extension = pathinfo($filename, PATHINFO_EXTENSION);

            return new StoredFile(
                $this->adapterName,
                $filename,
                $mimeType,
                $path,
                $hash,
                Str::lower($extension),
                $size,
                $url
            );
        } catch (\Exception $e) {
            throw new UploadFailException('Merge chunks failed: ' . $e->getMessage(), 0, $e);
        }
    }

    protected function generatorPath(): string
    {
        return '/' . date('Ymd');
    }

    protected function generatorId(): string
    {
        return Uuid::uuid4()->toString();
    }

    private function localUploadDirForToday(): string
    {
        $dir = Tools::storage_path('uploads') . $this->generatorPath();
        if (! is_dir($dir)) {
            mkdir($dir, 0755, true);
        }

        return $dir;
    }

    private function requireReadableRealPath(string $absolutePath): string
    {
        $absolutePath = trim($absolutePath);
        $realFile = $absolutePath != '' ? realpath($absolutePath) : false;

        return $realFile ?: $absolutePath;
    }

    private function placeLocalFile(string $realFile, string $target, bool $move): string
    {
        if ($realFile == $target) {
            return $target;
        }
        $ok = $move ? rename($realFile, $target) : copy($realFile, $target);
        if (! $ok) {
            if ($move) {
                throw new UploadFailException('Failed to move local file');
            }

            return $realFile;
        }

        return $target;
    }

    protected function generatorChunkPath(string $hash, int $chunkIndex): string
    {
        return Tools::storage_path('/tmp/' . $hash . '/' . $chunkIndex . '.tmp');
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
