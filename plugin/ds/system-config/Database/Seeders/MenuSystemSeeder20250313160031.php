<?php

declare(strict_types=1);

use App\Model\Permission\Menu;
use App\Model\Permission\Meta;
use Hyperf\Database\Seeders\Seeder;
use Hyperf\DbConnection\Db;

class MenuSystemSeeder20250313160031 extends Seeder
{
    public const BASE_DATA = [
        'name' => '',
        'path' => '',
        'component' => '',
        'redirect' => '',
        'created_by' => 0,
        'updated_by' => 0,
        'remark' => '',
    ];

    /**
     * Run the database seeds.
     */
    public function run()
    {
        echo '开始填充菜单数据' . \PHP_EOL;
        if (env('DB_DRIVER') === 'odbc-sql-server') {
            Db::unprepared('SET IDENTITY_INSERT [' . Menu::getModel()->getTable() . '] ON;');
        }
        $this->create($this->data());
        if (env('DB_DRIVER') === 'odbc-sql-server') {
            Db::unprepared('SET IDENTITY_INSERT [' . Menu::getModel()->getTable() . '] OFF;');
        }
    }

    public function data(): array
    {
        return [
            [
                'name' => 'plugin:ds:config',
                'path' => '/system',
                'component' => 'ds/system-config/views/index',
                'meta' => new Meta([
                    'title' => '系统设置',
                    'type' => 'M',
                    'hidden' => 0,
                    'icon' => 'ant-design:setting-outlined',
                    'i18n' => 'systemMenu.systemConfig.name',
                    'componentPath' => 'plugins/',
                    'componentSuffix' => '.vue',
                    'breadcrumbEnable' => 1,
                    'copyright' => 1,
                    'cache' => 1,
                    'affix' => 0,
                ]),
                'children' => [
                    [
                        'name' => 'plugin:ds:configGroup:list',
                        'meta' => new Meta([
                            'title' => '系统分组列表',
                            'i18n' => 'systemMenu.systemConfig.actions.index',
                            'type' => 'B',
                        ]),
                    ],
                    [
                        'name' => 'plugin:ds:configGroup:index:create',
                        'meta' => new Meta([
                            'title' => '系统分组创建',
                            'i18n' => 'systemMenu.systemConfig.actions.create',
                            'type' => 'B',
                        ]),
                    ],
                    [
                        'name' => 'plugin:ds:configGroup:update',
                        'meta' => new Meta([
                            'title' => '系统分组更新',
                            'i18n' => 'systemMenu.systemConfig.actions.update',
                            'type' => 'B',
                        ]),
                    ],
                    [
                        'name' => 'plugin:ds:configGroup:delete',
                        'meta' => new Meta([
                            'title' => '系统分组删除',
                            'i18n' => 'systemMenu.systemConfig.actions.delete',
                            'type' => 'B',
                        ]),
                    ],
                    [
                        'name' => 'plugin:ds:config:list',
                        'meta' => new Meta([
                            'title' => '系统配置列表',
                            'i18n' => 'systemMenu.systemConfig.actions.configIndex',
                            'type' => 'B',
                        ]),
                    ],
                    [
                        'name' => 'plugin:ds:config:details',
                        'meta' => new Meta([
                            'title' => '系统配置详情',
                            'i18n' => 'systemMenu.systemConfig.actions.configDetails',
                            'type' => 'B',
                        ]),
                    ],
                    [
                        'name' => 'plugin:ds:config:create',
                        'meta' => new Meta([
                            'title' => '系统配置创建',
                            'i18n' => 'systemMenu.systemConfig.actions.configCreate',
                            'type' => 'B',
                        ]),
                    ],
                    [
                        'name' => 'plugin:ds:config:update',
                        'meta' => new Meta([
                            'title' => '系统配置更新',
                            'i18n' => 'systemMenu.systemConfig.actions.configUpdate',
                            'type' => 'B',
                        ]),
                    ],
                    [
                        'name' => 'plugin:ds:config:delete',
                        'meta' => new Meta([
                            'title' => '系统配置删除',
                            'i18n' => 'systemMenu.systemConfig.actions.configDelete',
                            'type' => 'B',
                        ]),
                    ],
                    [
                        'name' => 'plugin:ds:config:batchUpdate',
                        'meta' => new Meta([
                            'title' => '系统配置批量更新',
                            'i18n' => 'systemMenu.systemConfig.actions.configBatchUpdate',
                            'type' => 'B',
                        ]),
                    ],
                ],
            ],
        ];
    }

    public function create(array $data, int $parent_id = 0): void
    {
        foreach ($data as $v) {
            $_v = $v;
            if (isset($v['children'])) {
                unset($_v['children']);
            }
            $_v['parent_id'] = $parent_id;

            // 判断菜单是否已存在
            $menu = Menu::where('name', $_v['name'])->where('parent_id', $parent_id)->first();

            if (! $menu) {
                // 不存在则创建
                $menu = Menu::create(array_merge(self::BASE_DATA, $_v));
            }

            // 如果有子菜单，递归创建
            if (isset($v['children']) && count($v['children'])) {
                $this->create($v['children'], $menu->id);
            }
        }
    }
}
