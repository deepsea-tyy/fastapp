-- 菜单种子：维护请直接改本 SQL（migrate seed / 插件安装会执行 database/seeders）

SET NAMES utf8mb4;

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT 0, 'ds:sysNotify', '/ds/sysNotify/admin/messageNotify', 'ds/sysNotify/views/messageNotify/index', '', 1, 0, CAST('{"title":"消息通知","i18n":"admin.MessageNotify","icon":"mdi:menu","type":"M","hidden":false,"componentPath":"modules\\/","componentSuffix":".vue","breadcrumbEnable":true,"copyright":true,"cache":true,"affix":false}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysNotify' LIMIT 1), 'ds:sysNotify:message_notify:list', '', '', '', 1, 0, CAST('{"title":"List","type":"B","i18n":"crud.list"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysNotify' LIMIT 1), 'ds:sysNotify:message_notify:create', '', '', '', 1, 0, CAST('{"title":"Add","type":"B","i18n":"crud.add"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysNotify' LIMIT 1), 'ds:sysNotify:message_notify:save', '', '', '', 1, 0, CAST('{"title":"Edit","type":"B","i18n":"crud.edit"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysNotify' LIMIT 1), 'ds:sysNotify:message_notify:delete', '', '', '', 1, 0, CAST('{"title":"Delete","type":"B","i18n":"crud.delete"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

