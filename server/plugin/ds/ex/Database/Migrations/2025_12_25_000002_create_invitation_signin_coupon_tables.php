<?php

declare(strict_types=1);

use Hyperf\Database\Migrations\Migration;
use Hyperf\Database\Schema\Blueprint;
use Hyperf\Database\Schema\Schema;

return new class extends Migration {
    public function up(): void
    {
        // 用户邀请关系表
        Schema::create('ex_user_invitations', static function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';
            $table->comment('用户邀请关系表');

            $table->bigIncrements('id');
            $table->unsignedBigInteger('inviter_uid')->comment('邀请人ID');
            $table->unsignedBigInteger('invitee_uid')->comment('被邀请人ID');
            $table->string('invitation_code', 50)->comment('邀请码');
            $table->unsignedTinyInteger('status')->default(1)->comment('状态：1=已注册,2=已实名,3=已交易');
            $table->datetime('register_time')->comment('注册时间');
            $table->datetime('kyc_time')->nullable()->comment('完成实名时间');
            $table->datetime('first_trade_time')->nullable()->comment('首次交易时间');
            $table->decimal('total_trade_amount', 20, 8)->default(0)->comment('累计交易额（USDT）');
            $table->decimal('total_commission', 20, 8)->default(0)->comment('累计返佣金额');
            $table->unsignedTinyInteger('level')->default(1)->comment('邀请层级：1=直接邀请,2=二级邀请');
            $table->timestamps();

            $table->unique('invitee_uid');
            $table->index('inviter_uid');
            $table->index('invitation_code');
        });

        // 返佣记录表
        Schema::create('ex_commission_logs', static function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';
            $table->comment('返佣记录表');

            $table->bigIncrements('id');
            $table->unsignedBigInteger('inviter_uid')->comment('邀请人ID');
            $table->unsignedBigInteger('invitee_uid')->comment('被邀请人ID');
            $table->unsignedTinyInteger('source_type')->comment('返佣来源：1=交易手续费,2=充值返佣');
            $table->string('source_id', 100)->nullable()->comment('来源订单号');
            $table->decimal('trade_amount', 20, 8)->comment('交易金额');
            $table->decimal('commission_rate', 8, 4)->comment('返佣比例（%）');
            $table->decimal('commission_amount', 20, 8)->comment('返佣金额');
            $table->string('symbol', 20)->comment('返佣币种');
            $table->unsignedTinyInteger('status')->default(0)->comment('状态：0=待结算,1=已发放,2=已冻结');
            $table->datetime('settled_at')->nullable()->comment('结算时间');
            $table->timestamps();

            $table->index(['inviter_uid', 'status']);
            $table->index('invitee_uid');
        });

        // 签到记录表
        Schema::create('ex_sign_in_logs', static function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';
            $table->comment('签到记录表');

            $table->bigIncrements('id');
            $table->unsignedBigInteger('uid')->comment('用户ID');
            $table->date('sign_date')->comment('签到日期');
            $table->unsignedInteger('continuous_days')->default(1)->comment('连续签到天数');
            $table->unsignedInteger('total_days')->default(1)->comment('累计签到天数');
            $table->unsignedTinyInteger('reward_type')->nullable()->comment('奖励类型');
            $table->decimal('reward_amount', 20, 8)->nullable()->comment('奖励数量');
            $table->string('reward_symbol', 20)->nullable()->comment('奖励币种');
            $table->datetime('created_at')->nullable();

            $table->unique(['uid', 'sign_date']);
            $table->index('uid');
        });

        // 排行榜表
        Schema::create('ex_leaderboards', static function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';
            $table->comment('排行榜表');

            $table->bigIncrements('id');
            $table->unsignedBigInteger('activity_id')->comment('活动ID');
            $table->unsignedBigInteger('uid')->comment('用户ID');
            $table->unsignedInteger('ranking')->comment('排名');
            $table->decimal('score', 20, 8)->comment('积分/成绩');
            $table->string('score_type', 50)->comment('成绩类型：trade_volume=交易量,invitation_count=邀请人数');
            $table->unsignedTinyInteger('is_claimed')->default(0)->comment('是否已领取奖励：0=否,1=是');
            $table->datetime('snapshot_time')->comment('快照时间');
            $table->timestamps();

            $table->unique(['activity_id', 'uid']);
            $table->index(['activity_id', 'ranking']);
        });

        // 优惠券表
        Schema::create('ex_coupons', static function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';
            $table->comment('优惠券表');

            $table->bigIncrements('id');
            $table->string('code', 50)->comment('优惠券码');
            $table->json('name')->comment('优惠券名称（多语言）');
            $table->unsignedTinyInteger('type')->comment('类型：1=手续费折扣,2=充值赠金');
            $table->unsignedTinyInteger('discount_type')->comment('折扣类型：1=百分比,2=固定金额');
            $table->decimal('discount_value', 10, 4)->comment('折扣值');
            $table->decimal('min_amount', 20, 8)->nullable()->comment('最低使用金额');
            $table->unsignedInteger('total_count')->nullable()->comment('发行总量（null为不限）');
            $table->unsignedInteger('used_count')->default(0)->comment('已使用数量');
            $table->unsignedInteger('per_user_limit')->default(1)->comment('每人限领数量');
            $table->unsignedInteger('valid_days')->nullable()->comment('有效天数');
            $table->datetime('start_time')->nullable()->comment('有效期开始');
            $table->datetime('end_time')->nullable()->comment('有效期结束');
            $table->unsignedTinyInteger('status')->default(1)->comment('状态：0=禁用,1=启用');
            $table->json('description')->nullable()->comment('使用说明（多语言）');
            $table->timestamps();

            $table->unique('code');
            $table->index(['type', 'status']);
        });

        // 用户优惠券表
        Schema::create('ex_user_coupons', static function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';
            $table->comment('用户优惠券表');

            $table->bigIncrements('id');
            $table->unsignedBigInteger('uid')->comment('用户ID');
            $table->unsignedBigInteger('coupon_id')->comment('优惠券ID');
            $table->string('code', 50)->comment('优惠券码');
            $table->unsignedTinyInteger('status')->default(0)->comment('状态：0=未使用,1=已使用,2=已过期');
            $table->unsignedTinyInteger('source_type')->nullable()->comment('来源：1=活动,2=任务,3=兑换码,4=后台发放');
            $table->datetime('receive_time')->comment('领取时间');
            $table->datetime('use_time')->nullable()->comment('使用时间');
            $table->datetime('expire_time')->comment('过期时间');
            $table->string('order_id', 100)->nullable()->comment('使用订单号');
            $table->timestamps();

            $table->index(['uid', 'status']);
            $table->index('coupon_id');
            $table->index('code');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ex_user_coupons');
        Schema::dropIfExists('ex_coupons');
        Schema::dropIfExists('ex_leaderboards');
        Schema::dropIfExists('ex_sign_in_logs');
        Schema::dropIfExists('ex_commission_logs');
        Schema::dropIfExists('ex_user_invitations');
    }
};
