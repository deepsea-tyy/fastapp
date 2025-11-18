<?php

declare(strict_types=1);


namespace Plugin\Ds\Article\Model;

use Carbon\Carbon;
use Hyperf\Database\Model\Relations\HasManyThrough;
use Hyperf\DbConnection\Model\Model;

/**
 * 文章表模型.
 *
 * @property array $title 标题
 * @property array $subtitle 副标题
 * @property string $author 作者
 * @property array $cover 封面
 * @property array $video 视频
 * @property string $release_at 发布日期
 * @property array $brief 摘要
 * @property array $content 内容
 * @property string $remark 备注
 * @property int $sort 排序
 * @property int $comment 评论数
 * @property int $views 浏览数
 * @property int $like 点赞数
 * @property int $status 1显示
 * @property string $code 调用代码
 * @property int $created_by 创建者
 * @property int $updated_by 更新者
 * @property Carbon $created_at 创建时间
 * @property Carbon $updated_at 更新时间
 */
final class Article extends Model
{
    /**
     * 数据表名称.
     */
    protected ?string $table = 'article';

    /**
     * 允许批量赋值的属性.
     */
    protected array $fillable = [
        'title',
        'subtitle',
        'author',
        'cover',
        'video',
        'release_at',
        'brief',
        'content',
        'remark',
        'sort',
        'comment',
        'views',
        'like',
        'status',
        'code',
        'created_by',
        'updated_by',
        'created_at',
        'updated_at',
    ];

    /**
     * 数据转换设置.
     */
    protected array $casts = [
        'title' => 'array',
        'subtitle' => 'array',
        'author' => 'string',
        'cover' => 'array',
        'video' => 'array',
        'release_at' => 'string',
        'brief' => 'array',
        'content' => 'array',
        'remark' => 'string',
        'sort' => 'integer',
        'comment' => 'integer',
        'views' => 'integer',
        'like' => 'integer',
        'status' => 'integer',
        'code' => 'string',
        'created_by' => 'integer',
        'updated_by' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * 隐藏的属性.
     */
    protected array $hidden = [];


    public function categories(): HasManyThrough
    {
        return $this->hasManyThrough(
            Category::class,
            CategoryCorrelation::class,
            'data_id', // Foreign key on category_correlation table
            'id', // Foreign key on category table  
            'id', // Local key on article table
            'category_id' // Local key on category_correlation table
        )->where('category_correlation.type', 1);
    }
}