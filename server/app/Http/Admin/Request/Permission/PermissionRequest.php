<?php

declare(strict_types=1);


namespace App\Http\Admin\Request\Permission;

use App\Common\Request\Traits\NoAuthorizeTrait;
use Hyperf\Validation\Request\FormRequest;

class PermissionRequest extends FormRequest
{
    use NoAuthorizeTrait;

    public function rules(): array
    {
        return [
            'nickname' => 'sometimes|string|max:255',
            'new_password' => 'sometimes|confirmed|string|min:8',
            'new_password_confirmation' => 'sometimes|string|min:8',
            'old_password' => ['sometimes', 'string'],
            'avatar' => 'sometimes|string|max:255',
            'signed' => 'sometimes|string|max:255',
        ];
    }

    public function attributes(): array
    {
        return [
            'nickname' => trans('user.nickname'),
            'new_password' => trans('user.password'),
            'new_password_confirmation' => trans('user.password_confirmation'),
            'old_password' => trans('user.old_password'),
            'avatar' => trans('user.avatar'),
            'signed' => trans('user.signed'),
        ];
    }
}
