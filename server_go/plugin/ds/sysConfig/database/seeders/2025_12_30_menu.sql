-- 菜单种子：维护请直接改本 SQL（migrate seed / 插件安装会执行 database/seeders）

SET NAMES utf8mb4;

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT 0, 'ds:sysConfig', '/system', 'ds/sysConfig/views/index', '', 1, 0, CAST('{"title":"系统设置","type":"M","hidden":0,"icon":"ant-design:setting-outlined","i18n":"systemMenu.systemConfig.name","componentPath":"plugins\\/","componentSuffix":".vue","breadcrumbEnable":1,"copyright":1,"cache":1,"affix":0}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysConfig' LIMIT 1), 'ds:sysConfigGroup:list', '', '', '', 1, 0, CAST('{"title":"系统分组列表","i18n":"systemMenu.systemConfig.actions.index","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysConfig' LIMIT 1), 'ds:sysConfigGroup:index:create', '', '', '', 1, 0, CAST('{"title":"系统分组创建","i18n":"systemMenu.systemConfig.actions.create","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysConfig' LIMIT 1), 'ds:sysConfigGroup:update', '', '', '', 1, 0, CAST('{"title":"系统分组更新","i18n":"systemMenu.systemConfig.actions.update","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysConfig' LIMIT 1), 'ds:sysConfigGroup:delete', '', '', '', 1, 0, CAST('{"title":"系统分组删除","i18n":"systemMenu.systemConfig.actions.delete","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysConfig' LIMIT 1), 'ds:sysConfig:list', '', '', '', 1, 0, CAST('{"title":"系统配置列表","i18n":"systemMenu.systemConfig.actions.configIndex","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysConfig' LIMIT 1), 'ds:sysConfig:details', '', '', '', 1, 0, CAST('{"title":"系统配置详情","i18n":"systemMenu.systemConfig.actions.configDetails","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysConfig' LIMIT 1), 'ds:sysConfig:create', '', '', '', 1, 0, CAST('{"title":"系统配置创建","i18n":"systemMenu.systemConfig.actions.configCreate","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysConfig' LIMIT 1), 'ds:sysConfig:update', '', '', '', 1, 0, CAST('{"title":"系统配置更新","i18n":"systemMenu.systemConfig.actions.configUpdate","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysConfig' LIMIT 1), 'ds:sysConfig:delete', '', '', '', 1, 0, CAST('{"title":"系统配置删除","i18n":"systemMenu.systemConfig.actions.configDelete","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysConfig' LIMIT 1), 'ds:sysConfig:batchUpdate', '', '', '', 1, 0, CAST('{"title":"系统配置批量更新","i18n":"systemMenu.systemConfig.actions.configBatchUpdate","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

