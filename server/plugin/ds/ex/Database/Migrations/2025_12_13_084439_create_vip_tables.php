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
        // VIP等级配置表
        Schema::create('ex_vip', static function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';
            $table->comment('VIP等级配置表');

            $table->bigIncrements('id')->comment('主键ID');
            $table->unsignedTinyInteger('level')->comment('VIP等级：0=普通用户,1-9=VIP1-VIP9');
            $table->json('name')->nullable()->comment('多语言名称：[{"lang":"en","text":"青铜"}]');
            $table->json('description')->nullable()->comment('多语言描述');
            $table->string('icon', 255)->nullable()->comment('VIP图标URL');
            $table->string('color', 20)->nullable()->comment('VIP主题颜色');
            $table->decimal('trading_volume_usdt', 20, 2)->default(0.00)->comment('交易型VIP：30天交易量要求（USDT）');
            $table->decimal('holder_wallet_asset_usd', 20, 2)->default(0.00)->comment('持有者计划：钱包资产要求（USD）');
            $table->decimal('holder_platform_token', 20, 8)->default(0.00000000)->comment('持有者计划：平台币持有量要求');
            $table->decimal('withdraw_limit_24h_usdt', 20, 2)->default(0.00)->comment('24小时提现额度（USDT）');
            $table->unsignedSmallInteger('protection_days')->default(0)->comment('降级保护天数，达到该等级后N天内不降级');
            $table->smallInteger('sort')->default(0)->comment('排序');
            $table->unsignedTinyInteger('status')->default(1)->comment('状态：1=启用,2=禁用');

            // 费率配置（JSON格式存储不同交易类型的费率，单位为小数，如0.001表示0.1%）
            $table->json('fee_rates')->nullable()->comment('费率配置JSON结构：{"spot":{"maker":0.001,"taker":0.001},"usdt_futures":{"maker":0.0002,"taker":0.0005},"coin_futures":{"maker":0.0002,"taker":0.0005},"option":{"maker":0.0002,"taker":0.0002},"margin":{"maker":0.001,"taker":0.001}}');

            // VIP特权配置（JSON格式存储各种特权设置）
            $table->json('privileges')->nullable()->comment('VIP特权配置JSON结构：{"api_rate_limit":1000,"api_rate_limit_ws":10,"customer_service":"priority","withdraw_fee_discount":0.5,"dedicated_account_manager":false,"exclusive_events":1,"airdrop_priority":1,"trading_rebate_rate":0.2,"loan_interest_discount":0.1}');

            $table->timestamps();
            $table->softDeletes();

            $table->unique('level');
            $table->index('status');
        });

        // 用户VIP信息表
        Schema::create('ex_user_vip', static function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';
            $table->comment('用户VIP信息表');

            $table->bigIncrements('id')->comment('主键ID');
            $table->unsignedBigInteger('user_id')->comment('用户ID');
            $table->unsignedTinyInteger('level')->default(0)->comment('当前VIP等级：0=普通用户，取持有者计划和交易型的最高等级');
            $table->unsignedTinyInteger('holder_level')->default(0)->comment('持有者计划等级（根据资产实时计算）');
            $table->unsignedTinyInteger('trading_level')->default(0)->comment('交易型VIP等级（缓存）');
            $table->unsignedTinyInteger('primary_type')->default(1)->comment('主要VIP获得方式：1=持有者计划,2=交易型VIP,3=手动赠送');
            $table->timestamp('expired_at')->nullable()->comment('VIP到期时间，NULL表示永久VIP');
            $table->timestamp('protection_until')->nullable()->comment('降级保护截止时间');

            // 交易量缓存字段（性能考虑）
            $table->decimal('trading_volume_30d_usdt', 20, 2)->default(0.00)->comment('30天交易量缓存，定时任务更新');
            $table->timestamp('trading_volume_cached_at')->nullable()->comment('交易量缓存时间');
            $table->timestamp('last_calculated_at')->nullable()->comment('最后一次计算VIP等级的时间');

            $table->timestamps();

            $table->unique('user_id');
            $table->index('level');
            $table->index('expired_at');
        });

        // VIP升级记录表
        Schema::create('ex_user_vip_log', static function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';
            $table->comment('VIP升级记录表');

            $table->bigIncrements('id')->comment('主键ID');
            $table->unsignedBigInteger('user_id')->comment('用户ID');
            $table->unsignedTinyInteger('from_level')->default(0)->comment('原VIP等级');
            $table->unsignedTinyInteger('to_level')->comment('新VIP等级');
            $table->unsignedTinyInteger('trigger_type')->default(1)->comment('升级触发方式：1=持有者计划,2=交易型VIP,3=手动调整');
            $table->string('action_type', 20)->comment('操作类型：UPGRADE=升级,DOWNGRADE=降级,MANUAL_ADJUST=手动调整');
            $table->string('downgrade_reason', 100)->nullable()->comment('降级原因：ASSET_DECREASED=资产减少,VOLUME_INSUFFICIENT=交易量不足,EXPIRED=到期,PROTECTION_END=保护期结束');
            $table->json('upgrade_data')->nullable()->comment('升级时的数据快照');
            $table->text('remark')->nullable()->comment('备注说明，手动调整时建议填写');
            $table->unsignedBigInteger('operator_id')->nullable()->comment('操作人ID');
            $table->string('operator_type', 20)->nullable()->comment('操作人类型：SYSTEM=系统,ADMIN=管理员');
            $table->string('ip', 45)->nullable()->comment('操作IP地址');
            $table->timestamp('created_at')->nullable();

            $table->index('user_id');
            $table->index('created_at');
            $table->index(['user_id', 'action_type']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ex_user_vip_log');
        Schema::dropIfExists('ex_user_vip');
        Schema::dropIfExists('ex_vip');
    }
};

