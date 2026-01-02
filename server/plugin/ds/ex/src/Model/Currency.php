<?php

declare(strict_types=1);
namespace Plugin\Ds\Ex\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * 币种信息表模型
 *
 * @property string $symbol 币种符号（如：BTC, ETH, USDT）
 * @property array $name 币种多语言名称，格式：
 * @property string $logo 币种图标URL
 * @property string $chain 所属链（如：ERC20, TRC20, BEP20）
 * @property string $contract_address 合约地址（代币）
 * @property int $decimals 小数位数
 * @property int $type 币种类型（0:加密货币, 1:稳定币, 2:法币）
 * @property int $is_base_currency 是否可作为基础货币（0:否, 1:是）
 * @property int $is_quote_currency 是否可作为计价货币（0:否, 1:是）
 * @property int $deposit_enabled 是否支持充值（0:否, 1:是）
 * @property int $withdraw_enabled 是否支持提现（0:否, 1:是）
 * @property float $min_deposit_amount 最小充值金额
 * @property float $min_withdraw_amount 最小提现金额
 * @property float $withdraw_fee 提现手续费
 * @property string $withdraw_fee_type 手续费类型（fixed:固定, percent:百分比）
 * @property float $market_cap 市值（USD）
 * @property int $market_cap_rank 市值排名
 * @property float $fully_diluted_market_cap 完全稀释市值（USD）
 * @property float $circulating_supply 流通供应量
 * @property float $total_supply 总供应量
 * @property float $max_supply 最大供应量（NULL表示无上限）
 * @property \Carbon\Carbon $launch_date 上线日期
 * @property string $consensus_algorithm 共识算法（如：PoW, PoS, DPoS）
 * @property string $algorithm 算法类型（如：SHA-256, Ethash）
 * @property array $description 项目多语言描述，格式：
 * @property array $links 白皮书和链接（JSON格式），格式：{"whitepaper": "url", "website": "url", "explorer": "url", "github": "url", "twitter": "url", "telegram": "url", "discord": "url", "reddit": "url", "medium": "url", "youtube": "url", "facebook": "url", "linkedin": "url"}
 * @property array $tags 标签（JSON数组，如：）
 * @property int $popularity_rank 热度排名
 * @property int $trading_volume_rank 交易量排名
 * @property int $status 状态（0:禁用, 1:启用）
 * @property int $is_hot 是否热门（0:否, 1:是）
 * @property int $is_recommended 是否推荐（0:否, 1:是）
 * @property int $sort 排序
 * @property \Carbon\Carbon $created_at 创建时间
 * @property \Carbon\Carbon $updated_at 更新时间
 */
class Currency extends Model
{
    protected ?string $table = 'currency';

    protected array $fillable = [
        'symbol',
        'name',
        'logo',
        'chain',
        'contract_address',
        'decimals',
        'type',
        'is_base_currency',
        'is_quote_currency',
        'deposit_enabled',
        'withdraw_enabled',
        'min_deposit_amount',
        'min_withdraw_amount',
        'withdraw_fee',
        'withdraw_fee_type',
        'market_cap',
        'market_cap_rank',
        'fully_diluted_market_cap',
        'circulating_supply',
        'total_supply',
        'max_supply',
        'launch_date',
        'consensus_algorithm',
        'algorithm',
        'description',
        'links',
        'tags',
        'popularity_rank',
        'trading_volume_rank',
        'status',
        'is_hot',
        'is_recommended',
        'sort',
        'created_at',
        'updated_at',
    ];

    protected array $casts = [
        'symbol' => 'string',
        'name' => 'array',
        'logo' => 'string',
        'chain' => 'string',
        'contract_address' => 'string',
        'decimals' => 'integer',
        'type' => 'integer',
        'is_base_currency' => 'integer',
        'is_quote_currency' => 'integer',
        'deposit_enabled' => 'integer',
        'withdraw_enabled' => 'integer',
        'min_deposit_amount' => 'decimal:2',
        'min_withdraw_amount' => 'decimal:2',
        'withdraw_fee' => 'decimal:2',
        'withdraw_fee_type' => 'string',
        'market_cap' => 'decimal:2',
        'market_cap_rank' => 'integer',
        'fully_diluted_market_cap' => 'decimal:2',
        'circulating_supply' => 'decimal:2',
        'total_supply' => 'decimal:2',
        'max_supply' => 'decimal:2',
        'launch_date' => 'date',
        'consensus_algorithm' => 'string',
        'algorithm' => 'string',
        'description' => 'array',
        'links' => 'array',
        'tags' => 'array',
        'popularity_rank' => 'integer',
        'trading_volume_rank' => 'integer',
        'status' => 'integer',
        'is_hot' => 'integer',
        'is_recommended' => 'integer',
        'sort' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];
    protected array $hidden = [];
}
