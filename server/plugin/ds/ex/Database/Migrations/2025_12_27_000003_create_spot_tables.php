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
        // 1. 现货订单表
        Schema::create('ex_spot_orders', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('现货订单表');
            $table->bigIncrements('id')->comment('主键');
            $table->string('order_id', 50)->comment('订单ID(唯一)');
            $table->bigInteger('user_id')->unsigned()->comment('用户ID');
            $table->bigInteger('symbol')->unsigned()->comment('交易对ID');
            $table->string('client_order_id', 50)->nullable()->comment('客户端订单ID');
            $table->string('side', 10)->comment('方向 BUY/SELL');
            $table->string('type', 20)->comment('订单类型 LIMIT/MARKET/STOP_LOSS/STOP_LOSS_LIMIT/TAKE_PROFIT/TAKE_PROFIT_LIMIT');
            $table->string('time_in_force', 10)->default('GTC')->comment('有效方式 GTC/IOC/FOK/GTX');
            $table->decimal('price', 36, 18)->default(0)->comment('委托价格');
            $table->decimal('quantity', 36, 18)->default(0)->comment('委托数量');
            $table->decimal('quote_quantity', 36, 18)->default(0)->comment('委托金额(市价买入用)');
            $table->decimal('stop_price', 36, 18)->default(0)->comment('触发价格');
            $table->decimal('iceberg_quantity', 36, 18)->default(0)->comment('冰山订单显示数量');
            $table->decimal('executed_quantity', 36, 18)->default(0)->comment('已成交数量');
            $table->decimal('executed_quote_quantity', 36, 18)->default(0)->comment('已成交金额');
            $table->decimal('avg_price', 36, 18)->default(0)->comment('成交均价');
            $table->decimal('commission', 36, 18)->default(0)->comment('手续费');
            $table->string('commission_asset', 20)->nullable()->comment('手续费币种');
            $table->string('status', 20)->default('NEW')->comment('订单状态 NEW/PARTIALLY_FILLED/FILLED/CANCELED/REJECTED/EXPIRED');
            $table->string('reject_reason', 255)->nullable()->comment('拒绝原因');
            $table->tinyInteger('is_working')->unsigned()->default(0)->comment('是否在订单簿中 0否 1是');
            $table->timestamp('working_time')->nullable()->comment('进入订单簿时间');
            $table->timestamp('filled_at')->nullable()->comment('完成时间');
            $table->timestamps();

            $table->unique('order_id', 'uk_order_id');
            $table->unique(['user_id', 'client_order_id'], 'uk_user_client_order')->nullable();
            $table->index(['user_id', 'symbol'], 'idx_user_symbol');
            $table->index('status', 'idx_status');
            $table->index('is_working', 'idx_is_working');
            $table->index('created_at', 'idx_created');
        });

        // 2. 现货成交记录表
        Schema::create('ex_spot_trades', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('现货成交记录表');
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
            $table->tinyInteger('is_maker')->unsigned()->comment('是否Maker 0否 1是');
            $table->tinyInteger('is_buyer')->unsigned()->comment('是否买方 0否 1是');
            $table->bigInteger('match_order_id')->unsigned()->nullable()->comment('对手订单ID');
            $table->bigInteger('match_user_id')->unsigned()->nullable()->comment('对手用户ID');
            $table->timestamp('created_at')->nullable()->comment('成交时间');

            $table->unique('trade_id', 'uk_trade_id');
            $table->index('order_id', 'idx_order_id');
            $table->index(['user_id', 'symbol'], 'idx_user_symbol');
            $table->index('created_at', 'idx_created');
        });

        // 3. 用户交易统计表
        Schema::create('ex_spot_user_stats', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('用户交易统计表');
            $table->bigIncrements('id')->comment('主键');
            $table->bigInteger('user_id')->unsigned()->comment('用户ID');
            $table->date('stat_date')->comment('统计日期');
            $table->integer('trade_count')->unsigned()->default(0)->comment('成交笔数');
            $table->decimal('buy_volume', 36, 18)->default(0)->comment('买入量');
            $table->decimal('sell_volume', 36, 18)->default(0)->comment('卖出量');
            $table->decimal('total_volume', 36, 18)->default(0)->comment('总交易量(USDT计价)');
            $table->decimal('total_commission', 36, 18)->default(0)->comment('总手续费');
            $table->decimal('maker_volume', 36, 18)->default(0)->comment('Maker交易量');
            $table->decimal('taker_volume', 36, 18)->default(0)->comment('Taker交易量');
            $table->timestamp('created_at')->nullable()->comment('创建时间');

            $table->unique(['user_id', 'stat_date'], 'uk_user_date');
            $table->index('stat_date', 'idx_stat_date');
        });

        // 4. 交易限制表
        Schema::create('ex_spot_trade_limits', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('交易限制表');
            $table->bigIncrements('id')->comment('主键');
            $table->bigInteger('user_id')->unsigned()->comment('用户ID');
            $table->string('symbol', 16)->nullable()->comment('交易对符号(null表示全局)');
            $table->decimal('max_order_quantity', 36, 18)->nullable()->comment('单笔最大数量');
            $table->decimal('max_order_notional', 36, 18)->nullable()->comment('单笔最大金额');
            $table->decimal('daily_buy_limit', 36, 18)->nullable()->comment('每日买入限额');
            $table->decimal('daily_sell_limit', 36, 18)->nullable()->comment('每日卖出限额');
            $table->tinyInteger('is_trading_enabled')->unsigned()->default(1)->comment('是否允许交易 0否 1是');
            $table->timestamps();

            $table->unique(['user_id', 'symbol'], 'uk_user_symbol');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ex_spot_trade_limits');
        Schema::dropIfExists('ex_spot_user_stats');
        Schema::dropIfExists('ex_spot_trades');
        Schema::dropIfExists('ex_spot_orders');
    }
};
