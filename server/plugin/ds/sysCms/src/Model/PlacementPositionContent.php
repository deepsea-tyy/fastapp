<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id 主键
 * @property int $position_id 投放位置ID
 * @property int $content_id 投放内容ID
 * @property \Carbon\Carbon $created_at 
 * @property \Carbon\Carbon $updated_at 
 */
class PlacementPositionContent extends Model
{
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'placement_position_content';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'position_id', 'content_id', 'created_at', 'updated_at'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = ['id' => 'integer', 'position_id' => 'integer', 'content_id' => 'integer', 'created_at' => 'datetime', 'updated_at' => 'datetime'];
}
