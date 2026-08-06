<?php

declare(strict_types=1);


namespace App\Common;

use Hyperf\Contract\Arrayable;

/**
 * @template T
 */
class Result implements Arrayable
{
    /**
     * @param T $data
     */
    public function __construct(
        public ResultCode $code = ResultCode::SUCCESS,
        public ?string    $message = null,
        public mixed      $data = null
    )
    {
        if ($this->message === null) {
            $this->message = ResultCode::getMessage($this->code->value);
        }
    }

    public function toArray(): array
    {
        return [
            'code' => $this->code->value,
            'message' => $this->message,
            'data' => $this->data ?: new \StdClass(),
        ];
    }
}
