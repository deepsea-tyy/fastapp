<?php

declare(strict_types=1);


namespace Plugin\Ds\SystemConfig\Schema;


use Hyperf\Swagger\Annotation\Property;
use Hyperf\Swagger\Annotation\Schema;
use Plugin\Ds\SystemConfig\Model\ConfigGroup;

/**
 * 参数配置分组表.
 */
#[Schema(title: 'ConfigGroupSchema')]
class ConfigGroupSchema implements \JsonSerializable
{
    #[Property(property: 'id', title: '主键', type: 'bigint')]
    public int $id;

    #[Property(property: 'name', title: '配置组名称', type: 'varchar')]
    public string $name;

    #[Property(property: 'code', title: '配置组标识', type: 'varchar')]
    public string $code;

    #[Property(property: 'icon', title: '配置组图标', type: 'varchar')]
    public string $icon;

    #[Property(property: 'created_by', title: '创建者', type: 'bigint')]
    public int $created_by;

    #[Property(property: 'updated_by', title: '更新者', type: 'bigint')]
    public int $updated_by;

    #[Property(property: 'created_at', title: '创建时间', type: 'timestamp')]
    public mixed $created_at;

    #[Property(property: 'updated_at', title: '更新时间', type: 'timestamp')]
    public mixed $updated_at;

    #[Property(property: 'remark', title: '备注', type: 'varchar')]
    public string $remark;

    public function __construct(ConfigGroup $model)
    {
        $this->id = $model->id;
        $this->name = $model->name;
        $this->code = $model->code;
        $this->icon = $model->icon;
        $this->created_by = $model->created_by;
        $this->updated_by = $model->updated_by;
        $this->created_at = $model->created_at;
        $this->updated_at = $model->updated_at;
        $this->remark = $model->remark;
    }

    public function jsonSerialize(): array
    {
        return ['id' => $this->id, 'name' => $this->name, 'code' => $this->code, 'icon' => $this->icon, 'created_by' => $this->created_by, 'updated_by' => $this->updated_by, 'created_at' => $this->created_at, 'updated_at' => $this->updated_at, 'remark' => $this->remark];
    }
}
