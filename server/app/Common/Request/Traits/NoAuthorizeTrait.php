<?php

declare(strict_types=1);


namespace App\Common\Request\Traits;

trait NoAuthorizeTrait
{
    public function authorize(): bool
    {
        return true;
    }
}
