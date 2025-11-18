<?php

declare(strict_types=1);

use App\Model\Permission\Menu;
use App\Model\Permission\Meta;
use Hyperf\Database\Seeders\Seeder;
use Hyperf\DbConnection\Db;

class MenuMessageNotify extends Seeder
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
                'name' => 'ds:message-notify',
                'path' => '/ds/message-notify/admin/messageNotify',
                'component' => 'ds/message-notify/views/messageNotify/index',
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
                        'name' => 'ds:message-notify:message_notify:list',
                        'meta' => new Meta([
                            'title' => 'List',
                            'type' => 'B',
                            'i18n' => 'crud.list',
                        ]),
                    ],
                    [
                        'name' => 'ds:message-notify:message_notify:create',
                        'meta' => new Meta([
                            'title' => 'Add',
                            'type' => 'B',
                            'i18n' => 'crud.add',
                        ]),
                    ],
                    [
                        'name' => 'ds:message-notify:message_notify:save',
                        'meta' => new Meta([
                            'title' => 'Edit',
                            'type' => 'B',
                            'i18n' => 'crud.edit',
                        ]),
                    ],
                    [
                        'name' => 'ds:message-notify:message_notify:delete',
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
