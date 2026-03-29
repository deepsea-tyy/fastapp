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
        Schema::create('search_keyword', static function (Blueprint $table) {
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

        Schema::create('search_index', static function (Blueprint $table) {
            $table->comment('搜索索引表');
            $table->bigIncrements('id')->comment('主键ID');
            $table->string('target_type', 50)->comment('内容类型: feed(短贴)|feed_article(标题贴)|article(普通文章)|notice(公告)|news(新闻)');
            $table->unsignedBigInteger('target_id')->comment('内容ID');
            $table->string('title', 200)->comment('标题');
            $table->string('content', 100)->nullable()->comment('内容');
            $table->json('keyword')->nullable()->comment('关键词数组');
            $table->json('tags')->nullable()->comment('标签数组');
            $table->integer('weight')->unsigned()->default(0)->comment('权重');
            $table->integer('click_count')->unsigned()->default(0)->comment('点击量');
            $table->timestamp('last_at')->nullable()->comment('最新时间');
            $table->unique(['target_type', 'target_id']);
            $table->index('last_at');
            $table->index('click_count');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('search_index');
        Schema::dropIfExists('search_keyword');
    }
};
