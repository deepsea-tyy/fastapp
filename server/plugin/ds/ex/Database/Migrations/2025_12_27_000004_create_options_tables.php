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

        // 2. 期权持仓表
        Schema::create('ex_options_positions', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('期权持仓表');
            $table->bigIncrements('id')->comment('主键');
            $table->bigInteger('user_id')->unsigned()->comment('用户ID');
            $table->bigInteger('contract_id')->unsigned()->comment('合约ID');
            $table->string('position_side', 10)->comment('持仓方向 LONG买方/SHORT卖方');
            $table->decimal('quantity', 36, 18)->default(0)->comment('持仓数量');
            $table->decimal('entry_price', 36, 18)->comment('开仓均价(期权费)');
            $table->decimal('mark_price', 36, 18)->default(0)->comment('标记价格(最新期权价)');
            $table->decimal('margin', 36, 18)->default(0)->comment('保证金(仅卖方)');
            $table->decimal('unrealized_pnl', 36, 18)->default(0)->comment('未实现盈亏');
            $table->decimal('realized_pnl', 36, 18)->default(0)->comment('已实现盈亏');
            $table->decimal('delta', 10, 6)->default(0)->comment('Delta值');
            $table->decimal('gamma', 10, 6)->default(0)->comment('Gamma值');
            $table->decimal('theta', 10, 6)->default(0)->comment('Theta值');
            $table->decimal('vega', 10, 6)->default(0)->comment('Vega值');
            $table->decimal('implied_volatility', 10, 6)->default(0)->comment('隐含波动率');
            $table->tinyInteger('can_exercise')->unsigned()->default(0)->comment('是否可行权 0否 1是');
            $table->tinyInteger('auto_exercise')->unsigned()->default(1)->comment('自动行权 0否 1是');
            $table->integer('version')->unsigned()->default(0)->comment('乐观锁版本号');
            $table->timestamps();

            $table->unique(['user_id', 'contract_id', 'position_side'], 'uk_user_contract_side');
            $table->index('user_id', 'idx_user_id');
            $table->index('contract_id', 'idx_contract_id');
        });

        // 3. 期权订单表
        Schema::create('ex_options_orders', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('期权订单表');
            $table->bigIncrements('id')->comment('主键');
            $table->string('order_id', 50)->comment('订单ID(唯一)');
            $table->bigInteger('user_id')->unsigned()->comment('用户ID');
            $table->bigInteger('contract_id')->unsigned()->comment('合约ID');
            $table->string('client_order_id', 50)->nullable()->comment('客户端订单ID');
            $table->string('side', 10)->comment('方向 BUY/SELL');
            $table->string('type', 20)->comment('订单类型 LIMIT/MARKET/STOP');
            $table->string('time_in_force', 10)->default('GTC')->comment('有效方式 GTC/IOC/FOK');
            $table->decimal('price', 36, 18)->default(0)->comment('委托价格(期权费)');
            $table->decimal('quantity', 36, 18)->comment('委托数量');
            $table->decimal('executed_quantity', 36, 18)->default(0)->comment('已成交数量');
            $table->decimal('executed_premium', 36, 18)->default(0)->comment('已成交期权费总额');
            $table->decimal('avg_price', 36, 18)->default(0)->comment('成交均价');
            $table->decimal('commission', 36, 18)->default(0)->comment('手续费');
            $table->string('commission_asset', 20)->nullable()->comment('手续费币种');
            $table->tinyInteger('reduce_only')->unsigned()->default(0)->comment('只减仓 0否 1是');
            $table->string('status', 20)->default('NEW')->comment('订单状态 NEW/PARTIALLY_FILLED/FILLED/CANCELED/REJECTED/EXPIRED');
            $table->string('reject_reason', 255)->nullable()->comment('拒绝原因');
            $table->timestamp('filled_at')->nullable()->comment('完成时间');
            $table->timestamps();

            $table->unique('order_id', 'uk_order_id');
            $table->unique(['user_id', 'client_order_id'], 'uk_user_client_order')->nullable();
            $table->index(['user_id', 'contract_id'], 'idx_user_contract');
            $table->index('status', 'idx_status');
            $table->index('created_at', 'idx_created');
        });

        // 4. 期权成交记录表
        Schema::create('ex_options_trades', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('期权成交记录表');
            $table->bigIncrements('id')->comment('主键');
            $table->string('trade_id', 50)->comment('成交ID(唯一)');
            $table->bigInteger('order_id')->unsigned()->comment('订单ID');
            $table->bigInteger('user_id')->unsigned()->comment('用户ID');
            $table->bigInteger('contract_id')->unsigned()->comment('合约ID');
            $table->string('side', 10)->comment('方向 BUY/SELL');
            $table->decimal('price', 36, 18)->comment('成交价格(期权费)');
            $table->decimal('quantity', 36, 18)->comment('成交数量');
            $table->decimal('premium', 36, 18)->comment('期权费总额');
            $table->decimal('commission', 36, 18)->comment('手续费');
            $table->string('commission_asset', 20)->comment('手续费币种');
            $table->tinyInteger('is_maker')->unsigned()->comment('是否Maker 0否 1是');
            $table->decimal('underlying_price', 36, 18)->comment('标的资产价格');
            $table->decimal('implied_volatility', 10, 6)->default(0)->comment('隐含波动率');
            $table->timestamp('created_at')->nullable()->comment('成交时间');

            $table->unique('trade_id', 'uk_trade_id');
            $table->index('order_id', 'idx_order_id');
            $table->index(['user_id', 'contract_id'], 'idx_user_contract');
            $table->index('created_at', 'idx_created');
        });

        // 5. 期权行权记录表
        Schema::create('ex_options_exercises', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('期权行权记录表');
            $table->bigIncrements('id')->comment('主键');
            $table->string('exercise_id', 50)->comment('行权ID');
            $table->bigInteger('user_id')->unsigned()->comment('用户ID');
            $table->bigInteger('contract_id')->unsigned()->comment('合约ID');
            $table->decimal('quantity', 36, 18)->comment('行权数量');
            $table->decimal('strike_price', 36, 18)->comment('行权价格');
            $table->decimal('settlement_price', 36, 18)->comment('结算价格(标的价格)');
            $table->decimal('settlement_amount', 36, 18)->comment('结算金额');
            $table->decimal('pnl', 36, 18)->comment('盈亏');
            $table->string('exercise_type', 20)->comment('行权类型 MANUAL手动/AUTO自动');
            $table->timestamp('exercise_time')->comment('行权时间');
            $table->timestamp('created_at')->nullable()->comment('创建时间');

            $table->unique('exercise_id', 'uk_exercise_id');
            $table->index(['user_id', 'contract_id'], 'idx_user_contract');
            $table->index('exercise_time', 'idx_exercise_time');
        });

        // 6. 期权结算记录表
        Schema::create('ex_options_settlements', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('期权结算记录表');
            $table->bigIncrements('id')->comment('主键');
            $table->bigInteger('contract_id')->unsigned()->comment('合约ID');
            $table->bigInteger('user_id')->unsigned()->comment('用户ID');
            $table->string('position_side', 10)->comment('持仓方向');
            $table->decimal('quantity', 36, 18)->comment('结算数量');
            $table->decimal('entry_price', 36, 18)->comment('开仓均价');
            $table->decimal('settlement_price', 36, 18)->comment('结算价格');
            $table->decimal('intrinsic_value', 36, 18)->comment('内在价值');
            $table->decimal('settlement_amount', 36, 18)->comment('结算金额');
            $table->decimal('realized_pnl', 36, 18)->comment('已实现盈亏');
            $table->timestamp('settlement_time')->comment('结算时间');
            $table->timestamp('created_at')->nullable()->comment('创建时间');

            $table->index('contract_id', 'idx_contract_id');
            $table->index('user_id', 'idx_user_id');
            $table->index('settlement_time', 'idx_settlement_time');
        });

        // 7. 期权定价表
        Schema::create('ex_options_pricing', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('期权定价表');
            $table->bigIncrements('id')->comment('主键');
            $table->bigInteger('contract_id')->unsigned()->comment('合约ID');
            $table->decimal('underlying_price', 36, 18)->comment('标的价格');
            $table->decimal('theoretical_price', 36, 18)->comment('理论价格(BS模型)');
            $table->decimal('mark_price', 36, 18)->comment('标记价格');
            $table->decimal('intrinsic_value', 36, 18)->comment('内在价值');
            $table->decimal('time_value', 36, 18)->comment('时间价值');
            $table->decimal('implied_volatility', 10, 6)->comment('隐含波动率');
            $table->decimal('delta', 10, 6)->comment('Delta');
            $table->decimal('gamma', 10, 6)->comment('Gamma');
            $table->decimal('theta', 10, 6)->comment('Theta');
            $table->decimal('vega', 10, 6)->comment('Vega');
            $table->decimal('rho', 10, 6)->comment('Rho');
            $table->integer('days_to_expiry')->unsigned()->comment('距到期天数');
            $table->decimal('bid_price', 36, 18)->default(0)->comment('买一价');
            $table->decimal('ask_price', 36, 18)->default(0)->comment('卖一价');
            $table->decimal('bid_iv', 10, 6)->default(0)->comment('买一隐含波动率');
            $table->decimal('ask_iv', 10, 6)->default(0)->comment('卖一隐含波动率');
            $table->timestamp('updated_at')->nullable()->comment('更新时间');

            $table->unique('contract_id', 'uk_contract_id');
            $table->index('updated_at', 'idx_updated');
        });

        // 8. 波动率表
        Schema::create('ex_options_volatility', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('波动率表');
            $table->bigIncrements('id')->comment('主键');
            $table->string('underlying_asset', 20)->comment('标的资产');
            $table->string('period', 10)->comment('周期 7d/30d/90d');
            $table->decimal('historical_volatility', 10, 6)->comment('历史波动率');
            $table->decimal('realized_volatility', 10, 6)->comment('已实现波动率');
            $table->decimal('implied_volatility', 10, 6)->comment('隐含波动率(ATM期权)');
            $table->date('stat_date')->comment('统计日期');
            $table->timestamp('created_at')->nullable()->comment('创建时间');

            $table->unique(['underlying_asset', 'period', 'stat_date'], 'uk_asset_period_date');
            $table->index('stat_date', 'idx_stat_date');
        });

        // 9. 期权保证金配置表
        Schema::create('ex_options_margin_config', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('期权保证金配置表');
            $table->bigIncrements('id')->comment('主键');
            $table->string('underlying_asset', 20)->comment('标的资产');
            $table->string('option_type', 10)->comment('期权类型 CALL/PUT');
            $table->decimal('initial_margin_rate', 10, 6)->comment('初始保证金率');
            $table->decimal('maintenance_margin_rate', 10, 6)->comment('维持保证金率');
            $table->decimal('short_otm_discount', 10, 6)->default(0)->comment('价外期权折扣');
            $table->timestamps();

            $table->unique(['underlying_asset', 'option_type'], 'uk_asset_type');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ex_options_margin_config');
        Schema::dropIfExists('ex_options_volatility');
        Schema::dropIfExists('ex_options_pricing');
        Schema::dropIfExists('ex_options_settlements');
        Schema::dropIfExists('ex_options_exercises');
        Schema::dropIfExists('ex_options_trades');
        Schema::dropIfExists('ex_options_orders');
        Schema::dropIfExists('ex_options_positions');
        Schema::dropIfExists('ex_options_contracts');
    }
};
