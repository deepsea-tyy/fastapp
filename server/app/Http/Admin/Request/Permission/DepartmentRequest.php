<?php

declare(strict_types=1);


namespace App\Http\Admin\Request\Permission;

use App\Common\Request\Traits\HttpMethodTrait;
use App\Common\Request\Traits\NoAuthorizeTrait;
use App\Schema\DepartmentSchema;
use Hyperf\Validation\Request\FormRequest;

#[\App\Common\Swagger\FormRequest(
    schema: DepartmentSchema::class,
    only: [
        'name', 'code', 'parent_id', 'sort', 'status', 'remark',
    ]
)]
class DepartmentRequest extends FormRequest
{
    use HttpMethodTrait;
    use NoAuthorizeTrait;

    public function rules(): array
    {
        $rules = [
            'name' => 'required|string|max:50',
            'code' => [
                'nullable',
                'string',
                'max:50',
                'regex:/^[a-zA-Z0-9_]+$/',
            ],
            'parent_id' => 'sometimes|integer|min:0',
            'status' => 'sometimes|integer|in:1,2',
            'sort' => 'required|numeric',
            'remark' => 'nullable|string|max:255',
        ];
        if ($this->isCreate()) {
            $rules['code'][] = 'unique:department,code';
        }
        if ($this->isUpdate()) {
            $rules['code'][] = 'unique:department,code,' . $this->route('id');
        }
        return $rules;
    }

    public function attributes(): array
    {
        return [
            'name' => '部门名称',
            'code' => '部门代码',
            'parent_id' => '父部门ID',
            'status' => '状态',
            'sort' => '排序',
            'remark' => '备注',
        ];
    }
}
