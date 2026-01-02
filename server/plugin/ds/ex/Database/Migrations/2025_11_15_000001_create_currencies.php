<?php

declare(strict_types=1);

use Hyperf\Database\Migrations\Migration;
use Hyperf\Database\Schema\Blueprint;
use Hyperf\Database\Schema\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('currency', static function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';
            $table->comment('币种信息表');

            // 基础信息
            $table->bigIncrements('id')->comment('币种ID');
            $table->string('symbol', 20)->comment('币种符号（如：BTC, ETH, USDT）');
            $table->json('name')->nullable()->comment('币种多语言名称，格式：[{"lang": "zh_CN", "text": "比特币"}, {"lang": "en", "text": "Bitcoin"}]');
            $table->string('logo', 255)->nullable()->comment('币种图标URL');
            $table->string('chain', 50)->nullable()->comment('所属链（如：solana, bnb, eth, polygon）');
            $table->string('contract_address', 255)->nullable()->comment('合约地址（代币）');
            $table->unsignedInteger('decimals')->default(18)->comment('小数位数');
            $table->unsignedTinyInteger('type')->default(0)->comment('币种类型（0:加密货币, 1:稳定币, 2:法币）');
            $table->unsignedTinyInteger('is_base_currency')->default(0)->comment('是否可作为基础货币（0:否, 1:是）');
            $table->unsignedTinyInteger('is_quote_currency')->default(0)->comment('是否可作为计价货币（0:否, 1:是）');

            // 充提设置
            $table->unsignedTinyInteger('deposit_enabled')->default(1)->comment('是否支持充值（0:否, 1:是）');
            $table->unsignedTinyInteger('withdraw_enabled')->default(1)->comment('是否支持提现（0:否, 1:是）');
            $table->decimal('min_deposit_amount', 30, 18)->nullable()->comment('最小充值金额');
            $table->decimal('min_withdraw_amount', 30, 18)->nullable()->comment('最小提现金额');
            $table->decimal('withdraw_fee', 30, 18)->nullable()->comment('提现手续费');
            $table->string('withdraw_fee_type', 20)->default('fixed')->comment('手续费类型（fixed:固定, percent:百分比）');

            // 市值信息
            $table->decimal('market_cap', 30, 2)->nullable()->comment('市值（USD）');
            $table->unsignedInteger('market_cap_rank')->nullable()->comment('市值排名');
            $table->decimal('fully_diluted_market_cap', 30, 2)->nullable()->comment('完全稀释市值（USD）');

            // 供应量信息
            $table->decimal('circulating_supply', 30, 8)->nullable()->comment('流通供应量');
            $table->decimal('total_supply', 30, 8)->nullable()->comment('总供应量');
            $table->decimal('max_supply', 30, 8)->nullable()->comment('最大供应量（NULL表示无上限）');

            // 项目信息
            $table->date('launch_date')->nullable()->comment('上线日期');
            $table->string('consensus_algorithm', 50)->nullable()->comment('共识算法（如：PoW, PoS, DPoS）');
            $table->string('algorithm', 50)->nullable()->comment('算法类型（如：SHA-256, Ethash）');
            $table->json('description')->nullable()->comment('项目多语言描述，格式：[{"lang": "zh_CN", "text": "描述内容"}, {"lang": "en", "text": "Description"}]');
            $table->json('links')->nullable()->comment('白皮书和链接（JSON格式），格式：{"whitepaper": "url", "website": "url", "explorer": "url", "github": "url", "twitter": "url", "telegram": "url", "discord": "url", "reddit": "url", "medium": "url", "youtube": "url", "facebook": "url", "linkedin": "url"}');

            // 其他信息
            $table->json('tags')->nullable()->comment('标签（JSON数组，如：["defi", "nft", "layer1"]）');
            $table->unsignedInteger('popularity_rank')->nullable()->comment('热度排名');
            $table->unsignedInteger('trading_volume_rank')->nullable()->comment('交易量排名');
            $table->unsignedTinyInteger('status')->default(1)->comment('状态（0:禁用, 1:启用）');
            $table->unsignedTinyInteger('is_hot')->default(0)->comment('是否热门（0:否, 1:是）');
            $table->unsignedTinyInteger('is_recommended')->default(0)->comment('是否推荐（0:否, 1:是）');
            $table->unsignedInteger('sort')->default(100)->comment('排序');
            $table->timestamps();

            // 索引
            $table->unique('symbol');
            $table->index('status');
            $table->index('is_base_currency');
            $table->index('is_quote_currency');
            $table->index('market_cap_rank');
        });

        Schema::create('market_pair', static function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';
            $table->comment('交易对数据表');

            // 基础信息
            $table->bigIncrements('id')->comment('交易对ID');
            $table->string('symbol', 50)->comment('交易对符号（如：BTCUSDT, BTCETH）,期权使用结构化命名（如 BTC-250627-70000-C）');
            $table->string('base_currency_symbol', 50)->comment('基础货币符号（关联currencies表的symbol）');
            $table->string('quote_currency_symbol', 50)->comment('计价货币符号（关联currencies表的symbol）');

            // 市场类型和币本位
            $table->string('market_type', 20)->default('spot')->comment('市场类型（spot:现货, futures:合约, option:期权）');
            $table->string('settlement_currency_symbol', 50)->nullable()->comment('结算货币符号（合约结算币种，如USDT本位、币本位）');

            // 期权相关（仅期权）
            $table->string('option_type', 10)->nullable()->comment('期权类型（call:看涨, put:看跌，仅期权）');
            $table->string('exercise_style', 10)->default('european')->comment('行权方式（european:欧式, american:美式）仅期权');
            $table->decimal('strike_price', 30, 18)->nullable()->comment('行权价格（仅期权）');
            $table->dateTime('expiry_date')->nullable()->comment('到期时间（仅期权）');
            $table->string('underlying_asset_symbol', 50)->nullable()->comment('标的资产符号（仅期权，关联currencies表的symbol）');

            // 交易精度和限制
            $table->unsignedTinyInteger('price_precision')->default(2)->comment('价格精度（小数位数）');
            $table->unsignedTinyInteger('quantity_precision')->default(8)->comment('数量精度（小数位数）');
            $table->decimal('min_quantity', 30, 18)->default(0)->comment('最小交易数量');
            $table->decimal('max_quantity', 30, 18)->nullable()->comment('最大交易数量');
            $table->decimal('min_amount', 30, 18)->default(0)->comment('最小交易金额（计价货币）');
            $table->decimal('max_amount', 30, 18)->nullable()->comment('最大交易金额（计价货币）');
            $table->decimal('tick_size', 30, 18)->nullable()->comment('价格步长（价格变动最小单位）');
            $table->decimal('step_size', 30, 18)->nullable()->comment('数量步长（数量变动最小单位）');

            // 手续费
            $table->decimal('maker_fee_rate', 10, 8)->default(0.001)->comment('Maker手续费率');
            $table->decimal('taker_fee_rate', 10, 8)->default(0.001)->comment('Taker手续费率');

            // 杠杆相关（主要用于合约交易）
            $table->unsignedTinyInteger('leverage_enabled')->default(0)->comment('是否支持杠杆（0:不支持, 1:支持）');
            $table->unsignedInteger('max_leverage')->nullable()->comment('最大杠杆倍数（如：10表示10倍杠杆）');

            // 合约相关（仅合约）
            $table->decimal('maintenance_margin_rate', 10, 8)->nullable()->comment('维持保证金率（合约）');
            $table->unsignedSmallInteger('funding_rate_interval')->nullable()->comment('资金费率结算间隔（秒，合约，通常28800秒即8小时）');
            $table->decimal('current_funding_rate', 10, 8)->nullable()->comment('当前资金费率（合约，计算公式：溢价指数 + clamp(利率 - 溢价指数, 上限, 下限)）');
            $table->decimal('premium_index', 10, 8)->nullable()->comment('溢价指数（合约，用于计算资金费率，通常基于标记价格与现货价格差）');
            $table->decimal('interest_rate', 10, 8)->nullable()->comment('利率（合约，基础利率，通常0.01%即0.0001）');
            $table->decimal('funding_rate_cap', 10, 8)->nullable()->comment('资金费率上限（合约，通常0.05%即0.0005）');
            $table->decimal('funding_rate_floor', 10, 8)->nullable()->comment('资金费率下限（合约，通常-0.05%即-0.0005）');
            $table->dateTime('next_funding_time')->nullable()->comment('下次资金费率结算时间（合约）');
            $table->decimal('mark_price', 30, 18)->nullable()->comment('标记价格（合约，用于计算未实现盈亏）');
            $table->decimal('contract_multiplier', 30, 8)->default(1)->comment('合约乘数（合约，交割合约使用）');
            $table->dateTime('delivery_date')->nullable()->comment('交割日期（合约，交割合约使用，永续合约为NULL）');

            // 风险控制
            $table->decimal('price_deviation_threshold', 10, 8)->nullable()->comment('价格偏离保护阈值（百分比，如0.05表示5%，超过此阈值将暂停交易）');

            // 其他信息
            $table->unsignedTinyInteger('status')->default(1)->comment('状态（0:禁用, 1:启用）');
            $table->unsignedTinyInteger('is_hot')->default(0)->comment('是否热门（0:否, 1:是）');
            $table->unsignedTinyInteger('is_recommended')->default(0)->comment('是否推荐（0:否, 1:是）');
            $table->string('category', 50)->nullable()->comment('交易对分类（如：main, innovation, defi等）');
            $table->unsignedInteger('sort')->default(100)->comment('排序');
            $table->timestamps();

            // 索引
            $table->unique(['symbol', 'market_type']);
            $table->index('base_currency_symbol');
            $table->index('quote_currency_symbol');
            $table->index('settlement_currency_symbol');
            $table->index('underlying_asset_symbol');
            $table->index('market_type');
            $table->index('status');
        });

        Schema::create('market_ticker', static function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';
            $table->comment('行情Ticker数据表');

            // 基础信息
            $table->bigIncrements('id')->comment('ID');
            $table->string('symbol', 50)->comment('交易对符号（如：BTC/USDT）');
            $table->string('market_type', 20)->default('spot')->comment('市场类型（spot:现货, futures:合约, options:期权）');

            // 价格数据
            $table->decimal('last_price', 30, 18)->default(0)->comment('最新价格');
            $table->decimal('open_price', 30, 18)->default(0)->comment('24小时开盘价');
            $table->decimal('high_price', 30, 18)->default(0)->comment('24小时最高价');
            $table->decimal('low_price', 30, 18)->default(0)->comment('24小时最低价');

            // 成交数据
            $table->decimal('volume', 30, 8)->default(0)->comment('24小时成交量');
            $table->decimal('amount', 30, 8)->default(0)->comment('24小时成交额（计价货币）');
            $table->decimal('quote_volume', 30, 8)->nullable()->comment('24小时成交额（报价货币）');

            // 涨跌数据
            $table->decimal('change_percent', 10, 4)->default(0)->comment('24小时涨跌幅（百分比，如5.25表示5.25%）');
            $table->decimal('change_amount', 30, 18)->default(0)->comment('24小时涨跌额');

            // 买卖盘口
            $table->decimal('bid_price', 30, 18)->nullable()->comment('最佳买一价');
            $table->decimal('bid_quantity', 30, 8)->nullable()->comment('最佳买一量');
            $table->decimal('ask_price', 30, 18)->nullable()->comment('最佳卖一价');
            $table->decimal('ask_quantity', 30, 8)->nullable()->comment('最佳卖一量');

            // 合约特定数据（仅合约使用）
            $table->decimal('funding_rate', 10, 8)->nullable()->comment('当前资金费率（合约）');
            $table->decimal('open_interest', 30, 8)->nullable()->comment('持仓量（合约）');
            $table->decimal('mark_price', 30, 18)->nullable()->comment('标记价格（合约，用于计算未实现盈亏）');
            $table->decimal('index_price', 30, 18)->nullable()->comment('指数价格（合约）');
            $table->dateTime('next_funding_time')->nullable()->comment('下次资金费率结算时间（合约）');

            // 期权特定数据（仅期权使用）
            $table->string('option_type', 10)->nullable()->comment('期权类型（call:看涨, put:看跌）');
            $table->decimal('strike_price', 30, 18)->nullable()->comment('行权价格（期权）');
            $table->dateTime('expiry_date')->nullable()->comment('到期时间（期权）');
            $table->decimal('implied_volatility', 10, 4)->nullable()->comment('隐含波动率（期权）');
            $table->decimal('delta', 10, 6)->nullable()->comment('Delta（期权）');
            $table->decimal('gamma', 10, 6)->nullable()->comment('Gamma（期权）');
            $table->decimal('theta', 10, 6)->nullable()->comment('Theta（期权）');
            $table->decimal('vega', 10, 6)->nullable()->comment('Vega（期权）');

            // 其他数据
            $table->unsignedInteger('count')->nullable()->comment('24小时成交笔数');
            $table->bigInteger('timestamp')->comment('更新时间戳（毫秒）');

            // 索引
            // 唯一索引：现货和合约使用 symbol + market_type，期权需要加上 strike_price 和 expiry_date 来区分
            // 注意：对于现货和合约，strike_price 和 expiry_date 为 NULL，所以唯一性由 symbol + market_type 保证
            $table->unique(['symbol', 'market_type', 'strike_price', 'expiry_date'], 'uk_ticker_unique');
            $table->index('market_type');
            $table->index('symbol');
            $table->index('change_percent');
            $table->index('volume');
            $table->index('timestamp');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('market_ticker');
        Schema::dropIfExists('market_pair');
        Schema::dropIfExists('currency');
    }
};
