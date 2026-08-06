<?php

declare(strict_types=1);


namespace App\Http\Admin\Request\Permission;

use App\Common\Request\Traits\NoAuthorizeTrait;
use Hyperf\Validation\Request\FormRequest;

class BatchGrantDepartmentsForRoleRequest extends FormRequest
{
    use NoAuthorizeTrait;

    public function rules(): array
    {
        return [
            'department_id' => 'sometimes|array',
            'department_id.*' => 'integer|exists:department,id',
        ];
    }

    public function attributes(): array
    {
        return [
            'department_id' => '部门ID',
        ];
    }
}
