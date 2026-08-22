<?php

declare(strict_types=1);


namespace App\Http\Admin\Request\Permission;

use App\Common\Request\Traits\NoAuthorizeTrait;
use Hyperf\Validation\Request\FormRequest;

class UpdateInfoRequest extends FormRequest
{
    use NoAuthorizeTrait;

    public function rules(): array
    {
        return [
            'nickname' => 'sometimes|string|max:60',
            'avatar' => 'sometimes|string|max:255',
            'signed' => 'sometimes|string|max:255',
            'lang' => 'sometimes|string|max:8',
        ];
    }

    public function attributes(): array
    {
        return [
            'nickname' => trans('user.nickname'),
            'avatar' => trans('user.avatar'),
            'signed' => trans('user.signed'),
            'lang' => 'lang',
        ];
    }
}
