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
        Schema::create('keyword', static function (Blueprint $table) {
            $table->comment('搜索关键词记录表');
            $table->bigIncrements('id')->comment('主键ID');
            $table->string('keyword', 32)->comment('搜索关键词');
            $table->integer('hit_count')->unsigned()->default(1)->comment('命中次数');
            $table->string('icon', 64)->nullable()->comment('图标名称');
            $table->string('color', 20)->nullable()->comment('图标颜色(十六进制)');
            $table->tinyInteger('source')->default(1)->comment('来源:1=用户搜索,2=热门推荐,3=系统推荐');
            $table->integer('sort')->unsigned()->default(0)->comment('排序(数字越大越靠前)');
            $table->timestamp('last_searched_at')->nullable()->comment('最后搜索时间');

            $table->unique('keyword');
            $table->index('hit_count');
            $table->index('sort');
            $table->index('last_searched_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('keyword');
    }
};
