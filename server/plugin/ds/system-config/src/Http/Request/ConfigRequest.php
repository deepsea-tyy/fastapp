<?php

declare(strict_types=1);


namespace Plugin\Ds\SystemConfig\Http\Request;

use Hyperf\Validation\Request\FormRequest;

class ConfigRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'group_code' => 'required',
            'key' => 'required',
            'name' => 'required',
        ];
    }

    public function attributes(): array
    {
        return [
            'group_code' => '组code',
            'key' => '配置键名',
            'name' => '配置名称',
        ];
    }
}
