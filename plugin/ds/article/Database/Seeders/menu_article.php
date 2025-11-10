<?php

declare(strict_types=1);

use App\Model\Permission\Menu;
use App\Model\Permission\Meta;
use Hyperf\Database\Seeders\Seeder;
use Hyperf\DbConnection\Db;

class MenuArticle extends Seeder
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
                'name' => 'ds:article',
                'path' => '/ds/article',
                'meta' => new Meta([
                    'title' => '文章管理',
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
                        'name' => 'ds:article:article',
                        'path' => '/article/article',
                        'component' => 'ds/article/views/article/index',
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
                                'name' => 'ds:article:article:list',
                                'meta' => new Meta([
                                    'title' => 'List',
                                    'i18n' => 'crud.list',
                                    'type' => 'B',
                                ]),
                            ],
                            [
                                'name' => 'ds:article:article:create',
                                'meta' => new Meta([
                                    'title' => 'Add',
                                    'i18n' => 'crud.add',
                                    'type' => 'B',
                                ]),
                            ],
                            [
                                'name' => 'ds:article:article:save',
                                'meta' => new Meta([
                                    'title' => 'Edit',
                                    'i18n' => 'crud.edit',
                                    'type' => 'B',
                                ]),
                            ],
                            [
                                'name' => 'ds:article:article:delete',
                                'meta' => new Meta([
                                    'title' => 'Delete',
                                    'i18n' => 'crud.delete',
                                    'type' => 'B',
                                ]),
                            ],
                        ],
                    ],
                    [
                        'name' => 'ds:article:category',
                        'path' => '/article/category',
                        'component' => 'ds/article/views/category/index',
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
                                'name' => 'ds:article:category:list',
                                'meta' => new Meta([
                                    'title' => 'List',
                                    'i18n' => 'crud.list',
                                    'type' => 'B',
                                ]),
                            ],
                            [
                                'name' => 'ds:article:category:create',
                                'meta' => new Meta([
                                    'title' => 'Add',
                                    'i18n' => 'crud.add',
                                    'type' => 'B',
                                ]),
                            ],
                            [
                                'name' => 'ds:article:category:save',
                                'meta' => new Meta([
                                    'title' => 'Edit',
                                    'i18n' => 'crud.edit',
                                    'type' => 'B',
                                ]),
                            ],
                            [
                                'name' => 'ds:article:category:delete',
                                'meta' => new Meta([
                                    'title' => 'Delete',
                                    'i18n' => 'crud.delete',
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
        foreach ($data as $v) {
            $_v = $v;
            if (isset($v['children'])) {
                unset($_v['children']);
            }
            $_v['parent_id'] = $parent_id;
            $menu = Menu::create(array_merge(self::BASE_DATA, $_v));
            if (isset($v['children']) && count($v['children'])) {
                $this->create($v['children'], $menu->id);
            }
        }
    }
}
