<?php

use Hyperf\Database\Schema\Schema;
use Hyperf\Database\Schema\Blueprint;
use Hyperf\Database\Migrations\Migration;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {

        // 2. 杠杆档位配置表
        Schema::create('ex_futures_leverage_brackets', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('杠杆档位配置表');
            $table->bigIncrements('id')->comment('主键');
            $table->bigInteger('symbol')->unsigned()->comment('交易对ID');
            $table->integer('bracket')->unsigned()->comment('档位');
            $table->decimal('notional_floor', 36, 18)->default(0)->comment('名义价值下限');
            $table->decimal('notional_cap', 36, 18)->comment('名义价值上限');
            $table->integer('max_leverage')->unsigned()->comment('最大杠杆');
            $table->decimal('maintenance_margin_rate', 10, 6)->comment('维持保证金率');
            $table->decimal('maintenance_amount', 36, 18)->default(0)->comment('维持保证金额');
            $table->timestamps();

            $table->unique(['symbol', 'bracket'], 'uk_symbol_bracket');
            $table->index('symbol', 'idx_symbol');
        });

        // 3. 合约持仓表
        Schema::create('ex_futures_positions', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('合约持仓表');
            $table->bigIncrements('id')->comment('主键');
            $table->bigInteger('user_id')->unsigned()->comment('用户ID');
            $table->bigInteger('symbol')->unsigned()->comment('交易对ID');
            $table->string('position_side', 10)->comment('持仓方向 LONG多/SHORT空/BOTH双向');
            $table->string('margin_mode', 10)->comment('保证金模式 CROSS全仓/ISOLATED逐仓');
            $table->integer('leverage')->unsigned()->default(20)->comment('杠杆倍数');
            $table->decimal('quantity', 36, 18)->default(0)->comment('持仓数量(净头寸)');
            $table->decimal('entry_price', 36, 18)->default(0)->comment('开仓均价');
            $table->decimal('mark_price', 36, 18)->default(0)->comment('标记价格(最新)');
            $table->decimal('liquidation_price', 36, 18)->default(0)->comment('强平价格');
            $table->decimal('margin', 36, 18)->default(0)->comment('保证金');
            $table->decimal('isolated_margin', 36, 18)->default(0)->comment('逐仓保证金(仅逐仓)');
            $table->decimal('unrealized_pnl', 36, 18)->default(0)->comment('未实现盈亏');
            $table->decimal('realized_pnl', 36, 18)->default(0)->comment('已实现盈亏');
            $table->decimal('cumulative_funding', 36, 18)->default(0)->comment('累计资金费用');
            $table->decimal('position_value', 36, 18)->default(0)->comment('持仓价值');
            $table->decimal('maintenance_margin', 36, 18)->default(0)->comment('维持保证金');
            $table->decimal('margin_ratio', 10, 6)->default(0)->comment('保证金率');
            $table->tinyInteger('auto_add_margin')->unsigned()->default(0)->comment('自动追加保证金 0否 1是');
            $table->integer('version')->unsigned()->default(0)->comment('乐观锁版本号');
            $table->timestamps();

            $table->unique(['user_id', 'symbol', 'position_side', 'margin_mode'], 'uk_user_position');
            $table->index('user_id', 'idx_user_id');
            $table->index('symbol', 'idx_symbol');
            $table->index('margin_ratio', 'idx_margin_ratio');
        });

        // 4. 合约订单表
        Schema::create('ex_futures_orders', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('合约订单表');
            $table->bigIncrements('id')->comment('主键');
            $table->string('order_id', 50)->comment('订单ID(唯一)');
            $table->bigInteger('user_id')->unsigned()->comment('用户ID');
            $table->bigInteger('symbol')->unsigned()->comment('交易对ID');
            $table->string('client_order_id', 50)->nullable()->comment('客户端订单ID');
            $table->string('position_side', 10)->comment('持仓方向 LONG/SHORT/BOTH');
            $table->string('side', 10)->comment('订单方向 BUY/SELL');
            $table->string('type', 20)->comment('订单类型 LIMIT/MARKET/STOP/STOP_MARKET/TAKE_PROFIT/TAKE_PROFIT_MARKET/TRAILING_STOP_MARKET');
            $table->string('time_in_force', 10)->default('GTC')->comment('有效方式 GTC/IOC/FOK/GTX');
            $table->decimal('price', 36, 18)->default(0)->comment('委托价格');
            $table->decimal('quantity', 36, 18)->comment('委托数量');
            $table->decimal('stop_price', 36, 18)->default(0)->comment('触发价格');
            $table->decimal('executed_quantity', 36, 18)->default(0)->comment('已成交数量');
            $table->decimal('executed_quote_quantity', 36, 18)->default(0)->comment('已成交金额');
            $table->decimal('avg_price', 36, 18)->default(0)->comment('成交均价');
            $table->decimal('commission', 36, 18)->default(0)->comment('手续费');
            $table->string('commission_asset', 20)->nullable()->comment('手续费币种');
            $table->string('margin_mode', 10)->comment('保证金模式 CROSS/ISOLATED');
            $table->integer('leverage')->unsigned()->comment('杠杆倍数');
            $table->tinyInteger('reduce_only')->unsigned()->default(0)->comment('只减仓 0否 1是');
            $table->tinyInteger('close_position')->unsigned()->default(0)->comment('平仓单 0否 1是');
            $table->string('working_type', 20)->default('MARK_PRICE')->comment('触发价格类型 MARK_PRICE/CONTRACT_PRICE');
            $table->tinyInteger('price_protect')->unsigned()->default(0)->comment('价格保护 0否 1是');
            $table->string('status', 20)->default('NEW')->comment('订单状态 NEW/PARTIALLY_FILLED/FILLED/CANCELED/REJECTED/EXPIRED');
            $table->string('reject_reason', 255)->nullable()->comment('拒绝原因');
            $table->tinyInteger('activated')->unsigned()->default(0)->comment('已激活(条件单) 0否 1是');
            $table->timestamp('activated_at')->nullable()->comment('激活时间');
            $table->timestamp('filled_at')->nullable()->comment('完成时间');
            $table->timestamps();

            $table->unique('order_id', 'uk_order_id');
            $table->unique(['user_id', 'client_order_id'], 'uk_user_client_order')->nullable();
            $table->index(['user_id', 'symbol'], 'idx_user_symbol');
            $table->index('status', 'idx_status');
            $table->index('created_at', 'idx_created');
        });

        // 5. 合约成交记录表
        Schema::create('ex_futures_trades', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('合约成交记录表');
            $table->bigIncrements('id')->comment('主键');
            $table->string('trade_id', 50)->comment('成交ID(唯一)');
            $table->bigInteger('order_id')->unsigned()->comment('订单ID');
            $table->bigInteger('user_id')->unsigned()->comment('用户ID');
            $table->bigInteger('symbol')->unsigned()->comment('交易对ID');
            $table->string('side', 10)->comment('方向 BUY/SELL');
            $table->decimal('price', 36, 18)->comment('成交价格');
            $table->decimal('quantity', 36, 18)->comment('成交数量');
            $table->decimal('quote_quantity', 36, 18)->comment('成交金额');
            $table->decimal('commission', 36, 18)->comment('手续费');
            $table->string('commission_asset', 20)->comment('手续费币种');
            $table->decimal('realized_pnl', 36, 18)->default(0)->comment('实现盈亏');
            $table->string('margin_asset', 20)->comment('保证金币种');
            $table->tinyInteger('is_maker')->unsigned()->comment('是否Maker 0否 1是');
            $table->string('position_side', 10)->comment('持仓方向');
            $table->timestamp('created_at')->nullable()->comment('成交时间');

            $table->unique('trade_id', 'uk_trade_id');
            $table->index('order_id', 'idx_order_id');
            $table->index(['user_id', 'symbol'], 'idx_user_symbol');
            $table->index('created_at', 'idx_created');
        });

        // 6. 资金费率表
        Schema::create('ex_futures_funding_rates', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('资金费率表');
            $table->bigIncrements('id')->comment('主键');
            $table->bigInteger('symbol')->unsigned()->comment('交易对ID');
            $table->decimal('funding_rate', 10, 6)->comment('资金费率');
            $table->decimal('mark_price', 36, 18)->comment('标记价格');
            $table->decimal('index_price', 36, 18)->comment('指数价格');
            $table->timestamp('funding_time')->comment('资金费率结算时间');
            $table->timestamp('created_at')->nullable()->comment('创建时间');

            $table->unique(['symbol', 'funding_time'], 'uk_symbol_funding_time');
            $table->index('funding_time', 'idx_funding_time');
        });

        // 7. 资金费用记录表
        Schema::create('ex_futures_funding_fee_logs', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('资金费用记录表');
            $table->bigIncrements('id')->comment('主键');
            $table->bigInteger('user_id')->unsigned()->comment('用户ID');
            $table->bigInteger('symbol')->unsigned()->comment('交易对ID');
            $table->string('position_side', 10)->comment('持仓方向');
            $table->decimal('funding_rate', 10, 6)->comment('资金费率');
            $table->decimal('position_quantity', 36, 18)->comment('持仓数量');
            $table->decimal('mark_price', 36, 18)->comment('标记价格');
            $table->decimal('funding_fee', 36, 18)->comment('资金费用(正收入负支出)');
            $table->timestamp('funding_time')->comment('结算时间');
            $table->timestamp('created_at')->nullable()->comment('创建时间');

            $table->index(['user_id', 'symbol'], 'idx_user_symbol');
            $table->index('funding_time', 'idx_funding_time');
        });

        // 8. 强平记录表
        Schema::create('ex_futures_liquidations', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('强平记录表');
            $table->bigIncrements('id')->comment('主键');
            $table->bigInteger('user_id')->unsigned()->comment('用户ID');
            $table->bigInteger('symbol')->unsigned()->comment('交易对ID');
            $table->string('position_side', 10)->comment('持仓方向');
            $table->string('side', 10)->comment('强平方向 BUY/SELL');
            $table->decimal('price', 36, 18)->comment('强平价格');
            $table->decimal('quantity', 36, 18)->comment('强平数量');
            $table->decimal('liquidation_fee', 36, 18)->comment('强平手续费');
            $table->decimal('insurance_fund', 36, 18)->default(0)->comment('保险基金支出');
            $table->string('margin_mode', 10)->comment('保证金模式');
            $table->timestamp('created_at')->nullable()->comment('强平时间');

            $table->index('user_id', 'idx_user_id');
            $table->index('symbol', 'idx_symbol');
            $table->index('created_at', 'idx_created');
        });

        // 9. 合约账户配置表
        Schema::create('ex_futures_account_config', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('合约账户配置表');
            $table->bigIncrements('id')->comment('主键');
            $table->bigInteger('user_id')->unsigned()->comment('用户ID');
            $table->string('position_mode', 20)->default('ONE_WAY')->comment('持仓模式 ONE_WAY单向/HEDGE双向');
            $table->tinyInteger('multi_assets_mode')->unsigned()->default(0)->comment('多资产模式 0否 1是');
            $table->timestamps();

            $table->unique('user_id', 'uk_user_id');
        });

        // 10. 风险限额表
        Schema::create('ex_futures_risk_limits', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('风险限额表');
            $table->bigIncrements('id')->comment('主键');
            $table->bigInteger('user_id')->unsigned()->comment('用户ID');
            $table->bigInteger('symbol')->unsigned()->comment('交易对ID');
            $table->decimal('max_position_value', 36, 18)->comment('最大持仓价值');
            $table->integer('max_leverage')->unsigned()->comment('最大杠杆');
            $table->timestamps();

            $table->unique(['user_id', 'symbol'], 'uk_user_symbol');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ex_futures_risk_limits');
        Schema::dropIfExists('ex_futures_account_config');
        Schema::dropIfExists('ex_futures_liquidations');
        Schema::dropIfExists('ex_futures_funding_fee_logs');
        Schema::dropIfExists('ex_futures_funding_rates');
        Schema::dropIfExists('ex_futures_trades');
        Schema::dropIfExists('ex_futures_orders');
        Schema::dropIfExists('ex_futures_positions');
        Schema::dropIfExists('ex_futures_leverage_brackets');
        Schema::dropIfExists('ex_futures_symbols');
    }
};
