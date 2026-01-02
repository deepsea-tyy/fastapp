<?php
/**
 * FastApp.
 * 12/6/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

declare(strict_types=1);

use App\Model\Permission\Menu;
use App\Model\Permission\Meta;
use Hyperf\Database\Seeders\Seeder;
use Hyperf\DbConnection\Db;

class MenuEx extends Seeder
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
                'name' => 'ds:ex',
                'path' => '/ds/ex',
                'component' => '',
                'sort' => 50,
                'meta' => new Meta([
                    'title' => '交易所',
                    'i18n' => '',
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
                        'name' => 'ds:ex:base',
                        'path' => '/ds/ex/base',
                        'component' => '',
                        'sort' => 50,
                        'meta' => new Meta([
                            'title' => '基础数据管理',
                            'i18n' => '',
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
                                'name' => 'ds:ex:currency',
                                'path' => '/ds/ex/admin/currency',
                                'component' => 'ds/ex/views/currency/index',
                                'sort' => 1,
                                'meta' => new Meta([
                                    'title' => '币种信息',
                                    'i18n' => 'admin.Currency',
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
                                        'name' => 'ds:ex:currency:list',
                                        'meta' => new Meta([
                                            'title' => '列表',
                                            'type' => 'B',
                                            'i18n' => 'crud.list',
                                        ]),
                                    ],
                                    [
                                        'name' => 'ds:ex:currency:create',
                                        'meta' => new Meta([
                                            'title' => '添加',
                                            'type' => 'B',
                                            'i18n' => 'crud.add',
                                        ]),
                                    ],
                                    [
                                        'name' => 'ds:ex:currency:save',
                                        'meta' => new Meta([
                                            'title' => '修改',
                                            'type' => 'B',
                                            'i18n' => 'crud.edit',
                                        ]),
                                    ],
                                    [
                                        'name' => 'ds:ex:currency:delete',
                                        'meta' => new Meta([
                                            'title' => '删除',
                                            'type' => 'B',
                                            'i18n' => 'crud.delete',
                                        ]),
                                    ],
                                ],
                            ],
                            [
                                'name' => 'ds:ex:market_pair',
                                'path' => '/ds/ex/admin/marketPair',
                                'component' => 'ds/ex/views/marketPair/index',
                                'sort' => 2,
                                'meta' => new Meta([
                                    'title' => '交易对数据',
                                    'i18n' => 'admin.MarketPair',
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
                                        'name' => 'ds:ex:market_pair:list',
                                        'meta' => new Meta([
                                            'title' => '列表',
                                            'type' => 'B',
                                            'i18n' => 'crud.list',
                                        ]),
                                    ],
                                    [
                                        'name' => 'ds:ex:market_pair:create',
                                        'meta' => new Meta([
                                            'title' => '添加',
                                            'type' => 'B',
                                            'i18n' => 'crud.add',
                                        ]),
                                    ],
                                    [
                                        'name' => 'ds:ex:market_pair:save',
                                        'meta' => new Meta([
                                            'title' => '修改',
                                            'type' => 'B',
                                            'i18n' => 'crud.edit',
                                        ]),
                                    ],
                                    [
                                        'name' => 'ds:ex:market_pair:delete',
                                        'meta' => new Meta([
                                            'title' => '删除',
                                            'type' => 'B',
                                            'i18n' => 'crud.delete',
                                        ]),
                                    ],
                                ],
                            ],
                            [
                                'name' => 'ds:ex:ex_vip',
                                'path' => '/ds/ex/admin/exVip',
                                'component' => 'ds/ex/views/exVip/index',
                                'sort' => 4,
                                'meta' => new Meta([
                                    'title' => 'VIP等级配置',
                                    'i18n' => 'admin.ExVip',
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
                                        'name' => 'ds:ex:ex_vip:list',
                                        'meta' => new Meta([
                                            'title' => '列表',
                                            'type' => 'B',
                                            'i18n' => 'crud.list',
                                        ]),
                                    ],
                                    [
                                        'name' => 'ds:ex:ex_vip:create',
                                        'meta' => new Meta([
                                            'title' => '添加',
                                            'type' => 'B',
                                            'i18n' => 'crud.add',
                                        ]),
                                    ],
                                    [
                                        'name' => 'ds:ex:ex_vip:save',
                                        'meta' => new Meta([
                                            'title' => '修改',
                                            'type' => 'B',
                                            'i18n' => 'crud.edit',
                                        ]),
                                    ],
                                    [
                                        'name' => 'ds:ex:ex_vip:delete',
                                        'meta' => new Meta([
                                            'title' => '删除',
                                            'type' => 'B',
                                            'i18n' => 'crud.delete',
                                        ]),
                                    ],
                                ],
                            ],
                        ]
                    ],
                    [
                        'name' => 'ds:ex:user',
                        'path' => '',
                        'component' => '',
                        'sort' => 50,
                        'meta' => new Meta([
                            'title' => '用户管理',
                            'i18n' => '',
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
                                'name' => 'ds:ex:account',
                                'path' => '/ds/ex/admin/account',
                                'component' => 'ds/ex/views/user/index',
                                'meta' => new Meta([
                                    'title' => '用户列表',
                                    'i18n' => 'admin.User',
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
                                        'name' => 'ds:ex:user:list',
                                        'meta' => new Meta([
                                            'title' => 'List',
                                            'type' => 'B',
                                            'i18n' => 'crud.list',
                                        ]),
                                    ],
                                    [
                                        'name' => 'ds:ex:user:create',
                                        'meta' => new Meta([
                                            'title' => 'Add',
                                            'type' => 'B',
                                            'i18n' => 'crud.add',
                                        ]),
                                    ],
                                    [
                                        'name' => 'ds:ex:user:save',
                                        'meta' => new Meta([
                                            'title' => 'Edit',
                                            'type' => 'B',
                                            'i18n' => 'crud.edit',
                                        ]),
                                    ],
                                    [
                                        'name' => 'ds:ex:user:delete',
                                        'meta' => new Meta([
                                            'title' => 'Delete',
                                            'type' => 'B',
                                            'i18n' => 'crud.delete',
                                        ]),
                                    ],
                                ],
                            ],
                            [
                                'name' => 'ds:ex:ex_kyc',
                                'path' => '/ds/ex/admin/exKyc',
                                'component' => 'ds/ex/views/exKyc/index',
                                'sort' => 3,
                                'meta' => new Meta([
                                    'title' => 'KYC认证申请',
                                    'i18n' => 'admin.ExKyc',
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
                                        'name' => 'ds:ex:ex_kyc:list',
                                        'meta' => new Meta([
                                            'title' => '列表',
                                            'type' => 'B',
                                            'i18n' => 'crud.list',
                                        ]),
                                    ],
                                    [
                                        'name' => 'ds:ex:ex_kyc:create',
                                        'meta' => new Meta([
                                            'title' => '添加',
                                            'type' => 'B',
                                            'i18n' => 'crud.add',
                                        ]),
                                    ],
                                    [
                                        'name' => 'ds:ex:ex_kyc:save',
                                        'meta' => new Meta([
                                            'title' => '修改',
                                            'type' => 'B',
                                            'i18n' => 'crud.edit',
                                        ]),
                                    ],
                                    [
                                        'name' => 'ds:ex:ex_kyc:delete',
                                        'meta' => new Meta([
                                            'title' => '删除',
                                            'type' => 'B',
                                            'i18n' => 'crud.delete',
                                        ]),
                                    ],
                                ],
                            ],
                            [
                                'name' => 'ds:ex:websocket',
                                'path' => '/ds/ex/admin/websocket',
                                'component' => 'ds/ex/views/ws/index',
                                'sort' => 5,
                                'meta' => new Meta([
                                    'title' => 'WebSocket连接管理',
                                    'i18n' => 'admin.websocket.mainTitle',
                                    'icon' => 'mdi:wifi',
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
                                        'name' => 'ds:ex:websocket:list',
                                        'meta' => new Meta([
                                            'title' => '列表',
                                            'type' => 'B',
                                            'i18n' => 'crud.list',
                                        ]),
                                    ],
                                    [
                                        'name' => 'ds:ex:websocket:info',
                                        'meta' => new Meta([
                                            'title' => '查看',
                                            'type' => 'B',
                                            'i18n' => 'crud.view',
                                        ]),
                                    ],
                                    [
                                        'name' => 'ds:ex:websocket:close',
                                        'meta' => new Meta([
                                            'title' => '关闭连接',
                                            'type' => 'B',
                                            'i18n' => 'admin.websocket.closeConnection',
                                        ]),
                                    ],
                                    [
                                        'name' => 'ds:ex:websocket:send',
                                        'meta' => new Meta([
                                            'title' => '发送消息',
                                            'type' => 'B',
                                            'i18n' => 'admin.websocket.sendMessage',
                                        ]),
                                    ],
                                ],
                            ],
                        ]
                    ]
                ]
            ],
        ];
    }

    public function create(array $data, int $parent_id = 0): void
    {
        foreach ($data as $menuItem) {
            // 分离子菜单数据
            $children = $menuItem['children'] ?? null;
            unset($menuItem['children']);

            // 准备菜单数据
            $menuData = array_merge(self::BASE_DATA, $menuItem, ['parent_id' => $parent_id]);

            // 查找或创建菜单
            $menu = $this->findOrCreateMenu($menuData);

            // 递归处理子菜单
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

        // 如果没有 name，直接创建
        if (!$menuName) {
            return Menu::create($menuData);
        }

        // 查找已存在的菜单
        $menu = Menu::query()
            ->where('name', $menuName)
            ->where('parent_id', $parentId)
            ->first();

        if ($menu) {
            // 更新现有菜单
            $updateData = $menuData;
            unset($updateData['created_by']); // 保留原有的创建者
            $menu->update($updateData);
            return $menu;
        }

        // 创建新菜单
        return Menu::create($menuData);
    }
}
