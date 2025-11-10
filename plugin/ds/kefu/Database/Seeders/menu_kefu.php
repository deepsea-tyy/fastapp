<?php

declare(strict_types=1);

use App\Model\Permission\Menu;
use App\Model\Permission\Meta;
use Hyperf\Database\Seeders\Seeder;
use Hyperf\DbConnection\Db;

class MenuKefu extends Seeder
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
                'name' => 'kefu',
                'path' => '/kefu',
                'sort' => 6,
                'meta' => new Meta([
                    'title' => '客服管理',
                    'i18n' => 'kefu.KefuManager',
                    'icon' => 'ant-design:container-outlined',
                    'type' => 'M',
                    'hidden' => false,
                ]),
                'children' => [
                    [
                        'name' => 'kefu:chat',
                        'path' => '/kefu/chat',
                        'component' => 'ds/kefu/views/chat/index',
                        'sort' => 1,
                        'meta' => new Meta([
                            'title' => '客服窗口',
                            'i18n' => 'kefu.KefuChat',
                            'icon' => 'ep:chat-dot-square',
                            'type' => 'M',
                            'hidden' => false,
                            'componentPath' => 'modules/',
                            'componentSuffix' => '.vue',
                            'breadcrumbEnable' => true,
                            'copyright' => true,
                            'cache' => true,
                            'affix' => false,
                        ]),
                    ],
                    [
                        'name' => 'kefu:kefu',
                        'path' => '/kefu/kefu',
                        'component' => 'ds/kefu/views/kefu/index',
                        'sort' => 3,
                        'meta' => new Meta([
                            'title' => '客服列表',
                            'i18n' => 'kefu.Kefu',
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
                                'name' => 'kefu:kefu:index',
                                'meta' => new Meta([
                                    'title' => '列表',
                                    'type' => 'B',
                                    'i18n' => '',
                                ]),
                            ],
                            [
                                'name' => 'kefu:kefu:save',
                                'meta' => new Meta([
                                    'title' => '添加',
                                    'type' => 'B',
                                    'i18n' => '',
                                ]),
                            ],
                            [
                                'name' => 'kefu:kefu:update',
                                'meta' => new Meta([
                                    'title' => '修改',
                                    'type' => 'B',
                                    'i18n' => '',
                                ]),
                            ],
                            [
                                'name' => 'kefu:kefu:delete',
                                'meta' => new Meta([
                                    'title' => '删除',
                                    'type' => 'B',
                                    'i18n' => '',
                                ]),
                            ],
                        ],
                    ],
                    [
                        'name' => 'kefu:kefuConversation',
                        'path' => '/kefu/kefuConversation',
                        'component' => 'ds/kefu/views/kefuConversation/index',
                        'sort' => 3,
                        'meta' => new Meta([
                            'title' => '会话列表',
                            'i18n' => 'kefu.KefuConversation',
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
                                'name' => 'kefu:kefuConversation:index',
                                'meta' => new Meta([
                                    'title' => '列表',
                                    'type' => 'B',
                                    'i18n' => '',
                                ]),
                            ],
                            [
                                'name' => 'kefu:kefuConversation:delete',
                                'meta' => new Meta([
                                    'title' => '删除',
                                    'type' => 'B',
                                    'i18n' => '',
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
