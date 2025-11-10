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
        Schema::create('user_invite_code', static function (Blueprint $table) {
            $table->comment('用户邀请码');
            $table->bigIncrements('id');
            $table->bigInteger('user_id')->comment('用户ID');
            $table->tinyInteger('type')->comment('类型:1=默认');
            $table->string('invite_code', 16)->nullable()->comment('邀请码');
            $table->json('config')->nullable()->comment('邀请码配置');
            $table->timestamp('created_at');

            $table->index('user_id');
            $table->unique('invite_code');
        });

        Schema::create('user_relation', static function (Blueprint $table) {
            $table->comment('上下级关系');
            $table->bigIncrements('id');
            $table->bigInteger('user_id')->comment('用户ID');
            $table->bigInteger('parent_id')->comment('上级ID');
            $table->string('path', 500)->default('')->comment('路径：从根节点到当前节点的完整路径，如 /1/2/3/');
            $table->unsignedTinyInteger('level')->default(0)->comment('层级深度：0=根节点，1=一级下级，以此类推');
            $table->timestamp('created_at');
            
            // 索引优化
            $table->index('user_id');
            $table->index('parent_id');
            $table->index('path'); // 用于快速查询所有下级
            $table->index(['parent_id', 'level']); // 用于查询直接下级和指定层级
            $table->index(['user_id', 'level']); // 用于按用户和层级查询
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_invite_code');
        Schema::dropIfExists('user_relation');
    }
};
