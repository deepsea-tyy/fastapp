<?php

use Hyperf\Database\Schema\Schema;
use Hyperf\Database\Schema\Blueprint;
use Hyperf\Database\Migrations\Migration;

return new class extends Migration {
    /**
     * Run the migrations.
     * 创建K线数据表（现货和合约）
     * 参考币安API设计，支持多时间周期
     */
    public function up(): void
    {
        // 1. 现货K线数据表（如果已存在则跳过）
        if (!Schema::hasTable('ex_spot_klines')) {
            Schema::create('ex_spot_klines', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('现货K线数据表');
            $table->bigIncrements('id')->comment('主键');
            $table->string('symbol', 16)->comment('交易对符号（如BTCUSDT）');
            $table->string('interval', 10)->comment('时间间隔 1m/3m/5m/15m/30m/1h/2h/4h/6h/8h/12h/1d/3d/1w/1M');
            $table->timestamp('open_time')->comment('开盘时间');
            $table->decimal('open_price', 36, 18)->comment('开盘价');
            $table->decimal('high_price', 36, 18)->comment('最高价');
            $table->decimal('low_price', 36, 18)->comment('最低价');
            $table->decimal('close_price', 36, 18)->comment('收盘价');
            $table->decimal('volume', 36, 18)->comment('成交量（基础币种）');
            $table->timestamp('close_time')->comment('收盘时间');
            $table->decimal('quote_volume', 36, 18)->comment('成交额（计价币种）');
            $table->integer('trade_count')->unsigned()->default(0)->comment('成交笔数');
            $table->decimal('taker_buy_volume', 36, 18)->default(0)->comment('主动买入成交量（基础币种）');
            $table->decimal('taker_buy_quote_volume', 36, 18)->default(0)->comment('主动买入成交额（计价币种）');
            $table->timestamps();

            // 唯一索引：同一交易对、同一时间周期、同一开盘时间只能有一条记录
            $table->unique(['symbol', 'interval', 'open_time'], 'uk_spot_symbol_interval_time');
            // 复合索引：用于查询指定交易对和时间周期的K线数据
            $table->index(['symbol', 'interval'], 'idx_spot_symbol_interval');
            // 时间索引：用于按时间范围查询
            $table->index('open_time', 'idx_spot_open_time');
            // 收盘时间索引：用于按收盘时间查询
            $table->index('close_time', 'idx_spot_close_time');
            });
        }

        // 2. 合约K线数据表
        Schema::create('ex_futures_klines', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('合约K线数据表');
            $table->bigIncrements('id')->comment('主键');
            $table->bigInteger('symbol')->unsigned()->comment('交易对ID（关联ex_futures_symbols或market_pair）');
            $table->string('interval', 10)->comment('时间间隔 1m/3m/5m/15m/30m/1h/2h/4h/6h/8h/12h/1d/3d/1w/1M');
            $table->timestamp('open_time')->comment('开盘时间');
            $table->decimal('open_price', 36, 18)->comment('开盘价');
            $table->decimal('high_price', 36, 18)->comment('最高价');
            $table->decimal('low_price', 36, 18)->comment('最低价');
            $table->decimal('close_price', 36, 18)->comment('收盘价');
            $table->decimal('volume', 36, 18)->comment('成交量（合约数量）');
            $table->timestamp('close_time')->comment('收盘时间');
            $table->decimal('quote_volume', 36, 18)->comment('成交额（计价币种）');
            $table->integer('trade_count')->unsigned()->default(0)->comment('成交笔数');
            $table->decimal('taker_buy_volume', 36, 18)->default(0)->comment('主动买入成交量（合约数量）');
            $table->decimal('taker_buy_quote_volume', 36, 18)->default(0)->comment('主动买入成交额（计价币种）');
            $table->timestamps();

            // 唯一索引：同一交易对、同一时间周期、同一开盘时间只能有一条记录
            $table->unique(['symbol', 'interval', 'open_time'], 'uk_futures_symbol_interval_time');
            // 复合索引：用于查询指定交易对和时间周期的K线数据
            $table->index(['symbol', 'interval'], 'idx_futures_symbol_interval');
            // 时间索引：用于按时间范围查询
            $table->index('open_time', 'idx_futures_open_time');
            // 收盘时间索引：用于按收盘时间查询
            $table->index('close_time', 'idx_futures_close_time');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // 只删除合约K线表，现货K线表可能在其他迁移文件中，不在这里删除
        Schema::dropIfExists('ex_futures_klines');
        // 如果现货K线表是在此迁移中创建的，则删除
        // 注意：如果表是在其他迁移中创建的，请手动处理
        // Schema::dropIfExists('ex_spot_klines');
    }
};

