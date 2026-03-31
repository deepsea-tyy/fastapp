-- 核心菜单种子；维护请直接改本文件
-- 执行：migrate seed internal/store/database

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT 0, 'permission', '/permission', '', '', 1, 99, CAST('{
      "title": "权限管理",
      "i18n": "baseMenu.permission.index",
      "icon": "ri:git-repository-private-line",
      "type": "M",
      "hidden": 0,
      "componentPath": "modules\/",
      "componentSuffix": ".vue",
      "breadcrumbEnable": 1,
      "copyright": 1,
      "cache": 1,
      "affix": 0
    }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'permission' LIMIT 1), 'permission:department', '/permission/department', 'base/views/permission/department/index', '', 1, 0, CAST('{
          "title": "部门管理",
          "i18n": "permission.Department",
          "icon": "mdi:menu",
          "hidden": 0,
          "type": "M",
          "componentPath": "modules\/",
          "componentSuffix": ".vue",
          "breadcrumbEnable": 1,
          "copyright": 1,
          "cache": 1,
          "affix": 0
        }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'permission:department' LIMIT 1), 'permission:department:list', '', '', '', 1, 0, CAST('{
              "title": "List",
              "type": "B",
              "i18n": "crud.list"
            }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'permission:department' LIMIT 1), 'permission:department:create', '', '', '', 1, 0, CAST('{
              "title": "Add",
              "type": "B",
              "i18n": "crud.add"
            }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'permission:department' LIMIT 1), 'permission:department:save', '', '', '', 1, 0, CAST('{
              "title": "Edit",
              "type": "B",
              "i18n": "crud.edit"
            }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'permission:department' LIMIT 1), 'permission:department:delete', '', '', '', 1, 0, CAST('{
              "title": "Delete",
              "type": "B",
              "i18n": "crud.delete"
            }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'permission' LIMIT 1), 'permission:user', '/permission/user', 'base/views/permission/user/index', '', 1, 0, CAST('{
          "type": "M",
          "title": "用户管理",
          "i18n": "baseMenu.permission.user",
          "icon": "material-symbols:manage-accounts-outline",
          "hidden": 0,
          "componentPath": "modules\/",
          "componentSuffix": ".vue",
          "breadcrumbEnable": 1,
          "copyright": 1,
          "cache": 1,
          "affix": 0
        }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'permission:user' LIMIT 1), 'permission:user:index', '', '', '', 1, 0, CAST('{
              "title": "用户列表",
              "type": "B",
              "i18n": "baseMenu.permission.userList"
            }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'permission:user' LIMIT 1), 'permission:user:save', '', '', '', 1, 0, CAST('{
              "title": "用户保存",
              "type": "B",
              "i18n": "baseMenu.permission.userSave"
            }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'permission:user' LIMIT 1), 'permission:user:update', '', '', '', 1, 0, CAST('{
              "title": "用户更新",
              "type": "B",
              "i18n": "baseMenu.permission.userUpdate"
            }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'permission:user' LIMIT 1), 'permission:user:delete', '', '', '', 1, 0, CAST('{
              "title": "用户删除",
              "type": "B",
              "i18n": "baseMenu.permission.userDelete"
            }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'permission:user' LIMIT 1), 'permission:user:password', '', '', '', 1, 0, CAST('{
              "title": "用户初始化密码",
              "type": "B",
              "i18n": "baseMenu.permission.userPassword"
            }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'permission:user' LIMIT 1), 'permission:user:getRole', '', '', '', 1, 0, CAST('{
              "title": "获取用户角色",
              "type": "B",
              "i18n": "baseMenu.permission.getUserRole"
            }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'permission:user' LIMIT 1), 'permission:user:setRole', '', '', '', 1, 0, CAST('{
              "title": "用户角色赋予",
              "type": "B",
              "i18n": "baseMenu.permission.setUserRole"
            }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'permission' LIMIT 1), 'permission:menu', '/permission/menu', 'base/views/permission/menu/index', '', 1, 0, CAST('{
          "title": "菜单管理",
          "i18n": "baseMenu.permission.menu",
          "icon": "ph:list-bold",
          "hidden": 0,
          "type": "M",
          "componentPath": "modules\/",
          "componentSuffix": ".vue",
          "breadcrumbEnable": 1,
          "copyright": 1,
          "cache": 1,
          "affix": 0
        }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'permission:menu' LIMIT 1), 'permission:menu:index', '', '', '', 1, 0, CAST('{
              "title": "菜单列表",
              "type": "B",
              "i18n": "baseMenu.permission.menuList"
            }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'permission:menu' LIMIT 1), 'permission:menu:create', '', '', '', 1, 0, CAST('{
              "title": "菜单保存",
              "type": "B",
              "i18n": "baseMenu.permission.menuSave"
            }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'permission:menu' LIMIT 1), 'permission:menu:save', '', '', '', 1, 0, CAST('{
              "title": "菜单更新",
              "type": "B",
              "i18n": "baseMenu.permission.menuUpdate"
            }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'permission:menu' LIMIT 1), 'permission:menu:delete', '', '', '', 1, 0, CAST('{
              "title": "菜单删除",
              "type": "B",
              "i18n": "baseMenu.permission.menuDelete"
            }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'permission' LIMIT 1), 'permission:role', '/permission/role', 'base/views/permission/role/index', '', 1, 0, CAST('{
          "title": "角色管理",
          "i18n": "baseMenu.permission.role",
          "icon": "material-symbols:supervisor-account-outline-rounded",
          "hidden": 0,
          "type": "M",
          "componentPath": "modules\/",
          "componentSuffix": ".vue",
          "breadcrumbEnable": 1,
          "copyright": 1,
          "cache": 1,
          "affix": 0
        }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'permission:role' LIMIT 1), 'permission:role:index', '', '', '', 1, 0, CAST('{
              "title": "角色列表",
              "type": "B",
              "i18n": "baseMenu.permission.roleList"
            }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'permission:role' LIMIT 1), 'permission:role:save', '', '', '', 1, 0, CAST('{
              "title": "角色保存",
              "type": "B",
              "i18n": "baseMenu.permission.roleSave"
            }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'permission:role' LIMIT 1), 'permission:role:update', '', '', '', 1, 0, CAST('{
              "title": "角色更新",
              "type": "B",
              "i18n": "baseMenu.permission.roleUpdate"
            }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'permission:role' LIMIT 1), 'permission:role:delete', '', '', '', 1, 0, CAST('{
              "title": "角色删除",
              "type": "B",
              "i18n": "baseMenu.permission.roleDelete"
            }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'permission:role' LIMIT 1), 'permission:role:getMenu', '', '', '', 1, 0, CAST('{
              "title": "获取角色权限",
              "type": "B",
              "i18n": "baseMenu.permission.getRolePermission"
            }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'permission:role' LIMIT 1), 'permission:role:setMenu', '', '', '', 1, 0, CAST('{
              "title": "赋予角色权限",
              "type": "B",
              "i18n": "baseMenu.permission.setRolePermission"
            }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT 0, 'log', '/log', '', '', 1, 100, CAST('{
      "title": "日志管理",
      "i18n": "baseMenu.log.index",
      "icon": "ph:instagram-logo",
      "type": "M",
      "hidden": 0,
      "componentPath": "modules\/",
      "componentSuffix": ".vue",
      "breadcrumbEnable": 1,
      "copyright": 1,
      "cache": 1,
      "affix": 0
    }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'log' LIMIT 1), 'log:userLogin', '/log/userLoginLog', 'base/views/log/userLogin', '', 1, 0, CAST('{
          "title": "用户登录日志管理",
          "type": "M",
          "hidden": 0,
          "icon": "ph:user-list",
          "i18n": "baseMenu.log.userLoginLog",
          "componentPath": "modules\/",
          "componentSuffix": ".vue",
          "breadcrumbEnable": 1,
          "copyright": 1,
          "cache": 1,
          "affix": 0
        }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'log:userLogin' LIMIT 1), 'log:userLogin:list', '/log/userLoginLog', '', '', 1, 0, CAST('{
              "title": "用户登录日志列表",
              "i18n": "baseMenu.log.userLoginLogList",
              "type": "B"
            }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'log:userLogin' LIMIT 1), 'log:userLogin:delete', '', '', '', 1, 0, CAST('{
              "title": "删除用户登录日志",
              "i18n": "baseMenu.log.userLoginLogDelete",
              "type": "B"
            }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'log' LIMIT 1), 'log:userOperation', '/log/operationLog', 'base/views/log/userOperation', '', 1, 0, CAST('{
          "title": "操作日志管理",
          "type": "M",
          "hidden": 0,
          "icon": "ph:list-magnifying-glass",
          "i18n": "baseMenu.log.operationLog",
          "componentPath": "modules\/",
          "componentSuffix": ".vue",
          "breadcrumbEnable": 1,
          "copyright": 1,
          "cache": 1,
          "affix": 0
        }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'log:userOperation' LIMIT 1), 'log:userOperation:list', '', '', '', 1, 0, CAST('{
              "title": "用户操作日志列表",
              "i18n": "baseMenu.log.userOperationLog",
              "type": "B"
            }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'log:userOperation' LIMIT 1), 'log:userOperation:delete', '', '', '', 1, 0, CAST('{
              "title": "删除用户操作日志",
              "i18n": "baseMenu.log.userOperationLogDelete",
              "type": "B"
            }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT 0, 'dataCenter', '/dataCenter', '', '', 1, 101, CAST('{
      "title": "数据中心",
      "i18n": "baseMenu.dataCenter.index",
      "icon": "ri:database-line",
      "type": "M",
      "hidden": 0,
      "componentPath": "modules\/",
      "componentSuffix": ".vue",
      "breadcrumbEnable": 1,
      "copyright": 1,
      "cache": 1,
      "affix": 0
    }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'dataCenter' LIMIT 1), 'dataCenter:attachment', '/dataCenter/attachment', 'base/views/dataCenter/attachment/index', '', 1, 0, CAST('{
          "title": "附件管理",
          "type": "M",
          "hidden": 0,
          "icon": "ri:attachment-line",
          "i18n": "baseMenu.dataCenter.attachment",
          "componentPath": "modules\/",
          "componentSuffix": ".vue",
          "breadcrumbEnable": 1,
          "copyright": 1,
          "cache": 1,
          "affix": 0
        }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'dataCenter:attachment' LIMIT 1), 'dataCenter:attachment:list', '', '', '', 1, 0, CAST('{
              "title": "附件列表",
              "i18n": "baseMenu.dataCenter.attachmentList",
              "type": "B"
            }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'dataCenter:attachment' LIMIT 1), 'dataCenter:attachment:upload', '', '', '', 1, 0, CAST('{
              "title": "上传附件",
              "i18n": "baseMenu.dataCenter.attachmentUpload",
              "type": "B"
            }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'dataCenter:attachment' LIMIT 1), 'dataCenter:attachment:delete', '', '', '', 1, 0, CAST('{
              "title": "删除附件",
              "i18n": "baseMenu.dataCenter.attachmentDelete",
              "type": "B"
            }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT 0, 'search:keyword', '/search/keyword', 'search/views/keyword/index', '', 1, 102, CAST('{
      "title": "搜索关键词记录",
      "i18n": "search.Keyword",
      "icon": "mdi:menu",
      "type": "M",
      "hidden": 0,
      "componentPath": "modules\/",
      "componentSuffix": ".vue",
      "breadcrumbEnable": 1,
      "copyright": 1,
      "cache": 1,
      "affix": 0
    }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'search:keyword' LIMIT 1), 'search:keyword:list', '', '', '', 1, 0, CAST('{
          "title": "List",
          "type": "B",
          "i18n": "crud.list"
        }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'search:keyword' LIMIT 1), 'search:keyword:create', '', '', '', 1, 0, CAST('{
          "title": "Add",
          "type": "B",
          "i18n": "crud.add"
        }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'search:keyword' LIMIT 1), 'search:keyword:save', '', '', '', 1, 0, CAST('{
          "title": "Edit",
          "type": "B",
          "i18n": "crud.edit"
        }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'search:keyword' LIMIT 1), 'search:keyword:delete', '', '', '', 1, 0, CAST('{
          "title": "Delete",
          "type": "B",
          "i18n": "crud.delete"
        }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT 0, 'search:indexs', '/search/indexs', 'search/views/indexs/index', '', 1, 103, CAST('{
      "title": "搜索索引",
      "i18n": "search.Indexs",
      "icon": "mdi:menu",
      "type": "M",
      "hidden": 0,
      "componentPath": "modules\/",
      "componentSuffix": ".vue",
      "breadcrumbEnable": 1,
      "copyright": 1,
      "cache": 1,
      "affix": 0
    }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'search:indexs' LIMIT 1), 'search:indexs:list', '', '', '', 1, 0, CAST('{
          "title": "List",
          "type": "B",
          "i18n": "crud.list"
        }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'search:indexs' LIMIT 1), 'search:indexs:create', '', '', '', 1, 0, CAST('{
          "title": "Add",
          "type": "B",
          "i18n": "crud.add"
        }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'search:indexs' LIMIT 1), 'search:indexs:save', '', '', '', 1, 0, CAST('{
          "title": "Edit",
          "type": "B",
          "i18n": "crud.edit"
        }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'search:indexs' LIMIT 1), 'search:indexs:delete', '', '', '', 1, 0, CAST('{
          "title": "Delete",
          "type": "B",
          "i18n": "crud.delete"
        }' AS JSON), '', NULL, NULL, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `redirect` = VALUES(`redirect`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `meta` = VALUES(`meta`),
  `updated_at` = VALUES(`updated_at`),
  `id` = LAST_INSERT_ID(`id`);

