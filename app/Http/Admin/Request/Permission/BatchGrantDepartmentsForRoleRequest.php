<?php

declare(strict_types=1);


namespace App\Http\Admin\Request\Permission;

use App\Common\Request\Traits\NoAuthorizeTrait;
use Hyperf\Swagger\Annotation\Property;
use Hyperf\Swagger\Annotation\Schema;
use Hyperf\Validation\Request\FormRequest;

#[Schema(
    title: '批量授权角色部门',
    properties: [
        new Property('department_id', description: '部门ID数组', type: 'array', example: '[1,2,3]'),
    ]
)]
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
