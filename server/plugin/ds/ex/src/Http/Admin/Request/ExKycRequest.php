<?php

declare(strict_types=1);
namespace Plugin\Ds\Ex\Http\Admin\Request;

use App\Common\Request\Traits\ActionRulesTrait;
use Hyperf\Validation\Request\FormRequest;

class ExKycRequest extends FormRequest
{
    use ActionRulesTrait;

    public function authorize(): bool
    {
        return true;
    }

    /**
     * 通用验证规则（所有方法都会应用）
     */
    public function commonRules(): array
    {
        return [
            'user_id' => 'integer',
            'kyc_level' => 'integer',
            'country_code' => 'sometimes|nullable',
            'surname' => 'sometimes|nullable',
            'middle_name' => 'sometimes|nullable',
            'name' => 'sometimes|nullable',
            'gender' => 'integer|nullable',
            'birthday' => 'date|nullable',
            'id_type' => 'sometimes|nullable',
            'id_number_hash' => 'sometimes|nullable',
            'id_issue_date' => 'date|nullable',
            'id_expiry_date' => 'date|nullable',
            'address' => 'sometimes|nullable',
            'latitude' => 'numeric|nullable',
            'longitude' => 'numeric|nullable',
            'location_accuracy' => 'numeric|nullable',
            'location_time' => 'date|nullable',
            'location_address' => 'sometimes|nullable',
            'id_front_image' => 'sometimes|nullable',
            'id_back_image' => 'sometimes|nullable',
            'id_selfie_image' => 'sometimes|nullable',
            'address_proof_image' => 'sometimes|nullable',
            'status' => 'integer',
            'ocr_result' => 'array|nullable',
            'ocr_confidence' => 'numeric|nullable',
            'remark' => 'sometimes|nullable|string',
        ];
    }

    /**
     * 自动匹配create方法验证
     */
    public function createRules(): array
    {
        return [];
    }

    /**
     * 自动匹配save方法验证
     */
    public function saveRules(): array
    {
        return [];
    }

    /**
     * 获取验证字段的自定义名称
     */
    public function attributes(): array
    {
        return [
            'user_id' => trans('ex_kyc.user_id') ?: '用户ID',
            'kyc_level' => trans('ex_kyc.kyc_level') ?: '认证等级：1=标准认证,2=进阶认证(KYC)',
            'country_code' => trans('ex_kyc.country_code') ?: '国家/地区代码（ISO 3166-1 alpha-2）',
            'surname' => trans('ex_kyc.surname') ?: '姓',
            'middle_name' => trans('ex_kyc.middle_name') ?: '中间名',
            'name' => trans('ex_kyc.name') ?: '名字',
            'gender' => trans('ex_kyc.gender') ?: '性别：1=男,2=女,3=其他',
            'birthday' => trans('ex_kyc.birthday') ?: '出生日期',
            'id_type' => trans('ex_kyc.id_type') ?: '证件类型：ID_CARD=身份证,PASSPORT=护照,DRIVING_LICENSE=驾驶证,OTHER=其他',
            'id_number' => trans('ex_kyc.id_number') ?: '身份证件号码（加密存储）',
            'id_number_hash' => trans('ex_kyc.id_number_hash') ?: '身份证件号码哈希（用于去重）',
            'id_issue_date' => trans('ex_kyc.id_issue_date') ?: '证件签发日期',
            'id_expiry_date' => trans('ex_kyc.id_expiry_date') ?: '证件有效期',
            'address' => trans('ex_kyc.address') ?: '地址信息',
            'latitude' => trans('ex_kyc.latitude') ?: 'GPS纬度',
            'longitude' => trans('ex_kyc.longitude') ?: 'GPS经度',
            'location_accuracy' => trans('ex_kyc.location_accuracy') ?: '定位精度（米）',
            'location_time' => trans('ex_kyc.location_time') ?: '定位时间',
            'location_address' => trans('ex_kyc.location_address') ?: 'GPS反地理编码地址（根据经纬度获取的地址）',
            'id_front_image' => trans('ex_kyc.id_front_image') ?: '证件正面照片URL',
            'id_back_image' => trans('ex_kyc.id_back_image') ?: '证件背面照片URL',
            'id_selfie_image' => trans('ex_kyc.id_selfie_image') ?: '手持证件自拍照片URL',
            'address_proof_image' => trans('ex_kyc.address_proof_image') ?: '地址证明照片URL',
            'status' => trans('ex_kyc.status') ?: '审核状态：0=待审核,1=已通过,2=已拒绝,3=已取消',
            'ocr_result' => trans('ex_kyc.ocr_result') ?: 'OCR识别结果：{&quot;id_number&quot;',
            'ocr_confidence' => trans('ex_kyc.ocr_confidence') ?: 'OCR识别置信度（0-100）',
            'remark' => trans('ex_kyc.remark') ?: '备注',
        ];
    }

    /**
     * 获取验证错误的自定义消息
     */
    public function messages(): array
    {
        return [
            // 可以在这里添加自定义的错误消息
        ];
    }
}
