<?php

declare(strict_types=1);
namespace Plugin\Ds\Ex\Http\Admin\Request;

use App\Common\Request\Traits\ActionRulesTrait;
use Hyperf\Validation\Request\FormRequest;

class ExVipRequest extends FormRequest
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
            'level' => 'required|integer|unique:ex_vip,level',
            'icon' => 'sometimes|nullable',
            'color' => 'sometimes|nullable',
            'trading_volume_usdt' => 'numeric',
            'holder_wallet_asset_usd' => 'numeric',
            'holder_platform_token' => 'numeric',
            'platform_token_currency' => 'sometimes|nullable',
            'withdraw_limit_24h_usdt' => 'numeric',
            'sort' => 'integer',
            'status' => 'integer',
            'fee_rates' => 'array|nullable',
            'privileges' => 'array|nullable',
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
            'level' => trans('ex_vip.level') ?: 'VIP等级：0=普通用户,1-9=VIP1-VIP9',
            'icon' => trans('ex_vip.icon') ?: 'VIP图标URL',
            'color' => trans('ex_vip.color') ?: 'VIP主题颜色',
            'trading_volume_usdt' => trans('ex_vip.trading_volume_usdt') ?: '交易型VIP：30天交易量（USDT）',
            'holder_wallet_asset_usd' => trans('ex_vip.holder_wallet_asset_usd') ?: '持有者计划：钱包资产（USD）',
            'holder_platform_token' => trans('ex_vip.holder_platform_token') ?: '持有者计划：平台币持有量',
            'platform_token_currency' => trans('ex_vip.platform_token_currency') ?: '平台币币种代码',
            'withdraw_limit_24h_usdt' => trans('ex_vip.withdraw_limit_24h_usdt') ?: '24小时提现额度（USDT）',
            'sort' => trans('ex_vip.sort') ?: '排序',
            'status' => trans('ex_vip.status') ?: '状态：1=启用,2=禁用',
            'fee_rates' => trans('ex_vip.fee_rates') ?: '费率配置JSON结构：{&quot;spot&quot;',
            'privileges' => trans('ex_vip.privileges') ?: 'VIP特权配置JSON结构：{&quot;api_rate_limit&quot;',
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
