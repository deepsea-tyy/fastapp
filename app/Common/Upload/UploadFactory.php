<?php
/**
 * FastApp.
 * 10/16/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Common\Upload;

use Hyperf\Filesystem\FilesystemFactory;
use Hyperf\Stringable\Str;
use League\Flysystem\Filesystem;
use Psr\Http\Message\UploadedFileInterface;
use Ramsey\Uuid\Uuid;

class UploadFactory
{

    private Filesystem $filesystem;

    public function __construct(
        FilesystemFactory $filesystemFactory,
        public string     $adapterName = 'local',
    )
    {
        $this->filesystem = $filesystemFactory->get($this->adapterName);
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