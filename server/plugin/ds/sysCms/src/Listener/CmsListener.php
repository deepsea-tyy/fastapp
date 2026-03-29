<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Listener;

use App\Common\Event\UserRegisterEvent;
use App\Common\Tools;
use App\Model\Search\SearchIndex;
use App\Service\AI\ContentExtractorService;
use Hyperf\Event\Annotation\Listener;
use Hyperf\Event\Contract\ListenerInterface;
use Plugin\Ds\SysCms\Event\ArticleEvent;
use Plugin\Ds\SysCms\Event\FeedEvent;
use Plugin\Ds\SysCms\Model\Article;
use Plugin\Ds\SysCms\Model\Category;
use Plugin\Ds\SysCms\Model\FeedPost;
use Plugin\Ds\SysCms\Model\FeedUserStats;

/**
 * 搜索索引监听器
 * 监听内容创建、更新、删除事件，自动更新搜索索引
 */
#[Listener]
class CmsListener implements ListenerInterface
{
    public function listen(): array
    {
        return [
            ArticleEvent::class,
            FeedEvent::class,
            UserRegisterEvent::class
        ];
    }

    public function process(object $event): void
    {
        if ($event instanceof FeedEvent) {
            // 根据 type 字段区分短贴(1)和标题贴(2)
            $model = FeedPost::query()->find($event->id);
            if (!$model) {
                $this->handleDelete($event->id, 1);
                return;
            }
            $type = $model->type === 2 ? 'feed_article' : 'feed';
            $this->indexContent($type, $model);
        } elseif ($event instanceof ArticleEvent) {
            // 根据分类 code 确定类型
            $model = Article::query()->find($event->id);
            if (!$model) {
                $this->handleDelete($event->id, 2);
                return;
            }

            $type = 'article';
            foreach (Category::query()
                         ->whereIn('id', $event->categoryIds)
                         ->pluck('code')->toArray() as $code) {
                if ($code === 'notice') {
                    $type = 'notice';
                }
                if ($code === 'news') {
                    $type = 'news';
                }
            }
            $model->title = Tools::formatLang($model->title ?: [], 'zh_CN');
            $model->content = Tools::formatLang($model->content ?: [], 'zh_CN');
            $this->indexContent($type, $model);
        } elseif ($event instanceof UserRegisterEvent) {
            FeedUserStats::query()->create(['user_id'=>$event->getUser()->id]);
        }
    }

    /**
     * 索引内容
     */
    private function indexContent(string $type, $model): void
    {
        try {
            // 使用 AI 提取内容
            $extractor = Tools::getContainer()->get(ContentExtractorService::class);
            $extracted = $extractor->extractContent($type, $model->toArray());

            // 准备索引数据
            $indexData = [
                'target_type' => $type,
                'target_id' => $model->id,
                'title' => $model->title,
                'content' => $model->content,
                'tags' => $extracted['tags'] ?? '',
                'keyword' => $extracted['keyword'] ?? '',
                'click_count' => $model->view_count ?? 0,
                'last_at' => $this->getLastAt($type, $model),
            ];

            // 更新或创建索引
            SearchIndex::query()->updateOrCreate(
                ['target_type' => $type, 'target_id' => $model->id],
                $indexData
            );

        } catch (\Exception $e) {
            Tools::logAsync($e->getMessage());
        }
    }

    /**
     * 获取最后更新时间
     */
    private function getLastAt(string $type, $model)
    {
        if ($type === 'article' || $type === 'notice' || $type === 'news') {
            return $model->release_at ?: $model->created_at;
        }

        return $model->created_at;
    }

    /**
     * 处理删除事件
     */
    private function handleDelete(int $id, int $type): void
    {
        try {
            $in = [];
            if ($type == 1) {
                $in = ['feed_article', 'feed'];
            } elseif ($type == 2) {
                $in = ['notice', 'news', 'article'];
            }
            if ($in) SearchIndex::query()
                ->whereIn('target_type', $in)
                ->where('target_id', $id)
                ->delete();
        } catch (\Exception $e) {
            Tools::logAsync($e->getMessage());
        }
    }
}
