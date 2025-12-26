<?php

declare(strict_types=1);


namespace Plugin\Ds\SysCms\Model;

use App\Model\UserProfile;
use Carbon\Carbon;
use Hyperf\Database\Model\Relations\HasManyThrough;
use Hyperf\Database\Model\Relations\HasOne;
use Hyperf\DbConnection\Model\Model;

/**
 * 文章表模型.
 *
 * @property string $title 标题
 * @property string $subtitle 副标题
 * @property string $author 作者
 * @property string $cover 封面
 * @property string $video 视频
 * @property string $lang
 * @property string $release_at 发布日期
 * @property string $brief 摘要
 * @property string $content 内容
 * @property string $remark 备注
 * @property int $sort 排序
 * @property int $view_count 浏览数
 * @property int $like_count 点赞数
 * @property int $comment_count 评论数
 * @property int $share_count 分享数
 * @property int $collect_count 收藏数
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
        'lang',
        'video',
        'release_at',
        'brief',
        'content',
        'remark',
        'sort',
        'view_count',
        'like_count',
        'comment_count',
        'share_count',
        'collect_count',
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
        'sort' => 'integer',
        'view_count' => 'integer',
        'like_count' => 'integer',
        'comment_count' => 'integer',
        'share_count' => 'integer',
        'collect_count' => 'integer',
        'status' => 'integer',
        'created_by' => 'integer',
        'updated_by' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * 隐藏的属性.
     */
    protected array $hidden = [];

    public function profile(): HasOne
    {
        return $this->hasOne(UserProfile::class, 'user_id', 'created_by');
    }

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