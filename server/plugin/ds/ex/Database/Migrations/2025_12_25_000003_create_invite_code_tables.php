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
        // 用户邀请码表
        Schema::create('ex_user_invite_codes', static function (Blueprint $table) {
            $table->comment('用户邀请码');
            $table->bigIncrements('id');
            $table->bigInteger('uid')->comment('用户ID');
            $table->tinyInteger('type')->default(1)->comment('类型:1=默认');
            $table->string('invite_code', 16)->nullable()->unique()->comment('邀请码');
            $table->json('config')->nullable()->comment('邀请码配置');
            $table->datetime('created_at');

            $table->index('uid');
            $table->unique('invite_code');
        });

        // 用户上下级关系表
        Schema::create('ex_user_relations', static function (Blueprint $table) {
            $table->comment('用户上下级关系');
            $table->bigIncrements('id');
            $table->bigInteger('uid')->comment('用户ID');
            $table->bigInteger('parent_uid')->comment('上级用户ID');
            $table->string('path', 500)->default('')->comment('路径：从根节点到当前节点的完整路径，如 /1/2/3/');
            $table->unsignedTinyInteger('level')->default(0)->comment('层级深度：0=根节点，1=一级下级，以此类推');
            $table->datetime('created_at');

            // 索引优化
            $table->unique('uid'); // uid 应该是唯一的
            $table->index('parent_uid');
            $table->index('path'); // 用于快速查询所有下级
            $table->index(['parent_uid', 'level']); // 用于查询直接下级和指定层级
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ex_user_invite_codes');
        Schema::dropIfExists('ex_user_relations');
    }
};
