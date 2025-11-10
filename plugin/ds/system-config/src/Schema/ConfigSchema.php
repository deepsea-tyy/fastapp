<?php

declare(strict_types=1);


namespace Plugin\Ds\SystemConfig\Schema;


use Hyperf\Swagger\Annotation\Property;
use Hyperf\Swagger\Annotation\Schema;
use Plugin\Ds\SystemConfig\Model\Config;

/**
 * 参数配置表.
 */
#[Schema(title: 'ConfigSchema')]
class ConfigSchema implements \JsonSerializable
{
    #[Property(property: 'group_code', title: '组id', type: 'varchar')]
    public int $group_code;

    #[Property(property: 'key', title: '配置键名', type: 'varchar')]
    public string $key;

    #[Property(property: 'value', title: '配置值', type: 'varchar')]
    public string $value;

    #[Property(property: 'name', title: '配置名称', type: 'varchar')]
    public string $name;

    #[Property(property: 'input_type', title: '数据输入类型', type: 'varchar')]
    public string $input_type;

    #[Property(property: 'config_select_data', title: '配置选项数据', type: 'varchar')]
    public array $config_select_data;

    #[Property(property: 'sort', title: '排序', type: 'smallint')]
    public int $sort;

    #[Property(property: 'remark', title: '备注', type: 'varchar')]
    public string $remark;

    public function __construct(Config $model)
    {
        $this->group_code = $model->group_code;
        $this->key = $model->key;
        $this->value = $model->value;
        $this->name = $model->name;
        $this->input_type = $model->input_type;
        $this->config_select_data = $model->config_select_data;
        $this->sort = $model->sort;
        $this->remark = $model->remark;
    }

    public function jsonSerialize(): array
    {
        return [
            'group_code' => $this->group_code,
            'key' => $this->key,
            'value' => $this->value,
            'name' => $this->name,
            'input_type' => $this->input_type,
            'config_select_data' => $this->config_select_data,
            'sort' => $this->sort,
            'remark' => $this->remark,
        ];
    }
}
