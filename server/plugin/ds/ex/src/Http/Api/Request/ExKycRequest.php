<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Http\Api\Request;

use App\Common\Request\Traits\ActionRulesTrait;
use Hyperf\Validation\Request\FormRequest;

class ExKycRequest extends FormRequest
{
    use ActionRulesTrait;

    public function authorize(): bool
    {
        return true;
    }

    public function commonRules(): array
    {
        return [
            'kyc_level' => 'integer|in:1,2',
            'country_code' => 'sometimes|nullable|string|max:10',
            'surname' => 'sometimes|nullable|string|max:50',
            'middle_name' => 'sometimes|nullable|string|max:50',
            'name' => 'sometimes|nullable|string|max:50',
            'gender' => 'integer|nullable|in:1,2,3',
            'birthday' => 'date|nullable',
            'id_type' => 'sometimes|nullable|string|in:ID_CARD,PASSPORT,DRIVING_LICENSE,OTHER',
            'id_number' => 'sometimes|nullable|string|max:50',
            'id_issue_date' => 'date|nullable',
            'id_expiry_date' => 'date|nullable',
            'address' => 'sometimes|nullable|string|max:500',
            'latitude' => 'numeric|nullable',
            'longitude' => 'numeric|nullable',
            'location_accuracy' => 'numeric|nullable',
            'location_time' => 'date|nullable',
            'location_address' => 'sometimes|nullable|string|max:500',
            'id_front_image' => 'sometimes|nullable|string|max:500',
            'id_back_image' => 'sometimes|nullable|string|max:500',
            'id_selfie_image' => 'sometimes|nullable|string|max:500',
            'address_proof_image' => 'sometimes|nullable|string|max:500',
        ];
    }

    public function submitRules(): array
    {
        return [
            'kyc_level' => 'required|integer|in:1,2',
            'country_code' => 'required|string|max:10',
            'surname' => 'required|string|max:50',
            'name' => 'required|string|max:50',
            'gender' => 'required|integer|in:1,2,3',
            'birthday' => 'required|date',
            'id_type' => 'required|string|in:ID_CARD,PASSPORT,DRIVING_LICENSE,OTHER',
            'id_number' => 'required|string|max:50',
            'id_issue_date' => 'required|date',
            'id_expiry_date' => 'nullable|date|after:id_issue_date',
            'address' => 'required|string|max:500',
            'id_front_image' => 'required|string|max:500',
            'id_back_image' => 'required|string|max:500',
            'id_selfie_image' => 'required|string|max:500',
        ];
    }

    public function attributes(): array
    {
        return [
            'kyc_level' => '认证等级',
            'country_code' => '国家/地区代码',
            'surname' => '姓',
            'middle_name' => '中间名',
            'name' => '名字',
            'gender' => '性别',
            'birthday' => '出生日期',
            'id_type' => '证件类型',
            'id_number' => '身份证件号码',
            'id_issue_date' => '证件签发日期',
            'id_expiry_date' => '证件有效期',
            'address' => '地址信息',
            'latitude' => 'GPS纬度',
            'longitude' => 'GPS经度',
            'location_accuracy' => '定位精度',
            'location_time' => '定位时间',
            'location_address' => 'GPS反地理编码地址',
            'id_front_image' => '证件正面照片',
            'id_back_image' => '证件背面照片',
            'id_selfie_image' => '手持证件自拍照片',
            'address_proof_image' => '地址证明照片',
        ];
    }

    public function messages(): array
    {
        return [
            '*.required' => ':attribute不能为空',
            '*.in' => ':attribute无效',
            '*.date' => ':attribute格式不正确',
            'id_expiry_date.after' => '证件有效期必须晚于签发日期',
        ];
    }
}

