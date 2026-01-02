<?php

declare(strict_types=1);
namespace Plugin\Ds\Ex\Http\Admin\Request;

use App\Common\Request\Traits\ActionRulesTrait;
use Hyperf\Validation\Request\FormRequest;

class MarketPairRequest extends FormRequest
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
            'base_currency_symbol' => 'string',
            'quote_currency_symbol' => 'string',
            'market_type' => 'sometimes',
            'settlement_currency_symbol' => 'string|nullable',
            'option_type' => 'sometimes|nullable',
            'exercise_style' => 'string|nullable|in:european,american',
            'strike_price' => 'numeric|nullable',
            'expiry_date' => 'date|nullable',
            'underlying_asset_symbol' => 'string|nullable',
            'price_precision' => 'integer',
            'quantity_precision' => 'integer',
            'min_quantity' => 'numeric',
            'max_quantity' => 'numeric|nullable',
            'min_amount' => 'numeric',
            'max_amount' => 'numeric|nullable',
            'tick_size' => 'numeric|nullable',
            'step_size' => 'numeric|nullable',
            'maker_fee_rate' => 'numeric',
            'taker_fee_rate' => 'numeric',
            'leverage_enabled' => 'integer',
            'max_leverage' => 'integer|nullable',
            'maintenance_margin_rate' => 'numeric|nullable',
            'funding_rate_interval' => 'integer|nullable',
            'current_funding_rate' => 'numeric|nullable',
            'premium_index' => 'numeric|nullable',
            'interest_rate' => 'numeric|nullable',
            'funding_rate_cap' => 'numeric|nullable',
            'funding_rate_floor' => 'numeric|nullable',
            'next_funding_time' => 'date|nullable',
            'mark_price' => 'numeric|nullable',
            'contract_multiplier' => 'numeric',
            'delivery_date' => 'date|nullable',
            'price_deviation_threshold' => 'numeric|nullable',
            'status' => 'integer',
            'is_hot' => 'integer',
            'is_recommended' => 'integer',
            'category' => 'sometimes|nullable',
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
            'symbol' => trans('market_pair.symbol') ?: '交易对符号（如：BTCUSDT, BTCETH）',
            'base_currency_symbol' => trans('market_pair.base_currency_symbol') ?: '基础货币符号（关联currencies表的symbol）',
            'quote_currency_symbol' => trans('market_pair.quote_currency_symbol') ?: '计价货币符号（关联currencies表的symbol）',
            'market_type' => trans('market_pair.market_type') ?: '市场类型（spot',
            'settlement_currency_symbol' => trans('market_pair.settlement_currency_symbol') ?: '结算货币符号（合约结算币种，如USDT本位、币本位）',
            'option_type' => trans('market_pair.option_type') ?: '期权类型（call',
            'exercise_style' => trans('market_pair.exercise_style') ?: '行权方式（european:欧式, american:美式，仅期权）',
            'strike_price' => trans('market_pair.strike_price') ?: '行权价格（仅期权）',
            'expiry_date' => trans('market_pair.expiry_date') ?: '到期时间（仅期权）',
            'underlying_asset_symbol' => trans('market_pair.underlying_asset_symbol') ?: '标的资产符号（仅期权，关联currencies表的symbol）',
            'price_precision' => trans('market_pair.price_precision') ?: '价格精度（小数位数）',
            'quantity_precision' => trans('market_pair.quantity_precision') ?: '数量精度（小数位数）',
            'min_quantity' => trans('market_pair.min_quantity') ?: '最小交易数量',
            'max_quantity' => trans('market_pair.max_quantity') ?: '最大交易数量',
            'min_amount' => trans('market_pair.min_amount') ?: '最小交易金额（计价货币）',
            'max_amount' => trans('market_pair.max_amount') ?: '最大交易金额（计价货币）',
            'tick_size' => trans('market_pair.tick_size') ?: '价格步长（价格变动最小单位）',
            'step_size' => trans('market_pair.step_size') ?: '数量步长（数量变动最小单位）',
            'maker_fee_rate' => trans('market_pair.maker_fee_rate') ?: 'Maker手续费率',
            'taker_fee_rate' => trans('market_pair.taker_fee_rate') ?: 'Taker手续费率',
            'leverage_enabled' => trans('market_pair.leverage_enabled') ?: '是否支持杠杆（合约）',
            'max_leverage' => trans('market_pair.max_leverage') ?: '最大杠杆倍数（合约）',
            'maintenance_margin_rate' => trans('market_pair.maintenance_margin_rate') ?: '维持保证金率（合约）',
            'funding_rate_interval' => trans('market_pair.funding_rate_interval') ?: '资金费率结算间隔（秒，合约，通常28800秒即8小时）',
            'current_funding_rate' => trans('market_pair.current_funding_rate') ?: '当前资金费率（合约，计算公式：溢价指数 + clamp(利率 - 溢价指数, 上限, 下限)）',
            'premium_index' => trans('market_pair.premium_index') ?: '溢价指数（合约，用于计算资金费率，通常基于标记价格与现货价格差）',
            'interest_rate' => trans('market_pair.interest_rate') ?: '利率（合约，基础利率，通常0.01%即0.0001）',
            'funding_rate_cap' => trans('market_pair.funding_rate_cap') ?: '资金费率上限（合约，通常0.05%即0.0005）',
            'funding_rate_floor' => trans('market_pair.funding_rate_floor') ?: '资金费率下限（合约，通常-0.05%即-0.0005）',
            'next_funding_time' => trans('market_pair.next_funding_time') ?: '下次资金费率结算时间（合约）',
            'mark_price' => trans('market_pair.mark_price') ?: '标记价格（合约，用于计算未实现盈亏）',
            'contract_multiplier' => trans('market_pair.contract_multiplier') ?: '合约乘数（合约，交割合约使用）',
            'delivery_date' => trans('market_pair.delivery_date') ?: '交割日期（合约，交割合约使用，永续合约为NULL）',
            'price_deviation_threshold' => trans('market_pair.price_deviation_threshold') ?: '价格偏离保护阈值（百分比，如0.05表示5%，超过此阈值将暂停交易）',
            'status' => trans('market_pair.status') ?: '状态（0',
            'is_hot' => trans('market_pair.is_hot') ?: '是否热门（0',
            'is_recommended' => trans('market_pair.is_recommended') ?: '是否推荐（0',
            'category' => trans('market_pair.category') ?: '交易对分类（如：main, innovation, defi等）',
            'sort' => trans('market_pair.sort') ?: '排序',
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
