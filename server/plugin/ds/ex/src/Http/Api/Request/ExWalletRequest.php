<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Http\Api\Request;

use App\Common\Request\Traits\ActionRulesTrait;
use Hyperf\Validation\Request\FormRequest;

class ExWalletRequest extends FormRequest
{
    use ActionRulesTrait;

    public function authorize(): bool
    {
        return true;
    }

    public function commonRules(): array
    {
        return [];
    }

    /**
     * 账户划转验证规则
     */
    public function transferRules(): array
    {
        return [
            'fromWalletType' => 'required|string|in:FUNDING,SPOT,FUTURES,MARGIN,EARN',
            'toWalletType' => 'required|string|in:FUNDING,SPOT,FUTURES,MARGIN,EARN',
            'symbol' => 'required|string|max:20',
            'amount' => 'required|numeric|min:0.00000001',
        ];
    }

    /**
     * 申请提现验证规则
     */
    public function withdrawRules(): array
    {
        return [
            'symbol' => 'required|string|max:20',
            'network' => 'required|string|max:50',
            'address' => 'required|string|max:255',
            'tag' => 'nullable|string|max:100',
            'amount' => 'required|numeric|min:0.00000001',
        ];
    }

    /**
     * 转账给用户验证规则
     */
    public function transferToUserRules(): array
    {
        return [
            'recipient_type' => 'required|integer|in:0,1,2',
            'recipient' => 'required|string|max:255',
            'symbol' => 'required|string|max:20',
            'amount' => 'required|numeric|min:0.00000001',
            'remark' => 'nullable|string|max:200',
        ];
    }

    public function attributes(): array
    {
        return [
            'fromWalletType' => '源钱包类型',
            'toWalletType' => '目标钱包类型',
            'symbol' => '币种',
            'amount' => '金额',
            'network' => '网络类型',
            'address' => '提现地址',
            'tag' => '标签/Memo',
            'recipient_type' => '收款方式',
            'recipient' => '收款人',
            'remark' => '备注',
        ];
    }

    public function messages(): array
    {
        return [
            '*.required' => ':attribute不能为空',
            '*.in' => ':attribute无效',
            '*.numeric' => ':attribute必须是数字',
            '*.min' => ':attribute不能小于:min',
        ];
    }
}
