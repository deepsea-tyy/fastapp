<?php

declare(strict_types=1);


namespace App\Http\Admin\Request\Permission;

use App\Common\Request\Traits\HttpMethodTrait;
use App\Common\Request\Traits\NoAuthorizeTrait;
use App\Schema\RoleSchema;
use Hyperf\Validation\Request\FormRequest;

#[\App\Common\Swagger\FormRequest(
    schema: RoleSchema::class,
    only: [
        'name', 'code', 'data_scope', 'status', 'sort', 'remark', 'dept_id',
    ]
)]
class RoleRequest extends FormRequest
{
    use HttpMethodTrait;
    use NoAuthorizeTrait;

    public function rules(): array
    {
        $rules = [
            'name' => 'required|string|max:60',
            'code' => [
                'required',
                'string',
                'max:60',
                'regex:/^[a-zA-Z0-9_]+$/',
            ],
            'data_scope' => 'nullable|integer|in:1,2,3,4,5',
            'status' => 'sometimes|integer|in:1,2',
            'sort' => 'required|integer',
            'remark' => 'nullable|string|max:255',
            'dept_id' => 'nullable|array',
            'dept_id.*' => 'integer|exists:department,id',
        ];
        if ($this->isCreate()) {
            $rules['code'][] = 'unique:role,code';
        }
        if ($this->isUpdate()) {
            $rules['code'][] = 'unique:role,code,' . $this->route('id');
        }
        return $rules;
    }

    public function attributes(): array
    {
        return [
            'name' => trans('role.name'),
            'code' => trans('role.code'),
            'data_scope' => trans('role.data_scope'),
            'status' => trans('role.status'),
            'sort' => trans('role.sort'),
            'remark' => trans('role.remark'),
            'dept_id' => trans('role.dept_id'),
        ];
    }
}
