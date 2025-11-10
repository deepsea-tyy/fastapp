<?php
/**
 * FastApp.
 * 10/19/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Common\Upload;

class UploadFailException extends \RuntimeException
{
    public function __construct(string $message = 'Upload failed', int $code = 0, ?\Throwable $previous = null)
    {
        parent::__construct($message, $code, $previous);
    }
}