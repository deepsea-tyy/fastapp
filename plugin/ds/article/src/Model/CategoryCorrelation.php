<?php

declare(strict_types=1);

namespace Plugin\Ds\Article\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id 主键
 * @property int $category_id 分类id
 * @property int $data_id 数据id
 * @property int $type 1:article
 */
class CategoryCorrelation extends Model
{
    public bool $timestamps = false;
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'category_correlation';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'category_id', 'data_id', 'type'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = ['id' => 'integer', 'category_id' => 'integer', 'data_id' => 'integer', 'type' => 'integer'];
}
