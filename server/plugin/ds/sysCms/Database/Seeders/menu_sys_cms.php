<?php

declare(strict_types=1);

use App\Model\Permission\Menu;
use App\Model\Permission\Meta;
use Hyperf\Database\Seeders\Seeder;
use Hyperf\DbConnection\Db;

class MenuSysCms extends Seeder
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
    public function run(): void
    {
        if (env('DB_DRIVER') === 'odbc-sql-server') {
            Db::unprepared('SET IDENTITY_INSERT [' . Menu::getModel()->getTable() . '] ON;');
        }
        Db::unprepared("INSERT INTO app_page_content (code, page_code, component_code, content_type, `data`, platform, start_at, end_at, fixed, status, sort, remark, created_by, updated_by, created_at, updated_at) VALUES('home.navIcon', 'home', NULL, 1, '[{\"icon\": \"\", \"label\": \"c2c买币\"}]', 3, NULL, NULL, 1, 1, 100, '首页导航快捷图标', 1, NULL, '2025-12-08 21:06:01', '2025-12-08 21:06:53');");
        $this->create($this->data());
        if (env('DB_DRIVER') === 'odbc-sql-server') {
            Db::unprepared('SET IDENTITY_INSERT [' . Menu::getModel()->getTable() . '] OFF;');
        }
    }

    /**
     * Database seeds data.
     */
    public function data(): array
    {
        return [
            [
                'name' => 'ds:sysCms',
                'path' => '/ds/sysCms',
                'meta' => new Meta([
                    'title' => '内容管理',
                    'i18n' => 'article.ArticleManager',
                    'icon' => 'mdi:menu',
                    'type' => 'M',
                    'hidden' => false,
                    'componentPath' => 'modules/',
                    'componentSuffix' => '.vue',
                    'breadcrumbEnable' => true,
                    'copyright' => true,
                    'cache' => true,
                    'affix' => false,
                ]),
                'children' => [
                    [
                        'name' => 'ds:sysCms:article',
                        'path' => '/article/article',
                        'component' => 'ds/sysCms/views/article/index',
                        'meta' => new Meta([
                            'title' => '文章列表',
                            'i18n' => 'article.Article',
                            'icon' => 'mdi:menu',
                            'type' => 'M',
                            'hidden' => false,
                            'componentPath' => 'modules/',
                            'componentSuffix' => '.vue',
                            'breadcrumbEnable' => true,
                            'copyright' => true,
                            'cache' => true,
                            'affix' => false,
                        ]),
                        'children' => [
                            [
                                'name' => 'ds:sysCms:article:list',
                                'meta' => new Meta([
                                    'title' => 'List',
                                    'i18n' => 'crud.list',
                                    'type' => 'B',
                                ]),
                            ],
                            [
                                'name' => 'ds:sysCms:article:create',
                                'meta' => new Meta([
                                    'title' => 'Add',
                                    'i18n' => 'crud.add',
                                    'type' => 'B',
                                ]),
                            ],
                            [
                                'name' => 'ds:sysCms:article:save',
                                'meta' => new Meta([
                                    'title' => 'Edit',
                                    'i18n' => 'crud.edit',
                                    'type' => 'B',
                                ]),
                            ],
                            [
                                'name' => 'ds:sysCms:article:delete',
                                'meta' => new Meta([
                                    'title' => 'Delete',
                                    'i18n' => 'crud.delete',
                                    'type' => 'B',
                                ]),
                            ],
                        ],
                    ],
                    [
                        'name' => 'ds:sysCms:category',
                        'path' => '/article/category',
                        'component' => 'ds/sysCms/views/category/index',
                        'meta' => new Meta([
                            'title' => '分类列表',
                            'i18n' => 'article.Category',
                            'icon' => 'mdi:menu',
                            'type' => 'M',
                            'hidden' => false,
                            'componentPath' => 'modules/',
                            'componentSuffix' => '.vue',
                            'breadcrumbEnable' => true,
                            'copyright' => true,
                            'cache' => true,
                            'affix' => false,
                        ]),
                        'children' => [
                            [
                                'name' => 'ds:sysCms:category:list',
                                'meta' => new Meta([
                                    'title' => 'List',
                                    'i18n' => 'crud.list',
                                    'type' => 'B',
                                ]),
                            ],
                            [
                                'name' => 'ds:sysCms:category:create',
                                'meta' => new Meta([
                                    'title' => 'Add',
                                    'i18n' => 'crud.add',
                                    'type' => 'B',
                                ]),
                            ],
                            [
                                'name' => 'ds:sysCms:category:save',
                                'meta' => new Meta([
                                    'title' => 'Edit',
                                    'i18n' => 'crud.edit',
                                    'type' => 'B',
                                ]),
                            ],
                            [
                                'name' => 'ds:sysCms:category:delete',
                                'meta' => new Meta([
                                    'title' => 'Delete',
                                    'i18n' => 'crud.delete',
                                    'type' => 'B',
                                ]),
                            ],
                        ],
                    ],
                    [
                        'name' => 'ds:sysCms:placement_position',
                        'path' => '/ds/sysCms/admin/placementPosition',
                        'component' => 'ds/sysCms/views/placementPosition/index',
                        'meta' => new Meta([
                            'title' => '投放位置',
                            'i18n' => 'admin.PlacementPosition',
                            'icon' => 'mdi:menu',
                            'type' => 'M',
                            'hidden' => false,
                            'componentPath' => 'plugins/',
                            'componentSuffix' => '.vue',
                            'breadcrumbEnable' => true,
                            'copyright' => true,
                            'cache' => true,
                            'affix' => false,
                        ]),
                        'children' => [
                            [
                                'name' => 'ds:sysCms:placement_position:list',
                                'meta' => new Meta([
                                    'title' => 'List',
                                    'i18n' => 'crud.list',
                                    'type' => 'B',
                                ]),
                            ],
                            [
                                'name' => 'ds:sysCms:placement_position:create',
                                'meta' => new Meta([
                                    'title' => 'Add',
                                    'i18n' => 'crud.add',
                                    'type' => 'B',
                                ]),
                            ],
                            [
                                'name' => 'ds:sysCms:placement_position:save',
                                'meta' => new Meta([
                                    'title' => 'Edit',
                                    'i18n' => 'crud.edit',
                                    'type' => 'B',
                                ]),
                            ],
                            [
                                'name' => 'ds:sysCms:placement_position:delete',
                                'meta' => new Meta([
                                    'title' => 'Delete',
                                    'i18n' => 'crud.delete',
                                    'type' => 'B',
                                ]),
                            ],
                        ],
                    ],
                    [
                        'name' => 'ds:sysCms:placement_content',
                        'path' => '/ds/sysCms/admin/placementContent',
                        'component' => 'ds/sysCms/views/placementContent/index',
                        'meta' => new Meta([
                            'title' => '投放内容',
                            'i18n' => 'admin.PlacementContent',
                            'icon' => 'mdi:menu',
                            'type' => 'M',
                            'hidden' => false,
                            'componentPath' => 'plugins/',
                            'componentSuffix' => '.vue',
                            'breadcrumbEnable' => true,
                            'copyright' => true,
                            'cache' => true,
                            'affix' => false,
                        ]),
                        'children' => [
                            [
                                'name' => 'ds:sysCms:placement_content:list',
                                'meta' => new Meta([
                                    'title' => 'List',
                                    'i18n' => 'crud.list',
                                    'type' => 'B',
                                ]),
                            ],
                            [
                                'name' => 'ds:sysCms:placement_content:create',
                                'meta' => new Meta([
                                    'title' => 'Add',
                                    'i18n' => 'crud.add',
                                    'type' => 'B',
                                ]),
                            ],
                            [
                                'name' => 'ds:sysCms:placement_content:save',
                                'meta' => new Meta([
                                    'title' => 'Edit',
                                    'i18n' => 'crud.edit',
                                    'type' => 'B',
                                ]),
                            ],
                            [
                                'name' => 'ds:sysCms:placement_content:delete',
                                'meta' => new Meta([
                                    'title' => 'Delete',
                                    'i18n' => 'crud.delete',
                                    'type' => 'B',
                                ]),
                            ],
                        ],
                    ],
                    [
                        'name' => 'ds:sysCms:app_page_content',
                        'path' => '/ds/sysCms/admin/appPageContent',
                        'component' => 'ds/sysCms/views/appPageContent/index',
                        'meta' => new Meta([
                            'title' => 'App页面内容',
                            'i18n' => 'admin.AppPageContent',
                            'icon' => 'mdi:menu',
                            'type' => 'M',
                            'hidden' => false,
                            'componentPath' => 'plugins/',
                            'componentSuffix' => '.vue',
                            'breadcrumbEnable' => true,
                            'copyright' => true,
                            'cache' => true,
                            'affix' => false,
                        ]),
                        'children' => [
                            [
                                'name' => 'ds:sysCms:app_page_content:list',
                                'meta' => new Meta([
                                    'title' => 'List',
                                    'i18n' => 'crud.list',
                                    'type' => 'B',
                                ]),
                            ],
                            [
                                'name' => 'ds:sysCms:app_page_content:create',
                                'meta' => new Meta([
                                    'title' => 'Add',
                                    'i18n' => 'crud.add',
                                    'type' => 'B',
                                ]),
                            ],
                            [
                                'name' => 'ds:sysCms:app_page_content:save',
                                'meta' => new Meta([
                                    'title' => 'Edit',
                                    'i18n' => 'crud.edit',
                                    'type' => 'B',
                                ]),
                            ],
                            [
                                'name' => 'ds:sysCms:app_page_content:delete',
                                'meta' => new Meta([
                                    'title' => 'Delete',
                                    'i18n' => 'crud.delete',
                                    'type' => 'B',
                                ]),
                            ],
                        ],
                    ],
                    [
                        'name' => 'ds:sysCms:app_page_content_sync',
                        'path' => '/ds/sysCms/admin/appPageContentSync',
                        'component' => 'ds/sysCms/views/appPageContentSync/index',
                        'meta' => new Meta([
                            'title' => 'App页面内容同步',
                            'i18n' => 'admin.AppPageContentSync',
                            'icon' => 'mdi:menu',
                            'type' => 'M',
                            'hidden' => false,
                            'componentPath' => 'plugins/',
                            'componentSuffix' => '.vue',
                            'breadcrumbEnable' => true,
                            'copyright' => true,
                            'cache' => true,
                            'affix' => false,
                        ]),
                        'children' => [
                            [
                                'name' => 'ds:sysCms:app_page_content_sync:list',
                                'meta' => new Meta([
                                    'title' => 'List',
                                    'i18n' => 'crud.list',
                                    'type' => 'B',
                                ]),
                            ],
                            [
                                'name' => 'ds:sysCms:app_page_content_sync:generate',
                                'meta' => new Meta([
                                    'title' => 'Generate',
                                    'i18n' => 'admin.AppPageContentSyncFields.generate',
                                    'type' => 'B',
                                ]),
                            ],
                        ],
                    ],
                ]
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
