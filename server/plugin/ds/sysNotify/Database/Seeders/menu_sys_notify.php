<?php

declare(strict_types=1);

use App\Model\Permission\Menu;
use App\Model\Permission\Meta;
use Hyperf\Database\Seeders\Seeder;
use Hyperf\DbConnection\Db;

class MenuSysNotify extends Seeder
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
                'name' => 'ds:sysNotify',
                'path' => '/ds/sysNotify/admin/messageNotify',
                'component' => 'ds/sysNotify/views/messageNotify/index',
                'meta' => new Meta([
                    'title' => '消息通知',
                    'i18n' => 'admin.MessageNotify',
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
                        'name' => 'ds:sysNotify:message_notify:list',
                        'meta' => new Meta([
                            'title' => 'List',
                            'type' => 'B',
                            'i18n' => 'crud.list',
                        ]),
                    ],
                    [
                        'name' => 'ds:sysNotify:message_notify:create',
                        'meta' => new Meta([
                            'title' => 'Add',
                            'type' => 'B',
                            'i18n' => 'crud.add',
                        ]),
                    ],
                    [
                        'name' => 'ds:sysNotify:message_notify:save',
                        'meta' => new Meta([
                            'title' => 'Edit',
                            'type' => 'B',
                            'i18n' => 'crud.edit',
                        ]),
                    ],
                    [
                        'name' => 'ds:sysNotify:message_notify:delete',
                        'meta' => new Meta([
                            'title' => 'Delete',
                            'type' => 'B',
                            'i18n' => 'crud.delete',
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
