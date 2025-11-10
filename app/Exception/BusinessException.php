<?php

declare(strict_types=1);


namespace App\Exception;

use App\Common\Result;
use App\Common\ResultCode;

class BusinessException extends \RuntimeException
{
    private Result $response;

    public function __construct(ResultCode $code = ResultCode::FAIL, ?string $message = null, mixed $data = [])
    {
        $this->response = new Result($code, $message, $data);
        parent::__construct();
    }

    public function getResponse(): Result
    {
        return $this->response;
    }
}
