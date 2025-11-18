<?php

declare(strict_types=1);


namespace Plugin\Ds\SystemConfig\Http\Request;

use Hyperf\Validation\Request\FormRequest;

/**
 * 参数配置分组表验证数据类.
 */
class ConfigGroupRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => 'required',
            'code' => 'required|string|max:255',
            'icon' => 'nullable|string|max:255',
            'remark' => 'nullable|string|max:500',
        ];
    }

    public function attributes(): array
    {
        return [
            'name' => '配置组名称',
            'code' => '配置组标识',
            'icon' => '配置组图标',
            'created_by' => '创建者',
            'remark' => '备注',
        ];
    }
}
