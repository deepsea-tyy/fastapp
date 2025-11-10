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
        Schema::create('article', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('文章表');
            $table->bigIncrements('id')->comment('ID');
            $table->json('title')->nullable()->comment('标题');
            $table->json('subtitle')->nullable()->comment('副标题');
            $table->char('author', 128)->nullable()->comment('作者');
            $table->json('cover')->nullable()->comment('封面');
            $table->json('video')->nullable()->comment('视频');
            $table->char('release_at')->nullable()->comment('发布日期');
            $table->json('brief')->nullable()->comment('摘要');
            $table->json('content')->nullable()->comment('内容');
            $table->string('remark')->nullable()->comment('备注');
            $table->integer('sort')->comment('排序')->default(100);
            $table->integer('comment')->comment('评论数')->default(0);
            $table->integer('views')->comment('浏览数')->default(0);
            $table->integer('like')->comment('点赞数')->default(0);
            $table->tinyInteger('status')->comment('1显示')->default(1);
            $table->char('code', 32)->nullable()->comment('调用代码');
            $table->bigInteger('created_by')->unsigned()->nullable()->comment('创建者');
            $table->bigInteger('updated_by')->unsigned()->nullable()->comment('更新者');
            $table->timestamps();
            $table->unique('code');
            $table->index('created_by');
        });
        Schema::create('category', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('分类表');
            $table->bigIncrements('id')->comment('ID');
            $table->json('name')->nullable()->comment('名称');
            $table->char('icon', 64)->nullable()->comment('icon');
            $table->integer('sort')->comment('排序')->default(100);
            $table->bigInteger('parent_id')->comment('上级')->default(0);
            $table->tinyInteger('status')->comment('1显示')->default(1);
            $table->string('remark')->nullable()->comment('备注');
            $table->char('code', 32)->nullable()->comment('调用代码');
            $table->bigInteger('created_by')->unsigned()->nullable()->comment('创建者');
            $table->bigInteger('updated_by')->unsigned()->nullable()->comment('更新者');
            $table->timestamps();
            $table->index('code');
        });
        Schema::create('category_correlation', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('分类关联表');
            $table->bigIncrements('id')->comment('主键');
            $table->bigInteger('category_id')->nullable()->comment('分类id');
            $table->bigInteger('data_id')->nullable()->comment('数据id');
            $table->tinyInteger('type')->nullable()->comment('1:article');
            $table->index('category_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('article');
        Schema::dropIfExists('category');
        Schema::dropIfExists('category_correlation');
    }
};
