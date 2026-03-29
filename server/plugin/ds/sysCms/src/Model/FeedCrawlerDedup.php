<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id 主键
 * @property int $source_id 采集源ID
 * @property string $content_hash 内容hash
 * @property string $source_url 原文链接
 * @property int $article_id 关联文章ID
 * @property string $created_at 首次采集时间
 */
class FeedCrawlerDedup extends Model
{
    public bool $timestamps = false;
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'feed_crawler_dedup';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'source_id', 'content_hash', 'source_url', 'article_id', 'created_at'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = ['id' => 'integer', 'source_id' => 'integer', 'article_id' => 'integer'];
}
