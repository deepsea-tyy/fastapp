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
        // 1. 用户帖子表（仅用于用户发帖，UGC内容）
        Schema::create('feed_post', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('用户帖子表（UGC）');
            $table->bigIncrements('id')->comment('主键');
            $table->bigInteger('user_id')->unsigned()->comment('发布用户ID');
            $table->tinyInteger('type')->comment('帖子类型：1短贴 2标题贴')->unsigned()->default(1);
            $table->tinyInteger('content_type')->comment('内容类型：1纯文本 2图文 3视频 4链接')->unsigned()->default(1);

            // 内容字段
            $table->string('title', 255)->nullable()->comment('标题（可选）');
            $table->text('content')->comment('内容');
            $table->json('images')->nullable()->comment('图片列表（JSON数组）');
            $table->json('videos')->nullable()->comment('视频列表（JSON数组）');
            $table->string('link_url', 512)->nullable()->comment('外链地址');
            $table->json('link_meta')->nullable()->comment('链接元数据（标题、描述、封面等）');

            // 引用功能
            $table->tinyInteger('quoted_type')->nullable()->comment('引用类型：1短贴 2标题贴')->unsigned();
            $table->bigInteger('quoted_id')->nullable()->unsigned()->comment('引用的内容ID');

            // 审核状态
            $table->tinyInteger('audit_status')->comment('审核状态：0待审核 1已通过 2已拒绝')->unsigned()->default(0);
            $table->timestamp('audited_at')->nullable()->comment('审核时间');

            // 显示控制
            $table->tinyInteger('is_top')->comment('是否置顶：0否 1是')->unsigned()->default(0);
            $table->tinyInteger('is_hot')->comment('是否热门：0否 1是')->unsigned()->default(0);
            $table->tinyInteger('status')->comment('状态：1显示 0隐藏')->unsigned()->default(1);

            // 统计字段
            $table->integer('view_count')->comment('浏览次数')->unsigned()->default(0);
            $table->integer('like_count')->comment('点赞数')->unsigned()->default(0);
            $table->integer('comment_count')->comment('评论数')->unsigned()->default(0);
            $table->integer('share_count')->comment('分享数')->unsigned()->default(0);
            $table->integer('collect_count')->comment('收藏数')->unsigned()->default(0);
            $table->integer('quote_count')->comment('引用数')->unsigned()->default(0);

            // IP和设备信息
            $table->string('ip', 64)->nullable()->comment('发布IP');
            $table->string('device_type', 32)->nullable()->comment('设备类型：ios, android, web');

            $table->timestamps();
            $table->softDeletes()->comment('软删除');

            $table->index('user_id');
            $table->index('type');
            $table->index('audit_status');
            $table->index(['is_top', 'is_hot']);
            $table->index(['quoted_type', 'quoted_id']);
            $table->index('created_at');
        });

        // 2. 评论表（支持帖子和文章）
        Schema::create('feed_comment', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('评论表（通用）');
            $table->bigIncrements('id')->comment('主键');
            $table->tinyInteger('target_type')->comment('目标类型：1短贴 2标题贴 3公告 4新闻')->unsigned();
            $table->bigInteger('target_id')->unsigned()->comment('目标ID');
            $table->bigInteger('user_id')->unsigned()->comment('评论用户ID');
            $table->bigInteger('parent_id')->unsigned()->comment('父评论ID（0为顶级评论）')->default(0);
            $table->bigInteger('root_id')->unsigned()->comment('根评论ID（用于楼中楼）')->default(0);
            $table->bigInteger('reply_to_user_id')->unsigned()->nullable()->comment('回复的用户ID');
            $table->bigInteger('quoted_comment_id')->unsigned()->nullable()->comment('引用的评论ID');

            $table->text('content')->comment('评论内容');
            $table->json('images')->nullable()->comment('图片列表（JSON数组）');

            // 统计字段
            $table->integer('like_count')->comment('点赞数')->unsigned()->default(0);
            $table->integer('reply_count')->comment('回复数')->unsigned()->default(0);

            $table->tinyInteger('status')->comment('状态：1显示 0隐藏')->unsigned()->default(1);
            $table->timestamps();
            $table->softDeletes()->comment('软删除');

            $table->index(['target_type', 'target_id', 'status', 'created_at']);
            $table->index('user_id');
            $table->index('quoted_comment_id');
            $table->index('root_id');
        });

        // 3. 点赞表（通用）
        Schema::create('feed_like', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('点赞表（通用）');
            $table->bigIncrements('id')->comment('主键');
            $table->bigInteger('user_id')->unsigned()->comment('点赞用户ID');
            $table->tinyInteger('target_type')->comment('目标类型：1短贴 2标题贴 3公告 4新闻 5评论')->unsigned();
            $table->bigInteger('target_id')->unsigned()->comment('目标ID');
            $table->timestamp('created_at')->nullable()->comment('点赞时间');

            $table->unique(['user_id', 'target_type', 'target_id'], 'unique_user_like');
            $table->index(['target_type', 'target_id']);
        });

        // 4. 分享表（通用）
        Schema::create('feed_share', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('分享表（通用）');
            $table->bigIncrements('id')->comment('主键');
            $table->bigInteger('user_id')->unsigned()->comment('分享用户ID');
            $table->tinyInteger('target_type')->comment('目标类型：1短贴 2标题贴 3公告 4新闻')->unsigned();
            $table->bigInteger('target_id')->unsigned()->comment('目标ID');
            $table->tinyInteger('share_type')->comment('分享类型：1复制链接 2分享平台 3站内引用')->unsigned();
            $table->string('platform', 32)->nullable()->comment('分享平台');
            $table->timestamp('created_at')->nullable()->comment('分享时间');

            $table->index(['target_type', 'target_id']);
            $table->index('user_id');
        });

        // 5. 收藏表（通用）
        Schema::create('feed_collect', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('收藏表（通用）');
            $table->bigIncrements('id')->comment('主键');
            $table->bigInteger('user_id')->unsigned()->comment('收藏用户ID');
            $table->tinyInteger('target_type')->comment('目标类型：1短贴 2标题贴 3公告 4新闻')->unsigned();
            $table->bigInteger('target_id')->unsigned()->comment('目标ID');
            $table->timestamp('created_at')->nullable()->comment('收藏时间');

            $table->unique(['user_id', 'target_type', 'target_id'], 'unique_user_collect');
            $table->index(['user_id', 'created_at']);
        });

        // 注：浏览次数统计直接更新 feed_post.view_count 和 article.views
        // 如需详细浏览记录，建议使用大数据方案（ClickHouse、日志文件等）

        // 6. 用户关注用户表（核心社交功能）
        Schema::create('feed_user_follow', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('用户关注用户表');
            $table->bigInteger('user_id')->unsigned()->comment('关注者ID');
            $table->bigInteger('follow_user_id')->unsigned()->comment('被关注者ID');
            $table->timestamp('created_at')->nullable()->comment('关注时间');

            $table->primary(['user_id', 'follow_user_id']);
            $table->index('follow_user_id'); // 查询粉丝列表
        });

        // 7. 采集源配置表（采集到 article 表）
        Schema::create('feed_crawler_source', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('采集源配置表');
            $table->bigIncrements('id')->comment('主键');
            $table->string('name', 128)->comment('采集源名称');
            $table->string('code', 64)->unique()->comment('采集源代码');
            $table->tinyInteger('source_type')->comment('来源类型：1RSS 2API 3网页爬虫')->unsigned();
            $table->string('source_url', 512)->comment('来源地址');
            $table->bigInteger('category_id')->unsigned()->nullable()->comment('默认分类ID');
            $table->json('config')->nullable()->comment('采集配置');
            $table->tinyInteger('auto_publish')->comment('自动发布：0否 1是')->unsigned()->default(0);
            $table->integer('fetch_interval')->comment('采集间隔（分钟）')->unsigned()->default(60);
            $table->timestamp('last_fetch_at')->nullable()->comment('最后采集时间');
            $table->tinyInteger('status')->comment('状态：1启用 0禁用')->unsigned()->default(1);
            $table->timestamps();

            $table->index('status');
        });

        // 8. 采集任务表
        Schema::create('feed_crawler_task', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('采集任务表');
            $table->bigIncrements('id')->comment('主键');
            $table->bigInteger('source_id')->unsigned()->comment('采集源ID');
            $table->tinyInteger('task_status')->comment('任务状态：0待处理 1处理中 2已完成 3失败')->unsigned()->default(0);
            $table->timestamp('start_at')->nullable()->comment('开始时间');
            $table->timestamp('end_at')->nullable()->comment('结束时间');
            $table->integer('success_count')->comment('成功数')->unsigned()->default(0);
            $table->integer('fail_count')->comment('失败数')->unsigned()->default(0);
            $table->text('error_message')->nullable()->comment('错误信息');
            $table->timestamp('created_at')->nullable()->comment('创建时间');

            $table->index(['source_id', 'task_status']);
            $table->index('created_at');
        });

        // 9. 采集内容去重表
        Schema::create('feed_crawler_dedup', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('采集内容去重表');
            $table->bigIncrements('id')->comment('主键');
            $table->bigInteger('source_id')->unsigned()->comment('采集源ID');
            $table->string('content_hash', 64)->comment('内容hash');
            $table->string('source_url', 512)->nullable()->comment('原文链接');
            $table->bigInteger('article_id')->unsigned()->nullable()->comment('关联文章ID');
            $table->timestamp('created_at')->nullable()->comment('首次采集时间');

            $table->unique(['source_id', 'content_hash']);
            $table->index('article_id');
        });

        // 10. 举报表（通用）
        Schema::create('feed_report', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('举报表（通用）');
            $table->bigIncrements('id')->comment('主键');
            $table->bigInteger('user_id')->unsigned()->comment('举报用户ID');
            $table->tinyInteger('target_type')->comment('目标类型：1帖子 2文章 3公告 4新闻 5评论')->unsigned();
            $table->bigInteger('target_id')->unsigned()->comment('目标ID');
            $table->tinyInteger('report_type')->comment('举报原因：1垃圾广告 2色情低俗 3违法违规 4侮辱谩骂 5其他')->unsigned();
            $table->text('content')->nullable()->comment('举报说明');
            $table->json('images')->nullable()->comment('举报图片');
            $table->tinyInteger('handle_status')->comment('处理状态：0待处理 1已处理 2已忽略')->unsigned()->default(0);
            $table->timestamp('handled_at')->nullable()->comment('处理时间');
            $table->timestamps();

            $table->index(['handle_status', 'created_at']);
            $table->index(['target_type', 'target_id']);
        });

        // 11. 标签表
        Schema::create('feed_tag', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('标签表');
            $table->bigIncrements('id')->comment('主键');
            $table->json('name')->comment('标签名称（多语言）');
            $table->string('icon')->nullable()->comment('标签图标');
            $table->string('color', 32)->nullable()->comment('标签颜色');
            $table->integer('post_count')->comment('内容数量')->unsigned()->default(0);
            $table->integer('follow_count')->comment('关注数')->unsigned()->default(0);
            $table->tinyInteger('is_hot')->comment('是否热门')->unsigned()->default(0);
            $table->tinyInteger('status')->comment('状态：1启用 0禁用')->unsigned()->default(1);
            $table->timestamps();

            $table->index(['is_hot', 'post_count']);
        });

        // 12. 内容标签关联表（通用）
        Schema::create('feed_content_tag', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('内容标签关联表');
            $table->tinyInteger('target_type')->comment('目标类型：1短贴 2标题贴 3公告 4新闻')->unsigned();
            $table->bigInteger('target_id')->unsigned()->comment('目标ID');
            $table->bigInteger('tag_id')->unsigned()->comment('标签ID');
            $table->timestamp('created_at')->nullable()->comment('创建时间');

            $table->primary(['target_type', 'target_id', 'tag_id']);
            $table->index('tag_id');
        });

        // 13. 用户关注标签表（辅助功能）
        Schema::create('feed_user_follow_tag', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('用户关注标签表');
            $table->bigInteger('user_id')->unsigned()->comment('用户ID');
            $table->bigInteger('tag_id')->unsigned()->comment('标签ID');
            $table->timestamp('created_at')->nullable()->comment('关注时间');

            $table->primary(['user_id', 'tag_id']);
            $table->index('tag_id');
        });

        // 14. 用户已读位置表
        Schema::create('feed_user_read_position', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('用户已读位置表');
            $table->bigInteger('user_id')->unsigned()->comment('用户ID');
            $table->tinyInteger('feed_type')->comment('信息流类型：1帖子 2公告 3新闻')->unsigned();
            $table->timestamp('last_read_at')->nullable()->comment('最后阅读时间');

            $table->primary(['user_id', 'feed_type']);
        });

        // 15. 内容质量反馈表
        Schema::create('feed_quality_feedback', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('内容质量反馈表');
            $table->bigIncrements('id')->comment('主键');
            $table->bigInteger('user_id')->unsigned()->comment('反馈用户ID');
            $table->tinyInteger('target_type')->comment('目标类型：1短贴 2标题贴 3公告 4新闻')->unsigned();
            $table->bigInteger('target_id')->unsigned()->comment('目标ID');
            $table->tinyInteger('quality_type')->comment('质量类型：1对投资没有帮助 2内容质量差')->unsigned();
            $table->timestamp('created_at')->nullable()->comment('反馈时间');

            $table->unique(['user_id', 'target_type', 'target_id']);
            $table->index(['target_type', 'target_id']);
        });

        // 16. 信息流用户统计表
        Schema::create('feed_user_stats', static function (Blueprint $table) {
            $table->comment('信息流用户统计表');
            $table->bigInteger('user_id')->unsigned()->primary()->comment('用户ID');
            $table->integer('following_count')->unsigned()->default(0)->comment('关注数');
            $table->integer('followers_count')->unsigned()->default(0)->comment('粉丝数');
            $table->integer('posts_count')->unsigned()->default(0)->comment('帖子数');
            $table->integer('total_likes')->unsigned()->default(0)->comment('获得的总点赞数');
            $table->integer('total_shares')->unsigned()->default(0)->comment('获得的总分享数');
            $table->integer('total_comments')->unsigned()->default(0)->comment('获得的总评论数');
            $table->integer('total_views')->unsigned()->default(0)->comment('获得的总浏览数');
            $table->timestamps();

            // 索引
            $table->index('followers_count');
            $table->index('posts_count');
            $table->index('total_likes');
        });

        // 17. 信息流曝光记录表
        Schema::create('feed_impression', function (Blueprint $table) {
            $table->engine = 'Innodb';
            $table->comment('信息流曝光记录表');
            $table->bigIncrements('id')->comment('主键');
            $table->bigInteger('user_id')->unsigned()->comment('用户ID');
            $table->bigInteger('content_id')->unsigned()->comment('内容ID');
            $table->tinyInteger('content_type')->unsigned()->comment('内容类型：1帖子 2文章 3公告 4新闻');
            $table->tinyInteger('feed_type')->unsigned()->comment('Feed类型：1关注 2推荐');
            $table->timestamp('impressed_at')->nullable()->comment('曝光时间');

            // 唯一索引：同一用户对同一内容只记录一次曝光
            $table->unique(['user_id', 'content_id', 'content_type'], 'unique_user_content');
            $table->index('content_id');
            $table->index('feed_type');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('feed_impression');
        Schema::dropIfExists('feed_user_stats');
        Schema::dropIfExists('feed_quality_feedback');
        Schema::dropIfExists('feed_user_read_position');
        Schema::dropIfExists('feed_user_follow_tag');
        Schema::dropIfExists('feed_content_tag');
        Schema::dropIfExists('feed_tag');
        Schema::dropIfExists('feed_report');
        Schema::dropIfExists('feed_crawler_dedup');
        Schema::dropIfExists('feed_crawler_task');
        Schema::dropIfExists('feed_crawler_source');
        Schema::dropIfExists('feed_user_follow');
        Schema::dropIfExists('feed_collect');
        Schema::dropIfExists('feed_share');
        Schema::dropIfExists('feed_like');
        Schema::dropIfExists('feed_comment');
        Schema::dropIfExists('feed_post');
    }
};
