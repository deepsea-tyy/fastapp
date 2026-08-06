<?php

declare(strict_types=1);


namespace App\Http\Admin\Request\Permission;

use App\Common\Request\Traits\NoAuthorizeTrait;
use Hyperf\Validation\Request\FormRequest;

class UserRequest extends FormRequest
{
    use NoAuthorizeTrait;

    public function rules(): array
    {
        return [
            'username' => 'required|string|max:20',
            'user_type' => 'required|integer',
            'nickname' => ['required', 'string', 'max:60', 'regex:/^[^\s]+$/'],
            'phone' => 'nullable|sometimes|string|max:12',
            'email' => 'nullable|sometimes|string|max:60|email:rfc,dns',
            'avatar' => 'nullable|sometimes|string|max:255',
            'signed' => 'nullable|sometimes|string|max:255',
            'status' => 'nullable|sometimes|integer',
            'remark' => 'nullable|sometimes|string|max:255',
            'password' => 'nullable|sometimes|string|min:6|max:20',
        ];
    }

    public function attributes(): array
    {
        return [
            'username' => trans('user.username'),
            'user_type' => trans('user.user_type'),
            'nickname' => trans('user.nickname'),
            'phone' => trans('user.phone'),
            'email' => trans('user.email'),
            'avatar' => trans('user.avatar'),
            'signed' => trans('user.signed'),
            'status' => trans('user.status'),
            'created_by' => trans('user.created_by'),
            'remark' => trans('user.remark'),
            'password' => trans('user.password'),
        ];
    }
}
