<?php

declare(strict_types=1);

use Hyperf\Database\Schema\Schema;
use Hyperf\Database\Schema\Blueprint;
use Hyperf\Database\Migrations\Migration;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('message_notify', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('消息通知表');
            $table->bigIncrements('id')->comment('ID');
            $table->json('title')->nullable()->comment('通知标题');
            $table->json('content')->nullable()->comment('通知内容');
            $table->tinyInteger('type')->comment('通知类型:1-全局,2-个人')->default(1);
            $table->bigInteger('user_id')->unsigned()->comment('用户ID 全局通知为0')->default(0);
            $table->tinyInteger('notify_type')->default(1)->comment('通知分类:1-系统通知,2-业务通知,3-其他');
            $table->string('link')->nullable()->comment('跳转链接');
            $table->bigInteger('created_by')->unsigned()->nullable()->comment('创建者');
            $table->bigInteger('updated_by')->unsigned()->nullable()->comment('更新者');
            $table->timestamps();
            $table->index('type');
            $table->index('user_id');
            $table->index('notify_type');
        });

        Schema::create('message_notify_read', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('消息已读状态表');
            $table->bigIncrements('id')->comment('ID');
            $table->bigInteger('notify_type')->unsigned()->comment('通知分类');
            $table->bigInteger('notify_id')->unsigned()->comment('已读最大ID');
            $table->bigInteger('user_id')->unsigned()->comment('用户ID');
            $table->index('user_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('message_notify');
        Schema::dropIfExists('message_notify_read');
    }
};
