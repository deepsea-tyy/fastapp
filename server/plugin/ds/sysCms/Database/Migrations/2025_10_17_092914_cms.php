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
            $table->string('icon')->nullable()->comment('icon');
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
        // 投放位置表（定义投放位置，如首页轮播、侧边栏等）
        Schema::create('placement_position', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('投放位置表');
            $table->bigIncrements('id')->comment('主键');
            $table->string('code', 32)->nullable()->comment('调用代码（唯一标识符，如：home_banner）');
            $table->string('name', 128)->nullable()->comment('位置名称');
            $table->tinyInteger('status')->comment('状态：1启用 0禁用')->unsigned()->default(1);
            $table->bigInteger('created_by')->unsigned()->nullable()->comment('创建者');
            $table->bigInteger('updated_by')->unsigned()->nullable()->comment('更新者');
            $table->timestamps();
            $table->unique('code');
        });
        
        // 投放内容表（具体的投放内容，如文章、链接、视频等）
        Schema::create('placement_content', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('投放内容表');
            $table->bigIncrements('id')->comment('主键');
            $table->string('code', 32)->nullable()->comment('调用代码');
            $table->string('name', 128)->nullable()->comment('内容名称');
            $table->tinyInteger('object_type')->comment('数据类型：1链接 2视频 3分享 4文章 5路径')->unsigned()->default(1);
            $table->unsignedBigInteger('object_id')->nullable()->comment('关联数据ID（根据object_type关联不同表，object_type=4时关联article表）')->default(0);
            // 链接类型字段（object_type=1时使用）
            $table->string('url', 512)->nullable()->comment('链接地址（object_type=1）');
            $table->tinyInteger('target')->comment('链接打开方式：1当前窗口 2新窗口')->unsigned()->default(1);
            // 通用展示字段（所有类型都可能使用，用于覆盖关联数据的展示信息）
            $table->json('title')->nullable()->comment('标题（多语言，用于覆盖关联数据的标题）');
            $table->string('cover', 512)->nullable()->comment('封面图片URL（用于覆盖关联数据的封面）');
            $table->json('desc')->nullable()->comment('描述（多语言，用于覆盖关联数据的描述）');
            // 分享类型字段（object_type=3时使用）
            $table->json('content')->nullable()->comment('分享内容（多语言，object_type=3分享时使用）');
            // 时间控制
            $table->integer('start_at')->nullable()->comment('开始时间（时间戳）')->unsigned();
            $table->integer('end_at')->nullable()->comment('结束时间（时间戳）')->unsigned();
            $table->tinyInteger('fixed')->comment('永久有效：1是 0否')->unsigned()->default(0);
            // 状态管理
            $table->tinyInteger('status')->comment('状态：1显示 0隐藏')->unsigned()->default(1);
            $table->integer('sort')->comment('排序')->unsigned()->default(0);
            $table->string('remark')->nullable()->comment('备注');
            // 统计字段
            $table->integer('views')->comment('展示次数')->unsigned()->default(0);
            $table->integer('clicks')->comment('点击次数')->unsigned()->default(0);
            $table->bigInteger('created_by')->unsigned()->nullable()->comment('创建者');
            $table->bigInteger('updated_by')->unsigned()->nullable()->comment('更新者');
            $table->timestamps();
            $table->unique('code');
            $table->index(['object_type', 'object_id']);
        });
        
        // 投放位置与内容关联表（多对多关系）
        Schema::create('placement_position_content', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('投放位置内容关联表');
            $table->bigIncrements('id')->comment('主键');
            $table->unsignedBigInteger('position_id')->comment('投放位置ID');
            $table->unsignedBigInteger('content_id')->comment('投放内容ID');
            $table->timestamps();
            $table->index('position_id');
            $table->index('content_id');
        });
        // 页面内容表（核心表）
        Schema::create('app_page_content', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('App页面内容表');
            $table->bigIncrements('id')->comment('主键');
            $table->string('code', 64)->nullable()->comment('内容标识（唯一，如：home.welcome.title）');
            $table->string('page_code', 32)->comment('页面标识（如：home, market, spot）');
            $table->string('component_code', 32)->nullable()->comment('组件标识（如：top_bar, banner, quick_entrance）');
            $table->tinyInteger('content_type')->comment('内容类型：1固定文本 2列表数据 3富文本 4配置项')->unsigned()->default(1);
            $table->json('data')->nullable()->comment('内容数据（JSON，根据content_type存储不同类型的数据：1=多语言文本{"zh_CN":"中文","en":"English"} 2=列表数据[] 3=富文本{} 4=配置项{}）');
            $table->tinyInteger('platform')->comment('平台：1Web 2App 3Both')->unsigned()->default(2);
            $table->integer('start_at')->nullable()->comment('开始时间（时间戳）')->unsigned();
            $table->integer('end_at')->nullable()->comment('结束时间（时间戳）')->unsigned();
            $table->tinyInteger('fixed')->comment('永久有效：1是 0否')->unsigned()->default(1);
            $table->tinyInteger('status')->comment('状态：1启用 0禁用')->unsigned()->default(1);
            $table->integer('sort')->comment('排序')->unsigned()->default(100);
            $table->string('remark')->nullable()->comment('备注');
            $table->bigInteger('created_by')->unsigned()->nullable()->comment('创建者');
            $table->bigInteger('updated_by')->unsigned()->nullable()->comment('更新者');
            $table->timestamps();
            $table->unique('code');
            $table->index(['page_code', 'component_code']);
            $table->index('platform');
        });

        // 同步版本管理表
        Schema::create('app_page_content_sync', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('App页面内容同步版本管理表');
            $table->bigIncrements('id')->comment('主键');
            $table->string('version', 32)->comment('版本号（时间戳）');
            $table->tinyInteger('platform')->comment('平台：1Web 2App')->unsigned();
            $table->string('file_path', 255)->comment('文件路径');
            $table->integer('file_size')->comment('文件大小（字节）')->unsigned()->default(0);
            $table->integer('record_count')->comment('记录数量')->unsigned()->default(0);
            $table->timestamp('generated_at')->nullable()->comment('生成时间');
            $table->timestamps();
            $table->index('platform');
            $table->index('version');
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
        Schema::dropIfExists('placement_position');
        Schema::dropIfExists('placement_content');
        Schema::dropIfExists('placement_position_content');
        Schema::dropIfExists('app_page_content_sync');
        Schema::dropIfExists('app_page_content');
    }
};
