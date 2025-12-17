<?php

declare(strict_types=1);

use Carbon\Carbon;
use Faker\Factory;
use Faker\Generator;
use Hyperf\Database\Seeders\Seeder;
use Plugin\Ds\SysCms\Model\FeedPost;
use Plugin\Ds\SysCms\Model\FeedComment;
use Plugin\Ds\SysCms\Model\FeedLike;
use Plugin\Ds\SysCms\Model\FeedCollect;
use Plugin\Ds\SysCms\Model\FeedUserFollow;
use Plugin\Ds\SysCms\Model\FeedTag;
use Plugin\Ds\SysCms\Model\FeedContentTag;

/**
 * 信息流测试数据生成器
 *
 * 使用方法：
 * cd server && php run_feed_seeder.php
 * 或使用脚本：
 * cd server && bash generate_feed_test_data.sh
 */
class FeedTestDataSeeder extends Seeder
{
    private Generator $faker;

    // 测试用户ID范围（假设已有用户ID 1-100）
    private const MIN_USER_ID = 1;
    private const MAX_USER_ID = 100;

    // 生成数量配置
    private const POST_COUNT = 50;        // 生成50个帖子
    private const COMMENT_COUNT = 200;    // 生成200条评论
    private const TAG_COUNT = 20;         // 生成20个标签

    public function __construct()
    {
        // 使用中文Faker
        $this->faker = Factory::create('zh_CN');
    }

    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        if (\Hyperf\Config\config('env') == 'prod') return;
        echo "🚀 开始生成信息流测试数据...\n\n";

        // 1. 生成标签
        echo "📌 生成标签数据...\n";
        $tags = $this->generateTags();
        echo "   ✓ 已生成 " . count($tags) . " 个标签\n\n";

        // 2. 生成帖子
        echo "📝 生成帖子数据...\n";
        $posts = $this->generatePosts();
        echo "   ✓ 已生成 " . count($posts) . " 个帖子\n\n";

        // 3. 为帖子添加标签
        echo "🏷️  为帖子添加标签...\n";
        $this->attachTagsToPosts($posts, $tags);
        echo "   ✓ 标签关联完成\n\n";

        // 4. 生成评论
        echo "💬 生成评论数据...\n";
        $comments = $this->generateComments($posts);
        echo "   ✓ 已生成 " . count($comments) . " 条评论\n\n";

        // 5. 生成点赞
        echo "👍 生成点赞数据...\n";
        $likeCount = $this->generateLikes($posts, $comments);
        echo "   ✓ 已生成 {$likeCount} 条点赞记录\n\n";

        // 6. 生成收藏
        echo "⭐ 生成收藏数据...\n";
        $collectCount = $this->generateCollects($posts);
        echo "   ✓ 已生成 {$collectCount} 条收藏记录\n\n";

        // 7. 生成关注关系
        echo "👥 生成关注关系...\n";
        $followCount = $this->generateFollows();
        echo "   ✓ 已生成 {$followCount} 条关注关系\n\n";

        echo "✅ 所有测试数据生成完成！\n";
    }

    /**
     * 生成标签
     */
    private function generateTags(): array
    {
        $tags = [];
        $tagNames = [
            '技术', '前端', '后端', '移动开发', '人工智能',
            '区块链', '创业', '产品', '设计', 'UX/UI',
            '投资理财', '职场', '生活', '旅行', '美食',
            '运动健身', '音乐', '电影', '读书', '摄影'
        ];

        foreach (array_slice($tagNames, 0, self::TAG_COUNT) as $index => $name) {
            $tag = FeedTag::create([
                'name' => [['lang' => 'zh_CN', 'text' => $name]],
                'icon' => null,
                'color' => $this->faker->hexColor(),
                'post_count' => 0,
                'follow_count' => 0,
                'is_hot' => $index < 5 ? 1 : 0,  // 前5个标记为热门
                'status' => 1,
            ]);
            $tags[] = $tag;
        }

        return $tags;
    }

    /**
     * 生成帖子
     */
    private function generatePosts(): array
    {
        $posts = [];
        $contentTypes = [1, 2, 3, 4]; // 1纯文本 2图文 3视频 4链接

        for ($i = 0; $i < self::POST_COUNT; $i++) {
            $contentType = $this->faker->randomElement($contentTypes);
            $userId = $this->faker->numberBetween(self::MIN_USER_ID, self::MAX_USER_ID);

            // 生成内容
            $content = $this->generatePostContent();
            $title = $this->faker->boolean(70) ? $this->faker->sentence() : null;

            // 根据类型生成相应的媒体
            $images = [];
            $videos = [];
            if ($contentType === 2) {
                // 图文：1-9张图片
                $imageCount = $this->faker->numberBetween(1, 9);
                for ($j = 0; $j < $imageCount; $j++) {
                    $images[] = $this->faker->imageUrl(800, 600, 'posts');
                }
            } elseif ($contentType === 3) {
                // 视频：1个视频
                $videos[] = 'https://example.com/videos/' . $this->faker->uuid() . '.mp4';
            }

            $post = FeedPost::create([
                'user_id' => $userId,
                'content_type' => $contentType,
                'title' => $title,
                'content' => $content,
                'images' => $images,
                'videos' => $videos,
                'link_url' => $contentType === 4 ? $this->faker->url() : null,
                'link_meta' => $contentType === 4 ? [
                    'title' => $this->faker->sentence(),
                    'description' => $this->faker->paragraph(),
                    'image' => $this->faker->imageUrl(),
                ] : null,
                'quoted_type' => null,
                'quoted_id' => null,
                'audit_status' => 1,  // 已审核通过
                'audited_at' => Carbon::now(),
                'is_top' => $this->faker->boolean(5) ? 1 : 0,  // 5%概率置顶
                'is_hot' => $this->faker->boolean(10) ? 1 : 0,  // 10%概率热门
                'status' => 1,
                'view_count' => $this->faker->numberBetween(0, 10000),
                'like_count' => 0,  // 后续通过点赞生成
                'comment_count' => 0,  // 后续通过评论生成
                'share_count' => $this->faker->numberBetween(0, 100),
                'collect_count' => 0,  // 后续通过收藏生成
                'quote_count' => 0,
                'ip' => $this->faker->ipv4(),
                'device_type' => $this->faker->randomElement(['ios', 'android', 'web']),
                'created_at' => $this->faker->dateTimeBetween('-30 days', 'now')->format('Y-m-d H:i:s'),
            ]);

            $posts[] = $post;
        }

        return $posts;
    }

    /**
     * 生成帖子内容
     */
    private function generatePostContent(): string
    {
        $templates = [
            fn() => $this->faker->paragraph(3),
            fn() => $this->faker->realText(200),
            fn() => implode("\n\n", $this->faker->paragraphs(2)),
            fn() => "分享一下我的经验：\n" . $this->faker->paragraph(),
            fn() => "今天遇到一个问题：\n" . $this->faker->sentence() . "\n\n解决方法：\n" . $this->faker->paragraph(),
        ];

        return $this->faker->randomElement($templates)();
    }

    /**
     * 为帖子添加标签
     */
    private function attachTagsToPosts(array $posts, array $tags): void
    {
        foreach ($posts as $post) {
            // 每个帖子随机1-3个标签
            $tagCount = $this->faker->numberBetween(1, 3);
            $selectedTags = $this->faker->randomElements($tags, $tagCount);

            foreach ($selectedTags as $tag) {
                FeedContentTag::create([
                    'tag_id' => $tag->id,
                    'target_type' => 1,  // 1:帖子
                    'target_id' => $post->id,
                    'created_at' => is_string($post->created_at) ? $post->created_at : $post->created_at->format('Y-m-d H:i:s'),
                ]);

                // 更新标签的帖子数
                $tag->increment('post_count');
            }
        }
    }

    /**
     * 生成评论
     */
    private function generateComments(array $posts): array
    {
        $comments = [];
        $commentsPerPost = (int)(self::COMMENT_COUNT / count($posts));

        foreach ($posts as $post) {
            // 每个帖子生成随机数量的评论
            $count = $this->faker->numberBetween(1, $commentsPerPost * 2);

            for ($i = 0; $i < $count; $i++) {
                $userId = $this->faker->numberBetween(self::MIN_USER_ID, self::MAX_USER_ID);

                // 80%顶级评论，20%回复评论
                $isReply = $this->faker->boolean(20) && count($comments) > 0;
                $parentId = 0;
                $rootId = 0;
                $replyToUserId = null;

                if ($isReply) {
                    // 随机选择一个已有评论作为父评论
                    $parentComment = $this->faker->randomElement($comments);
                    if ($parentComment->target_id === $post->id) {  // 确保是同一个帖子的评论
                        $parentId = $parentComment->id;
                        $rootId = $parentComment->root_id ?: $parentComment->id;
                        $replyToUserId = $parentComment->user_id;
                    }
                }

                $comment = FeedComment::create([
                    'target_type' => 1,  // 1:帖子
                    'target_id' => $post->id,
                    'user_id' => $userId,
                    'parent_id' => $parentId,
                    'root_id' => $rootId,
                    'reply_to_user_id' => $replyToUserId,
                    'content' => $this->generateCommentContent(),
                    'like_count' => 0,  // 后续通过点赞生成
                    'reply_count' => 0,
                    'status' => 1,
                    'created_at' => $this->faker->dateTimeBetween($post->created_at, 'now')->format('Y-m-d H:i:s'),
                ]);

                $comments[] = $comment;

                // 更新帖子的评论数
                $post->increment('comment_count');

                // 更新父评论的回复数
                if ($parentId > 0) {
                    FeedComment::where('id', $parentId)->increment('reply_count');
                }
            }
        }

        return $comments;
    }

    /**
     * 生成评论内容
     */
    private function generateCommentContent(): string
    {
        $templates = [
            fn() => $this->faker->sentence(),
            fn() => "同意！" . $this->faker->sentence(),
            fn() => "说得对👍",
            fn() => $this->faker->realText(100),
            fn() => "学习了，感谢分享",
            fn() => "有道理，" . $this->faker->sentence(),
        ];

        return $this->faker->randomElement($templates)();
    }

    /**
     * 生成点赞
     */
    private function generateLikes(array $posts, array $comments): int
    {
        $count = 0;

        // 为帖子生成点赞
        foreach ($posts as $post) {
            $likeCount = $this->faker->numberBetween(0, 50);

            for ($i = 0; $i < $likeCount; $i++) {
                $userId = $this->faker->numberBetween(self::MIN_USER_ID, self::MAX_USER_ID);

                // 避免重复点赞
                $exists = FeedLike::where('user_id', $userId)
                    ->where('target_type', 1)
                    ->where('target_id', $post->id)
                    ->exists();

                if (!$exists) {
                    FeedLike::create([
                        'user_id' => $userId,
                        'target_type' => 1,  // 1:帖子
                        'target_id' => $post->id,
                        'created_at' => $this->faker->dateTimeBetween($post->created_at, 'now')->format('Y-m-d H:i:s'),
                    ]);

                    $post->increment('like_count');
                    $count++;
                }
            }
        }

        // 为评论生成点赞
        foreach ($comments as $comment) {
            $likeCount = $this->faker->numberBetween(0, 10);

            for ($i = 0; $i < $likeCount; $i++) {
                $userId = $this->faker->numberBetween(self::MIN_USER_ID, self::MAX_USER_ID);

                // 避免重复点赞
                $exists = FeedLike::where('user_id', $userId)
                    ->where('target_type', 3)
                    ->where('target_id', $comment->id)
                    ->exists();

                if (!$exists) {
                    FeedLike::create([
                        'user_id' => $userId,
                        'target_type' => 3,  // 3:评论
                        'target_id' => $comment->id,
                        'created_at' => $this->faker->dateTimeBetween($comment->created_at, 'now')->format('Y-m-d H:i:s'),
                    ]);

                    $comment->increment('like_count');
                    $count++;
                }
            }
        }

        return $count;
    }

    /**
     * 生成收藏
     */
    private function generateCollects(array $posts): int
    {
        $count = 0;

        foreach ($posts as $post) {
            $collectCount = $this->faker->numberBetween(0, 20);

            for ($i = 0; $i < $collectCount; $i++) {
                $userId = $this->faker->numberBetween(self::MIN_USER_ID, self::MAX_USER_ID);

                // 避免重复收藏
                $exists = FeedCollect::where('user_id', $userId)
                    ->where('target_type', 1)
                    ->where('target_id', $post->id)
                    ->exists();

                if (!$exists) {
                    FeedCollect::create([
                        'user_id' => $userId,
                        'target_type' => 1,  // 1:帖子
                        'target_id' => $post->id,
                        'created_at' => $this->faker->dateTimeBetween($post->created_at, 'now')->format('Y-m-d H:i:s'),
                    ]);

                    $post->increment('collect_count');
                    $count++;
                }
            }
        }

        return $count;
    }

    /**
     * 生成关注关系
     */
    private function generateFollows(): int
    {
        $count = 0;

        // 每个用户随机关注5-15个其他用户
        for ($userId = self::MIN_USER_ID; $userId <= self::MAX_USER_ID; $userId++) {
            $followCount = $this->faker->numberBetween(5, 15);

            for ($i = 0; $i < $followCount; $i++) {
                $followUserId = $this->faker->numberBetween(self::MIN_USER_ID, self::MAX_USER_ID);

                // 不能关注自己
                if ($followUserId === $userId) {
                    continue;
                }

                // 避免重复关注
                $exists = FeedUserFollow::where('user_id', $userId)
                    ->where('follow_user_id', $followUserId)
                    ->exists();

                if (!$exists) {
                    FeedUserFollow::create([
                        'user_id' => $userId,
                        'follow_user_id' => $followUserId,
                        'created_at' => $this->faker->dateTimeBetween('-30 days', 'now')->format('Y-m-d H:i:s'),
                    ]);

                    $count++;
                }
            }
        }

        return $count;
    }
}
