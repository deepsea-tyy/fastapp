<?php

declare(strict_types=1);

namespace Plugin\Ds\Kefu\Schema;

use Hyperf\Swagger\Annotation\Property;
use Hyperf\Swagger\Annotation\Schema;
use Plugin\Ds\Kefu\Model\Kefu;

/**
 * 客服表
 */
#[Schema(title: 'KefuSchema')]
class KefuSchema implements \JsonSerializable
{
    #[Property(property: 'id', title: 'ID', type: 'bigint')]
    public string $id;

    #[Property(property: 'nickname', title: '昵称', type: 'varchar')]
    public string $nickname;

    #[Property(property: 'avatar', title: '头像', type: 'varchar')]
    public string $avatar;

    #[Property(property: 'status', title: '1启用2禁用', type: 'tinyint')]
    public string $status;

    #[Property(property: 'max_concurrent', title: '最大会话数', type: 'int')]
    public string $max_concurrent;

    #[Property(property: 'current_concurrent', title: '当前会话数', type: 'int')]
    public string $current_concurrent;

    #[Property(property: 'created_at', title: 'created_at', type: 'timestamp')]
    public string $created_at;

    #[Property(property: 'updated_at', title: 'updated_at', type: 'timestamp')]
    public string $updated_at;

    #[Property(property: 'created_by', title: '创建者', type: 'bigint')]
    public string $created_by;

    #[Property(property: 'updated_by', title: '更新者', type: 'bigint')]
    public string $updated_by;

    public function __construct(Kefu $model)
    {
        $this->id = $model->id;
        $this->nickname = $model->nickname;
        $this->avatar = $model->avatar;
        $this->status = $model->status;
        $this->max_concurrent = $model->max_concurrent;
        $this->current_concurrent = $model->current_concurrent;
        $this->created_at = $model->created_at;
        $this->updated_at = $model->updated_at;
        $this->created_by = $model->created_by;
        $this->updated_by = $model->updated_by;
    }

    public function jsonSerialize(): array
    {
        return [
            'id' => $this->id,
            'nickname' => $this->nickname,
            'avatar' => $this->avatar,
            'status' => $this->status,
            'max_concurrent' => $this->max_concurrent,
            'current_concurrent' => $this->current_concurrent,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            'created_by' => $this->created_by,
            'updated_by' => $this->updated_by
        ];
    }
}
