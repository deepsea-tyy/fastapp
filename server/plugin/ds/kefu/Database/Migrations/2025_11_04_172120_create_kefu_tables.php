<?php

declare(strict_types=1);

use Hyperf\Database\Schema\Schema;
use Hyperf\Database\Schema\Blueprint;
use Hyperf\Database\Migrations\Migration;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('kefu', function (Blueprint $table) {
            $table->comment('客服表');
            $table->bigIncrements('id')->comment('ID');
            $table->string('nickname', 50)->nullable()->comment('昵称');
            $table->string('avatar')->nullable()->comment('头像');
            $table->tinyInteger('status')->default(1)->comment('1启用2禁用');
            $table->integer('max_concurrent')->default(0)->comment('最大会话数 0不限');
            $table->integer('current_concurrent')->default(0)->comment('当前会话数');
            $table->timestamps();
            $table->bigInteger('created_by')->unsigned()->nullable()->comment('创建者');
            $table->bigInteger('updated_by')->unsigned()->nullable()->comment('更新者');
        });

        Schema::create('kefu_conversation', function (Blueprint $table) {
            $table->comment('客服会话表');
            $table->bigIncrements('id')->comment('ID');
            $table->bigInteger('kefu_id')->comment('关联客服表');
            $table->bigInteger('user_id')->comment('用户id');
            $table->tinyInteger('status')->default(1)->comment('会话状态：1-进行中，2-已结束');
            $table->timestamp('last_message_at')->nullable()->comment('最后消息时间');
            $table->integer('unread_count')->default(0)->comment('未读消息数（用户侧）');
            $table->integer('kefu_unread_count')->default(0)->comment('未读消息数（客服侧）');
            $table->timestamps();
            $table->index('kefu_id');
            $table->index('user_id');
            $table->index('last_message_at');
        });

        Schema::create('kefu_message', function (Blueprint $table) {
            $table->comment('客服消息表');
            $table->bigIncrements('id')->comment('ID');
            $table->bigInteger('conversation_id')->comment('会话ID');
            $table->bigInteger('sender_id')->comment('发送者ID');
            $table->tinyInteger('sender_type')->comment('发送者类型：1-用户，2-客服');
            $table->text('content')->comment('消息内容');
            $table->tinyInteger('message_type')->default(1)->comment('消息类型：1-文本，2-图片，3-文件');
            $table->string('file_url')->nullable()->comment('文件URL（图片或文件类型时使用）');
            $table->tinyInteger('is_read')->default(0)->comment('是否已读：0-未读，1-已读');
            $table->timestamp('read_at')->nullable()->comment('阅读时间');
            $table->timestamps();
            $table->index('conversation_id');
            $table->index('sender_id');
            $table->index('created_at');
        });

        Schema::create('kefu_knowledge', function (Blueprint $table) {
            $table->comment('客服知识库表');
            $table->bigIncrements('id')->comment('ID');
            $table->string('keywords')->comment('关键词列表(,分割)');
            $table->text('content')->comment('回复内容');
            $table->tinyInteger('match_type')->default(2)->comment('匹配类型：1-精确匹配，2-包含匹配，3-模糊匹配');
            $table->tinyInteger('status')->default(1)->comment('状态：1-启用，2-禁用');
            $table->integer('sort')->default(0)->comment('排序');
            $table->integer('priority')->default(0)->comment('优先级（数字越大优先级越高）');
            $table->integer('hit_count')->default(0)->comment('命中次数');
            $table->bigInteger('created_by')->unsigned()->nullable()->comment('创建者');
            $table->bigInteger('updated_by')->unsigned()->nullable()->comment('更新者');
            $table->timestamps();
        });

        Schema::create('kefu_visitor', function (Blueprint $table) {
            $table->comment('客服游客消息表');
            $table->bigIncrements('id')->comment('ID');
            $table->string('visitor_id')->comment('游客标识');
            $table->string('kefu_id')->comment('客服ID');
            $table->tinyInteger('sender_type')->default(1);
            $table->text('content')->comment('消息内容');
            $table->timestamps();
            $table->index('visitor_id');
            $table->index('kefu_id');
        });

    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('kefu');
        Schema::dropIfExists('kefu_conversation');
        Schema::dropIfExists('kefu_message');
        Schema::dropIfExists('kefu_knowledge');
        Schema::dropIfExists('kefu_visitor');
    }
};
