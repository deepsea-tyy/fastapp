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
        // 1. 钱包余额表
        Schema::create('ex_wallet_balances', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('钱包余额表');
            $table->bigIncrements('id')->comment('主键');
            $table->bigInteger('user_id')->unsigned()->comment('用户ID');
            $table->string('wallet_type', 20)->comment('钱包类型: FUNDING/SPOT/FUTURES/MARGIN/EARN/OPTIONS');
            $table->string('symbol', 20)->comment('币种');
            $table->decimal('available', 36, 18)->default(0)->comment('可用余额');
            $table->decimal('frozen', 36, 18)->default(0)->comment('冻结余额');
            $table->decimal('total', 36, 18)->storedAs('available + frozen')->comment('总余额');
            $table->tinyInteger('status')->unsigned()->default(1)->comment('状态 1正常 2冻结');
            $table->integer('version')->unsigned()->default(0)->comment('乐观锁版本号');
            $table->timestamps();

            $table->unique(['user_id', 'wallet_type', 'symbol'], 'uk_user_wallet_symbol');
            $table->index('user_id', 'idx_user_id');
            $table->index('symbol', 'idx_symbol');
        });

        // 2. 资金流水表
        Schema::create('ex_wallet_balance_logs', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('资金流水表');
            $table->bigIncrements('id')->comment('主键');
            $table->bigInteger('user_id')->unsigned()->comment('用户ID');
            $table->string('wallet_type', 20)->comment('钱包类型');
            $table->string('symbol', 20)->comment('币种');
            $table->string('change_type', 30)->comment('变动类型');
            $table->decimal('amount', 36, 18)->comment('变动金额(正数为增加,负数为减少)');
            $table->decimal('available_before', 36, 18)->comment('变动前可用');
            $table->decimal('available_after', 36, 18)->comment('变动后可用');
            $table->decimal('frozen_before', 36, 18)->comment('变动前冻结');
            $table->decimal('frozen_after', 36, 18)->comment('变动后冻结');
            $table->string('ref_id', 100)->nullable()->comment('关联业务ID');
            $table->string('ref_type', 30)->nullable()->comment('业务类型');
            $table->string('remark', 255)->nullable()->comment('备注');
            $table->timestamp('created_at')->nullable()->comment('创建时间');

            $table->index(['user_id', 'wallet_type'], 'idx_user_wallet');
            $table->index(['user_id', 'symbol'], 'idx_user_symbol');
            $table->index(['ref_type', 'ref_id'], 'idx_ref');
            $table->index('created_at', 'idx_created');
        });

        // 3. 账户划转表
        Schema::create('ex_wallet_transfers', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('账户划转记录表');
            $table->bigIncrements('id')->comment('主键');
            $table->bigInteger('user_id')->unsigned()->comment('用户ID');
            $table->string('from_wallet_type', 20)->comment('源钱包类型');
            $table->string('to_wallet_type', 20)->comment('目标钱包类型');
            $table->string('symbol', 20)->comment('币种');
            $table->decimal('amount', 36, 18)->comment('划转金额');
            $table->tinyInteger('status')->unsigned()->default(1)->comment('状态 1成功 2失败 3处理中');
            $table->timestamps();

            $table->index('user_id', 'idx_user_id');
            $table->index('created_at', 'idx_created');
        });

        // 4. 钱包地址表
        Schema::create('ex_wallet_addresses', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('钱包链上地址表');
            $table->bigIncrements('id')->comment('主键');
            $table->bigInteger('user_id')->unsigned()->comment('用户ID');
            $table->string('symbol', 20)->comment('币种');
            $table->string('network', 50)->comment('网络类型: TRC20/ERC20/BTC/etc');
            $table->string('address', 255)->comment('钱包地址');
            $table->tinyInteger('address_type')->unsigned()->comment('地址类型 1充值 2提现');
            $table->text('public_key')->nullable()->comment('公钥');
            $table->text('private_key')->nullable()->comment('加密后的私钥');
            $table->string('tag', 100)->nullable()->comment('标签/Memo(部分币种需要)');
            $table->tinyInteger('status')->unsigned()->default(1)->comment('状态 1启用 2禁用');
            $table->tinyInteger('is_whitelist')->unsigned()->default(0)->comment('是否白名单地址 0否 1是');
            $table->timestamp('last_used_at')->nullable()->comment('最后使用时间');
            $table->timestamps();

            $table->unique(['user_id', 'symbol', 'network', 'address_type'], 'uk_user_symbol_network');
            $table->index('address', 'idx_address');
            $table->index('user_id', 'idx_user_id');
        });

        // 5. 充值记录表
        Schema::create('ex_wallet_deposits', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('充值记录表');
            $table->bigIncrements('id')->comment('主键');
            $table->bigInteger('user_id')->unsigned()->comment('用户ID');
            $table->bigInteger('address_id')->unsigned()->comment('充值地址ID');
            $table->string('symbol', 20)->comment('币种');
            $table->string('network', 50)->comment('网络类型');
            $table->string('from_address', 255)->comment('来源地址');
            $table->string('to_address', 255)->comment('充值地址');
            $table->decimal('amount', 36, 18)->comment('充值金额');
            $table->string('txid', 255)->comment('交易哈希');
            $table->integer('confirmations')->unsigned()->default(0)->comment('确认数');
            $table->integer('required_confirmations')->unsigned()->default(6)->comment('需要确认数');
            $table->tinyInteger('status')->unsigned()->default(1)->comment('状态 1待确认 2已完成 3失败');
            $table->tinyInteger('credited')->unsigned()->default(0)->comment('是否已入账 0否 1是');
            $table->timestamp('credited_at')->nullable()->comment('入账时间');
            $table->timestamps();

            $table->unique(['txid', 'network'], 'uk_txid');
            $table->index('user_id', 'idx_user_id');
            $table->index('status', 'idx_status');
            $table->index('created_at', 'idx_created');
        });

        // 6. 提现记录表
        Schema::create('ex_wallet_withdrawals', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('提现记录表');
            $table->bigIncrements('id')->comment('主键');
            $table->bigInteger('user_id')->unsigned()->comment('用户ID');
            $table->string('symbol', 20)->comment('币种');
            $table->string('network', 50)->comment('网络类型');
            $table->string('to_address', 255)->comment('提现地址');
            $table->string('tag', 100)->nullable()->comment('标签/Memo');
            $table->decimal('amount', 36, 18)->comment('提现金额');
            $table->decimal('fee', 36, 18)->comment('手续费');
            $table->decimal('actual_amount', 36, 18)->comment('实际到账金额');
            $table->string('txid', 255)->nullable()->comment('交易哈希');
            $table->tinyInteger('status')->unsigned()->default(1)->comment('状态 1待审核 2审核通过 3处理中 4已完成 5已拒绝 6已取消');
            $table->tinyInteger('audit_status')->unsigned()->default(1)->comment('审核状态 1待审核 2通过 3拒绝');
            $table->string('audit_remark', 255)->nullable()->comment('审核备注');
            $table->bigInteger('audited_by')->unsigned()->nullable()->comment('审核人ID');
            $table->timestamp('audited_at')->nullable()->comment('审核时间');
            $table->timestamp('completed_at')->nullable()->comment('完成时间');
            $table->timestamps();

            $table->index('user_id', 'idx_user_id');
            $table->index('status', 'idx_status');
            $table->index('txid', 'idx_txid');
            $table->index('created_at', 'idx_created');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ex_wallet_withdrawals');
        Schema::dropIfExists('ex_wallet_deposits');
        Schema::dropIfExists('ex_wallet_addresses');
        Schema::dropIfExists('ex_wallet_transfers');
        Schema::dropIfExists('ex_wallet_balance_logs');
        Schema::dropIfExists('ex_wallet_balances');
    }
};
