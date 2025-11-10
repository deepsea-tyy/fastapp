<?php

declare(strict_types=1);

use App\Model\Permission\Menu;
use App\Model\Permission\Meta;
use App\Model\Permission\Role;
use App\Model\User;
use Hyperf\Database\Seeders\Seeder;
use Hyperf\DbConnection\Db;

class Init20251017 extends Seeder
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
        Menu::truncate();
        if (env('DB_DRIVER') === 'odbc-sql-server') {
            Db::unprepared('SET IDENTITY_INSERT [' . Menu::getModel()->getTable() . '] ON;');
        }
        $this->create($this->data());
        if (env('DB_DRIVER') === 'odbc-sql-server') {
            Db::unprepared('SET IDENTITY_INSERT [' . Menu::getModel()->getTable() . '] OFF;');
        }
        User::truncate();
        Role::truncate();
        $entity = User::create([
            'username' => 'admin',
            'email' => '649909457@qq.com',
            'password' => '123456',
            'user_type' => '100',
            'status' => 1,
            'created_at' => date('Y-m-d H:i:s'),
            'updated_at' => date('Y-m-d H:i:s'),
        ]);
        $role = Role::create([
            'name' => '超级管理员',
            'code' => 'SuperAdmin',
        ]);
        $entity->roles()->sync($role);
        Db::table('rules')->insert([
            'v0' => 'admin',
            'v1' => 'superAdmin',
            'ptype' => 'g',
        ]);
    }

    /**
     * Database seeds data.
     */
    public function data(): array
    {
        return [
            [
                'name' => 'permission',
                'path' => '/permission',
                'meta' => new Meta([
                    'title' => '权限管理',
                    'i18n' => 'baseMenu.permission.index',
                    'icon' => 'ri:git-repository-private-line',
                    'type' => 'M',
                    'hidden' => 0,
                    'componentPath' => 'modules/',
                    'componentSuffix' => '.vue',
                    'breadcrumbEnable' => 1,
                    'copyright' => 1,
                    'cache' => 1,
                    'affix' => 0,
                ]),
                'children' => [
                    [
                        'name' => 'permission:department',
                        'path' => '/permission/department',
                        'component' => 'base/views/permission/department/index',
                        'meta' => new Meta([
                            'title' => '部门管理',
                            'i18n' => 'permission.Department',
                            'icon' => 'mdi:menu',
                            'hidden' => 0,
                            'type' => 'M',
                            'componentPath' => 'modules/',
                            'componentSuffix' => '.vue',
                            'breadcrumbEnable' => 1,
                            'copyright' => 1,
                            'cache' => 1,
                            'affix' => 0,
                        ]),
                        'children' => [
                            [
                                'name' => 'permission:department:list',
                                'meta' => new Meta([
                                    'title' => 'List',
                                    'type' => 'B',
                                    'i18n' => 'crud.list',
                                ]),
                            ],
                            [
                                'name' => 'permission:department:create',
                                'meta' => new Meta([
                                    'title' => 'Add',
                                    'type' => 'B',
                                    'i18n' => 'crud.add',
                                ]),
                            ],
                            [
                                'name' => 'permission:department:save',
                                'meta' => new Meta([
                                    'title' => 'Edit',
                                    'type' => 'B',
                                    'i18n' => 'crud.edit',
                                ]),
                            ],
                            [
                                'name' => 'permission:department:delete',
                                'meta' => new Meta([
                                    'title' => 'Delete',
                                    'type' => 'B',
                                    'i18n' => 'crud.delete',
                                ]),
                            ],
                        ],
                    ],
                    [
                        'name' => 'permission:user',
                        'path' => '/permission/user',
                        'component' => 'base/views/permission/user/index',
                        'meta' => new Meta([
                            'type' => 'M',
                            'title' => '用户管理',
                            'i18n' => 'baseMenu.permission.user',
                            'icon' => 'material-symbols:manage-accounts-outline',
                            'hidden' => 0,
                            'componentPath' => 'modules/',
                            'componentSuffix' => '.vue',
                            'breadcrumbEnable' => 1,
                            'copyright' => 1,
                            'cache' => 1,
                            'affix' => 0,
                        ]),
                        'children' => [
                            [
                                'name' => 'permission:user:index',
                                'meta' => new Meta([
                                    'title' => '用户列表',
                                    'type' => 'B',
                                    'i18n' => 'baseMenu.permission.userList',
                                ]),
                            ],
                            [
                                'name' => 'permission:user:save',
                                'meta' => new Meta([
                                    'title' => '用户保存',
                                    'type' => 'B',
                                    'i18n' => 'baseMenu.permission.userSave',
                                ]),
                            ],
                            [
                                'name' => 'permission:user:update',
                                'meta' => new Meta([
                                    'title' => '用户更新',
                                    'type' => 'B',
                                    'i18n' => 'baseMenu.permission.userUpdate',
                                ]),
                            ],
                            [
                                'name' => 'permission:user:delete',
                                'meta' => new Meta([
                                    'title' => '用户删除',
                                    'type' => 'B',
                                    'i18n' => 'baseMenu.permission.userDelete',
                                ]),
                            ],
                            [
                                'name' => 'permission:user:password',
                                'meta' => new Meta([
                                    'title' => '用户初始化密码',
                                    'type' => 'B',
                                    'i18n' => 'baseMenu.permission.userPassword',
                                ]),
                            ],
                            [
                                'name' => 'permission:user:getRole',
                                'meta' => new Meta([
                                    'title' => '获取用户角色',
                                    'type' => 'B',
                                    'i18n' => 'baseMenu.permission.getUserRole',
                                ]),
                            ],
                            [
                                'name' => 'permission:user:setRole',
                                'meta' => new Meta([
                                    'title' => '用户角色赋予',
                                    'type' => 'B',
                                    'i18n' => 'baseMenu.permission.setUserRole',
                                ]),
                            ],
                        ],
                    ],
                    [
                        'name' => 'permission:menu',
                        'path' => '/permission/menu',
                        'component' => 'base/views/permission/menu/index',
                        'meta' => new Meta([
                            'title' => '菜单管理',
                            'i18n' => 'baseMenu.permission.menu',
                            'icon' => 'ph:list-bold',
                            'hidden' => 0,
                            'type' => 'M',
                            'componentPath' => 'modules/',
                            'componentSuffix' => '.vue',
                            'breadcrumbEnable' => 1,
                            'copyright' => 1,
                            'cache' => 1,
                            'affix' => 0,
                        ]),
                        'children' => [
                            [
                                'name' => 'permission:menu:index',
                                'meta' => new Meta([
                                    'title' => '菜单列表',
                                    'type' => 'B',
                                    'i18n' => 'baseMenu.permission.menuList',
                                ]),
                            ],
                            [
                                'name' => 'permission:menu:create',
                                'meta' => new Meta([
                                    'title' => '菜单保存',
                                    'type' => 'B',
                                    'i18n' => 'baseMenu.permission.menuSave',
                                ]),
                            ],
                            [
                                'name' => 'permission:menu:save',
                                'meta' => new Meta([
                                    'title' => '菜单更新',
                                    'type' => 'B',
                                    'i18n' => 'baseMenu.permission.menuUpdate',
                                ]),
                            ],
                            [
                                'name' => 'permission:menu:delete',
                                'meta' => new Meta([
                                    'title' => '菜单删除',
                                    'type' => 'B',
                                    'i18n' => 'baseMenu.permission.menuDelete',
                                ]),
                            ],
                        ],
                    ],
                    [
                        'name' => 'permission:role',
                        'path' => '/permission/role',
                        'component' => 'base/views/permission/role/index',
                        'meta' => new Meta([
                            'title' => '角色管理',
                            'i18n' => 'baseMenu.permission.role',
                            'icon' => 'material-symbols:supervisor-account-outline-rounded',
                            'hidden' => 0,
                            'type' => 'M',
                            'componentPath' => 'modules/',
                            'componentSuffix' => '.vue',
                            'breadcrumbEnable' => 1,
                            'copyright' => 1,
                            'cache' => 1,
                            'affix' => 0,
                        ]),
                        'children' => [
                            [
                                'name' => 'permission:role:index',
                                'meta' => new Meta([
                                    'title' => '角色列表',
                                    'type' => 'B',
                                    'i18n' => 'baseMenu.permission.roleList',
                                ]),
                            ],
                            [
                                'name' => 'permission:role:save',
                                'meta' => new Meta([
                                    'title' => '角色保存',
                                    'type' => 'B',
                                    'i18n' => 'baseMenu.permission.roleSave',
                                ]),
                            ],
                            [
                                'name' => 'permission:role:update',
                                'meta' => new Meta([
                                    'title' => '角色更新',
                                    'type' => 'B',
                                    'i18n' => 'baseMenu.permission.roleUpdate',
                                ]),
                            ],
                            [
                                'name' => 'permission:role:delete',
                                'meta' => new Meta([
                                    'title' => '角色删除',
                                    'type' => 'B',
                                    'i18n' => 'baseMenu.permission.roleDelete',
                                ]),
                            ],
                            [
                                'name' => 'permission:role:getMenu',
                                'meta' => new Meta([
                                    'title' => '获取角色权限',
                                    'type' => 'B',
                                    'i18n' => 'baseMenu.permission.getRolePermission',
                                ]),
                            ],
                            [
                                'name' => 'permission:role:setMenu',
                                'meta' => new Meta([
                                    'title' => '赋予角色权限',
                                    'type' => 'B',
                                    'i18n' => 'baseMenu.permission.setRolePermission',
                                ]),
                            ],
                        ],
                    ],
                ],
            ],
            [
                'name' => 'log',
                'path' => '/log',
                'meta' => new Meta([
                    'title' => '日志管理',
                    'i18n' => 'baseMenu.log.index',
                    'icon' => 'ph:instagram-logo',
                    'type' => 'M',
                    'hidden' => 0,
                    'componentPath' => 'modules/',
                    'componentSuffix' => '.vue',
                    'breadcrumbEnable' => 1,
                    'copyright' => 1,
                    'cache' => 1,
                    'affix' => 0,
                ]),
                'children' => [
                    [
                        'name' => 'log:userLogin',
                        'path' => '/log/userLoginLog',
                        'component' => 'base/views/log/userLogin',
                        'meta' => new Meta([
                            'title' => '用户登录日志管理',
                            'type' => 'M',
                            'hidden' => 0,
                            'icon' => 'ph:user-list',
                            'i18n' => 'baseMenu.log.userLoginLog',
                            'componentPath' => 'modules/',
                            'componentSuffix' => '.vue',
                            'breadcrumbEnable' => 1,
                            'copyright' => 1,
                            'cache' => 1,
                            'affix' => 0,
                        ]),
                        'children' => [
                            [
                                'name' => 'log:userLogin:list',
                                'path' => '/log/userLoginLog',
                                'meta' => new Meta([
                                    'title' => '用户登录日志列表',
                                    'i18n' => 'baseMenu.log.userLoginLogList',
                                    'type' => 'B',
                                ]),
                            ],
                            [
                                'name' => 'log:userLogin:delete',
                                'meta' => new Meta([
                                    'title' => '删除用户登录日志',
                                    'i18n' => 'baseMenu.log.userLoginLogDelete',
                                    'type' => 'B',
                                ]),
                            ],
                        ],
                    ],
                    [
                        'name' => 'log:userOperation',
                        'path' => '/log/operationLog',
                        'component' => 'base/views/log/userOperation',
                        'meta' => new Meta([
                            'title' => '操作日志管理',
                            'type' => 'M',
                            'hidden' => 0,
                            'icon' => 'ph:list-magnifying-glass',
                            'i18n' => 'baseMenu.log.operationLog',
                            'componentPath' => 'modules/',
                            'componentSuffix' => '.vue',
                            'breadcrumbEnable' => 1,
                            'copyright' => 1,
                            'cache' => 1,
                            'affix' => 0,
                        ]),
                        'children' => [
                            [
                                'name' => 'log:userOperation:list',
                                'meta' => new Meta([
                                    'title' => '用户操作日志列表',
                                    'i18n' => 'baseMenu.log.userOperationLog',
                                    'type' => 'B',
                                ]),
                            ],
                            [
                                'name' => 'log:userOperation:delete',
                                'meta' => new Meta([
                                    'title' => '删除用户操作日志',
                                    'i18n' => 'baseMenu.log.userOperationLogDelete',
                                    'type' => 'B',
                                ]),
                            ],
                        ],
                    ],
                ],
            ],
            [
                'name' => 'dataCenter',
                'path' => '/dataCenter',
                'meta' => new Meta([
                    'title' => '数据中心',
                    'i18n' => 'baseMenu.dataCenter.index',
                    'icon' => 'ri:database-line',
                    'type' => 'M',
                    'hidden' => 0,
                    'componentPath' => 'modules/',
                    'componentSuffix' => '.vue',
                    'breadcrumbEnable' => 1,
                    'copyright' => 1,
                    'cache' => 1,
                    'affix' => 0,
                ]),
                'children' => [
                    [
                        'name' => 'dataCenter:attachment',
                        'path' => '/dataCenter/attachment',
                        'component' => 'base/views/dataCenter/attachment/index',
                        'meta' => new Meta([
                            'title' => '附件管理',
                            'type' => 'M',
                            'hidden' => 0,
                            'icon' => 'ri:attachment-line',
                            'i18n' => 'baseMenu.dataCenter.attachment',
                            'componentPath' => 'modules/',
                            'componentSuffix' => '.vue',
                            'breadcrumbEnable' => 1,
                            'copyright' => 1,
                            'cache' => 1,
                            'affix' => 0,
                        ]),
                        'children' => [
                            [
                                'name' => 'dataCenter:attachment:list',
                                'meta' => new Meta([
                                    'title' => '附件列表',
                                    'i18n' => 'baseMenu.dataCenter.attachmentList',
                                    'type' => 'B',
                                ]),
                            ],
                            [
                                'name' => 'dataCenter:attachment:upload',
                                'meta' => new Meta([
                                    'title' => '上传附件',
                                    'i18n' => 'baseMenu.dataCenter.attachmentUpload',
                                    'type' => 'B',
                                ]),
                            ],
                            [
                                'name' => 'dataCenter:attachment:delete',
                                'meta' => new Meta([
                                    'title' => '删除附件',
                                    'i18n' => 'baseMenu.dataCenter.attachmentDelete',
                                    'type' => 'B',
                                ]),
                            ],
                        ],
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
