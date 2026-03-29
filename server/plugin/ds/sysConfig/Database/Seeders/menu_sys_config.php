<?php

declare(strict_types=1);

use App\Model\Permission\Menu;
use App\Model\Permission\Meta;
use Hyperf\Database\Seeders\Seeder;
use Hyperf\DbConnection\Db;

class MenuSysConfig extends Seeder
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
                'name' => 'ds:sysConfig',
                'path' => '/system',
                'component' => 'ds/sysConfig/views/index',
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
                        'name' => 'ds:sysConfigGroup:list',
                        'meta' => new Meta([
                            'title' => '系统分组列表',
                            'i18n' => 'systemMenu.systemConfig.actions.index',
                            'type' => 'B',
                        ]),
                    ],
                    [
                        'name' => 'ds:sysConfigGroup:index:create',
                        'meta' => new Meta([
                            'title' => '系统分组创建',
                            'i18n' => 'systemMenu.systemConfig.actions.create',
                            'type' => 'B',
                        ]),
                    ],
                    [
                        'name' => 'ds:sysConfigGroup:update',
                        'meta' => new Meta([
                            'title' => '系统分组更新',
                            'i18n' => 'systemMenu.systemConfig.actions.update',
                            'type' => 'B',
                        ]),
                    ],
                    [
                        'name' => 'ds:sysConfigGroup:delete',
                        'meta' => new Meta([
                            'title' => '系统分组删除',
                            'i18n' => 'systemMenu.systemConfig.actions.delete',
                            'type' => 'B',
                        ]),
                    ],
                    [
                        'name' => 'ds:sysConfig:list',
                        'meta' => new Meta([
                            'title' => '系统配置列表',
                            'i18n' => 'systemMenu.systemConfig.actions.configIndex',
                            'type' => 'B',
                        ]),
                    ],
                    [
                        'name' => 'ds:sysConfig:details',
                        'meta' => new Meta([
                            'title' => '系统配置详情',
                            'i18n' => 'systemMenu.systemConfig.actions.configDetails',
                            'type' => 'B',
                        ]),
                    ],
                    [
                        'name' => 'ds:sysConfig:create',
                        'meta' => new Meta([
                            'title' => '系统配置创建',
                            'i18n' => 'systemMenu.systemConfig.actions.configCreate',
                            'type' => 'B',
                        ]),
                    ],
                    [
                        'name' => 'ds:sysConfig:update',
                        'meta' => new Meta([
                            'title' => '系统配置更新',
                            'i18n' => 'systemMenu.systemConfig.actions.configUpdate',
                            'type' => 'B',
                        ]),
                    ],
                    [
                        'name' => 'ds:sysConfig:delete',
                        'meta' => new Meta([
                            'title' => '系统配置删除',
                            'i18n' => 'systemMenu.systemConfig.actions.configDelete',
                            'type' => 'B',
                        ]),
                    ],
                    [
                        'name' => 'ds:sysConfig:batchUpdate',
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
        foreach ($data as $menuItem) {
            $children = $menuItem['children'] ?? null;
            unset($menuItem['children']);

            $menuData = array_merge(self::BASE_DATA, $menuItem, ['parent_id' => $parent_id]);

            $menu = $this->findOrCreateMenu($menuData);

            if ($children && count($children) > 0) {
                $this->create($children, $menu->id);
            }
        }
    }

    /**
     * 查找或创建菜单
     *
     * @param array $menuData 菜单数据
     * @return Menu
     */
    private function findOrCreateMenu(array $menuData): Menu
    {
        $menuName = $menuData['name'] ?? null;
        $parentId = $menuData['parent_id'] ?? 0;

        if (!$menuName) {
            return Menu::create($menuData);
        }

        $menu = Menu::query()
            ->where('name', $menuName)
            ->where('parent_id', $parentId)
            ->first();

        if ($menu) {
            $updateData = $menuData;
            $menu->update($updateData);
            return $menu;
        }

        return Menu::create($menuData);
    }
}
