<?php

declare(strict_types=1);
namespace Plugin\Ds\Ex\Http\Admin\Request;

use App\Common\Request\Traits\ActionRulesTrait;
use Hyperf\Validation\Request\FormRequest;

class CurrencyRequest extends FormRequest
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
            'symbol' => 'sometimes',
            'name' => 'array|nullable',
            'logo' => 'sometimes|nullable',
            'chain' => 'sometimes|nullable',
            'contract_address' => 'sometimes|nullable',
            'decimals' => 'integer',
            'type' => 'integer|in:0,1,2',
            'is_base_currency' => 'integer',
            'is_quote_currency' => 'integer',
            'deposit_enabled' => 'integer',
            'withdraw_enabled' => 'integer',
            'min_deposit_amount' => 'numeric|nullable',
            'min_withdraw_amount' => 'numeric|nullable',
            'withdraw_fee' => 'numeric|nullable',
            'withdraw_fee_type' => 'sometimes',
            'market_cap' => 'numeric|nullable',
            'market_cap_rank' => 'integer|nullable',
            'fully_diluted_market_cap' => 'numeric|nullable',
            'circulating_supply' => 'numeric|nullable',
            'total_supply' => 'numeric|nullable',
            'max_supply' => 'numeric|nullable',
            'launch_date' => 'date|nullable',
            'consensus_algorithm' => 'sometimes|nullable',
            'algorithm' => 'sometimes|nullable',
            'description' => 'array|nullable',
            'links' => 'array|nullable',
            'tags' => 'array|nullable',
            'popularity_rank' => 'integer|nullable',
            'trading_volume_rank' => 'integer|nullable',
            'status' => 'integer',
            'is_hot' => 'integer',
            'is_recommended' => 'integer',
            'sort' => 'integer',
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
            'symbol' => trans('currency.symbol') ?: '币种符号（如：BTC, ETH, USDT）',
            'name' => trans('currency.name') ?: '币种多语言名称，格式：',
            'logo' => trans('currency.logo') ?: '币种图标URL',
            'chain' => trans('currency.chain') ?: '所属链（如：ERC20, TRC20, BEP20）',
            'contract_address' => trans('currency.contract_address') ?: '合约地址（代币）',
            'decimals' => trans('currency.decimals') ?: '小数位数',
            'type' => trans('currency.type') ?: '币种类型（0:加密货币, 1:稳定币, 2:法币）',
            'is_base_currency' => trans('currency.is_base_currency') ?: '是否可作为基础货币（0',
            'is_quote_currency' => trans('currency.is_quote_currency') ?: '是否可作为计价货币（0',
            'deposit_enabled' => trans('currency.deposit_enabled') ?: '是否支持充值（0',
            'withdraw_enabled' => trans('currency.withdraw_enabled') ?: '是否支持提现（0',
            'min_deposit_amount' => trans('currency.min_deposit_amount') ?: '最小充值金额',
            'min_withdraw_amount' => trans('currency.min_withdraw_amount') ?: '最小提现金额',
            'withdraw_fee' => trans('currency.withdraw_fee') ?: '提现手续费',
            'withdraw_fee_type' => trans('currency.withdraw_fee_type') ?: '手续费类型（fixed',
            'market_cap' => trans('currency.market_cap') ?: '市值（USD）',
            'market_cap_rank' => trans('currency.market_cap_rank') ?: '市值排名',
            'fully_diluted_market_cap' => trans('currency.fully_diluted_market_cap') ?: '完全稀释市值（USD）',
            'circulating_supply' => trans('currency.circulating_supply') ?: '流通供应量',
            'total_supply' => trans('currency.total_supply') ?: '总供应量',
            'max_supply' => trans('currency.max_supply') ?: '最大供应量（NULL表示无上限）',
            'launch_date' => trans('currency.launch_date') ?: '上线日期',
            'consensus_algorithm' => trans('currency.consensus_algorithm') ?: '共识算法（如：PoW, PoS, DPoS）',
            'algorithm' => trans('currency.algorithm') ?: '算法类型（如：SHA-256, Ethash）',
            'description' => trans('currency.description') ?: '项目多语言描述，格式：',
            'links' => trans('currency.links') ?: '白皮书和链接（JSON格式），格式：{&quot;whitepaper&quot;',
            'tags' => trans('currency.tags') ?: '标签（JSON数组，如：）',
            'popularity_rank' => trans('currency.popularity_rank') ?: '热度排名',
            'trading_volume_rank' => trans('currency.trading_volume_rank') ?: '交易量排名',
            'status' => trans('currency.status') ?: '状态（0',
            'is_hot' => trans('currency.is_hot') ?: '是否热门（0',
            'is_recommended' => trans('currency.is_recommended') ?: '是否推荐（0',
            'sort' => trans('currency.sort') ?: '排序',
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
