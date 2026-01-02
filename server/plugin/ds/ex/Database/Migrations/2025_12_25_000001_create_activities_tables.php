<?php

declare(strict_types=1);

use Hyperf\Database\Migrations\Migration;
use Hyperf\Database\Schema\Blueprint;
use Hyperf\Database\Schema\Schema;

return new class extends Migration {
    public function up(): void
    {
        // 活动表
        Schema::create('ex_activities', static function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';
            $table->comment('交易所活动表');

            $table->bigIncrements('id')->comment('活动ID');
            $table->json('title')->comment('活动标题（多语言）');
            $table->json('subtitle')->nullable()->comment('活动副标题（多语言）');
            $table->unsignedTinyInteger('type')->comment('活动类型：1=新手活动,2=交易挖矿,3=邀请返佣,4=节日活动,5=持仓空投,6=交易大赛,7=签到活动,8=限时任务');
            $table->unsignedTinyInteger('status')->default(1)->comment('状态：0=草稿,1=已发布,2=进行中,3=已结束,4=已下架');
            $table->string('cover_image', 500)->nullable()->comment('活动封面图');
            $table->string('banner_image', 500)->nullable()->comment('活动横幅图');
            $table->json('description')->nullable()->comment('活动详细描述（多语言富文本）');
            $table->json('rules')->nullable()->comment('活动规则配置（JSON格式）');
            $table->datetime('start_time')->comment('活动开始时间');
            $table->datetime('end_time')->comment('活动结束时间');
            $table->json('reward_config')->nullable()->comment('奖励配置（币种、数量、类型等）');
            $table->unsignedInteger('participate_limit')->nullable()->comment('参与人数限制（null表示不限）');
            $table->unsignedInteger('participated_count')->default(0)->comment('已参与人数');
            $table->integer('sort_order')->default(0)->comment('排序权重');
            $table->unsignedTinyInteger('is_hot')->default(0)->comment('是否热门活动：0=否,1=是');
            $table->unsignedTinyInteger('is_recommend')->default(0)->comment('是否推荐：0=否,1=是');
            $table->timestamps();
            $table->softDeletes();

            $table->index('type');
            $table->index('status');
            $table->index(['start_time', 'end_time']);
        });

        // 任务表
        Schema::create('ex_tasks', static function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';
            $table->comment('任务表');

            $table->bigIncrements('id')->comment('任务ID');
            $table->unsignedBigInteger('activity_id')->nullable()->comment('关联活动ID（null表示独立任务）');
            $table->json('title')->comment('任务标题（多语言）');
            $table->json('description')->nullable()->comment('任务描述（多语言）');
            $table->unsignedTinyInteger('type')->comment('任务类型：1=签到,2=交易,3=充值,4=邀请,5=持仓,6=KYC认证,7=绑定邮箱,8=绑定手机,9=分享,10=关注社交账号');
            $table->json('task_config')->comment('任务配置（完成条件、次数等）');
            $table->unsignedTinyInteger('reward_type')->comment('奖励类型：1=代币,2=积分,3=优惠券,4=手续费折扣券');
            $table->json('reward_config')->comment('奖励配置');
            $table->unsignedTinyInteger('repeat_type')->default(1)->comment('重复类型：1=一次性,2=每日,3=每周,4=每月');
            $table->integer('priority')->default(0)->comment('优先级（用于排序）');
            $table->datetime('start_time')->nullable()->comment('任务开始时间');
            $table->datetime('end_time')->nullable()->comment('任务结束时间');
            $table->unsignedTinyInteger('status')->default(1)->comment('状态：0=禁用,1=启用');
            $table->string('icon', 500)->nullable()->comment('任务图标');
            $table->string('category', 50)->nullable()->comment('任务分类：新手任务、日常任务、进阶任务');
            $table->timestamps();
            $table->softDeletes();

            $table->index('activity_id');
            $table->index(['type', 'status']);
            $table->index('category');
        });

        // 用户任务记录表
        Schema::create('ex_user_tasks', static function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';
            $table->comment('用户任务记录表');

            $table->bigIncrements('id');
            $table->unsignedBigInteger('uid')->comment('用户ID');
            $table->unsignedBigInteger('task_id')->comment('任务ID');
            $table->unsignedBigInteger('activity_id')->nullable()->comment('活动ID');
            $table->unsignedTinyInteger('status')->default(0)->comment('状态：0=未开始,1=进行中,2=已完成,3=已领取奖励');
            $table->unsignedInteger('progress')->default(0)->comment('当前进度');
            $table->unsignedInteger('target')->default(0)->comment('目标进度');
            $table->json('progress_data')->nullable()->comment('进度详细数据');
            $table->datetime('completed_at')->nullable()->comment('完成时间');
            $table->datetime('claimed_at')->nullable()->comment('领取奖励时间');
            $table->date('date')->comment('任务日期（用于每日任务）');
            $table->timestamps();

            $table->unique(['uid', 'task_id', 'date']);
            $table->index('uid');
            $table->index(['task_id', 'status']);
        });

        // 用户活动参与表
        Schema::create('ex_user_activities', static function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';
            $table->comment('用户活动参与表');

            $table->bigIncrements('id');
            $table->unsignedBigInteger('uid')->comment('用户ID');
            $table->unsignedBigInteger('activity_id')->comment('活动ID');
            $table->unsignedTinyInteger('status')->default(1)->comment('状态：1=参与中,2=已完成,3=已领奖');
            $table->datetime('join_time')->comment('参与时间');
            $table->datetime('complete_time')->nullable()->comment('完成时间');
            $table->datetime('claimed_time')->nullable()->comment('领奖时间');
            $table->json('progress_data')->nullable()->comment('进度数据（交易量、邀请人数等）');
            $table->unsignedInteger('ranking')->nullable()->comment('排名（用于排行榜）');
            $table->decimal('score', 20, 2)->nullable()->comment('积分/成绩');
            $table->timestamps();

            $table->unique(['uid', 'activity_id']);
            $table->index('activity_id');
            $table->index(['activity_id', 'ranking']);
        });

        // 奖励发放记录表
        Schema::create('ex_reward_logs', static function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';
            $table->comment('奖励发放记录表');

            $table->bigIncrements('id');
            $table->unsignedBigInteger('uid')->comment('用户ID');
            $table->unsignedTinyInteger('source_type')->comment('来源类型：1=活动,2=任务,3=邀请返佣,4=交易挖矿,5=签到,6=后台发放');
            $table->unsignedBigInteger('source_id')->nullable()->comment('来源ID（活动ID或任务ID）');
            $table->unsignedTinyInteger('reward_type')->comment('奖励类型：1=代币,2=积分,3=优惠券,4=手续费折扣券');
            $table->string('reward_name', 100)->comment('奖励名称');
            $table->decimal('reward_amount', 20, 8)->nullable()->comment('奖励数量');
            $table->string('symbol', 20)->nullable()->comment('币种（代币奖励）');
            $table->json('reward_config')->nullable()->comment('奖励配置详情');
            $table->unsignedTinyInteger('status')->default(0)->comment('状态：0=待发放,1=已发放,2=发放失败');
            $table->datetime('issued_at')->nullable()->comment('发放时间');
            $table->string('remark', 500)->nullable()->comment('备注');
            $table->timestamps();

            $table->index(['uid', 'status']);
            $table->index(['source_type', 'source_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ex_reward_logs');
        Schema::dropIfExists('ex_user_activities');
        Schema::dropIfExists('ex_user_tasks');
        Schema::dropIfExists('ex_tasks');
        Schema::dropIfExists('ex_activities');
    }
};
