<?php

declare(strict_types=1);

use App\Model\Permission\Menu;
use App\Model\Permission\Meta;
use Hyperf\Database\Seeders\Seeder;
use Hyperf\DbConnection\Db;

class MenuSysKefu extends Seeder
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
                'name' => 'ds:sysKefu',
                'path' => '/sysKefu',
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
                        'name' => 'ds:sysKefu:chat',
                        'path' => '/sysKefu/chat',
                        'component' => 'ds/sysKefu/views/chat/index',
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
                        'name' => 'ds:sysKefu:kefu',
                        'path' => '/sysKefu/kefu',
                        'component' => 'ds/sysKefu/views/kefu/index',
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
                                'name' => 'ds:sysKefu:kefu:index',
                                'meta' => new Meta([
                                    'title' => '列表',
                                    'type' => 'B',
                                    'i18n' => '',
                                ]),
                            ],
                            [
                                'name' => 'ds:sysKefu:kefu:save',
                                'meta' => new Meta([
                                    'title' => '添加',
                                    'type' => 'B',
                                    'i18n' => '',
                                ]),
                            ],
                            [
                                'name' => 'ds:sysKefu:kefu:update',
                                'meta' => new Meta([
                                    'title' => '修改',
                                    'type' => 'B',
                                    'i18n' => '',
                                ]),
                            ],
                            [
                                'name' => 'ds:sysKefu:kefu:delete',
                                'meta' => new Meta([
                                    'title' => '删除',
                                    'type' => 'B',
                                    'i18n' => '',
                                ]),
                            ],
                        ],
                    ],
                    [
                        'name' => 'ds:sysKefu:kefuConversation',
                        'path' => '/sysKefu/kefuConversation',
                        'component' => 'ds/sysKefu/views/kefuConversation/index',
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
                                'name' => 'ds:sysKefu:kefuConversation:index',
                                'meta' => new Meta([
                                    'title' => '列表',
                                    'type' => 'B',
                                    'i18n' => '',
                                ]),
                            ],
                            [
                                'name' => 'ds:sysKefu:kefuConversation:delete',
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
