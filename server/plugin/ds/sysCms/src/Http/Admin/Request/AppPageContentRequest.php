<?php

declare(strict_types=1);
namespace Plugin\Ds\SysCms\Http\Admin\Request;

use App\Common\Request\Traits\ActionRulesTrait;
use Hyperf\Validation\Request\FormRequest;

class AppPageContentRequest extends FormRequest
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
            'code' => 'sometimes|nullable|string|max:64',
            'page_code' => 'required|string|max:32',
            'component_code' => 'sometimes|nullable|string|max:32',
            'content_type' => 'required|integer|in:1,2,3,4',
            'data' => 'sometimes|nullable',
            'platform' => 'required|integer|in:1,2,3',
            'start_at' => 'sometimes|nullable|integer',
            'end_at' => 'sometimes|nullable|integer',
            'fixed' => 'required|integer|in:0,1',
            'status' => 'required|integer|in:0,1',
            'sort' => 'required|integer',
            'remark' => 'sometimes|nullable|string',
        ];
    }

    /**
     * 自动匹配create方法验证
     */
    public function createRules(): array
    {
        return [
            'code' => 'required|string|max:64|unique:app_page_content,code',
        ];
    }

    /**
     * 自动匹配save方法验证
     */
    public function saveRules(): array
    {
        $id = $this->route('id');
        return [
            'code' => 'required|string|max:64|unique:app_page_content,code,' . $id,
        ];
    }

    /**
     * 获取验证字段的自定义名称
     */
    public function attributes(): array
    {
        return [
            'code' => trans('app_page_content.code') ?: '内容标识',
            'page_code' => trans('app_page_content.page_code') ?: '页面标识',
            'component_code' => trans('app_page_content.component_code') ?: '组件标识',
            'content_type' => trans('app_page_content.content_type') ?: '内容类型',
            'data' => trans('app_page_content.data') ?: '内容数据',
            'platform' => trans('app_page_content.platform') ?: '平台',
            'start_at' => trans('app_page_content.start_at') ?: '开始时间',
            'end_at' => trans('app_page_content.end_at') ?: '结束时间',
            'fixed' => trans('app_page_content.fixed') ?: '永久有效',
            'status' => trans('app_page_content.status') ?: '状态',
            'sort' => trans('app_page_content.sort') ?: '排序',
            'remark' => trans('app_page_content.remark') ?: '备注',
        ];
    }

    /**
     * 获取验证错误的自定义消息
     */
    public function messages(): array
    {
        return [
            'code.unique' => trans('app_page_content.code_unique') ?: '内容标识已存在',
        ];
    }
}

