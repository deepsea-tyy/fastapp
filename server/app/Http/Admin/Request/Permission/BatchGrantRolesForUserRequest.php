<?php

declare(strict_types=1);


namespace App\Http\Admin\Request\Permission;

use App\Common\Request\Traits\NoAuthorizeTrait;
use Hyperf\Validation\Request\FormRequest;

class BatchGrantRolesForUserRequest extends FormRequest
{
    use NoAuthorizeTrait;

    public function rules(): array
    {
        return [
            'role_codes' => 'required|array',
            'role_codes.*' => 'string|exists:role,code',
        ];
    }

    public function attributes(): array
    {
        return [
            'role_codes' => trans('role.code'),
        ];
    }
}
