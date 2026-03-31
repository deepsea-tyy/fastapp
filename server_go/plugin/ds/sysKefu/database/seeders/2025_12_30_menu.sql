-- 菜单种子：维护请直接改本 SQL（migrate seed / 插件安装会执行 database/seeders）

SET NAMES utf8mb4;

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT 0, 'ds:sysKefu', '/sysKefu', '', '', 1, 6, CAST('{"title":"客服管理","i18n":"kefu.KefuManager","icon":"ant-design:container-outlined","type":"M","hidden":false}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysKefu' LIMIT 1), 'ds:sysKefu:chat', '/sysKefu/chat', 'ds/sysKefu/views/chat/index', '', 1, 1, CAST('{"title":"客服窗口","i18n":"kefu.KefuChat","icon":"ep:chat-dot-square","type":"M","hidden":false,"componentPath":"modules\\/","componentSuffix":".vue","breadcrumbEnable":true,"copyright":true,"cache":true,"affix":false}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysKefu' LIMIT 1), 'ds:sysKefu:kefu', '/sysKefu/kefu', 'ds/sysKefu/views/kefu/index', '', 1, 3, CAST('{"title":"客服列表","i18n":"kefu.Kefu","icon":"mdi:menu","type":"M","hidden":false,"componentPath":"modules\\/","componentSuffix":".vue","breadcrumbEnable":true,"copyright":true,"cache":true,"affix":false}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysKefu:kefu' LIMIT 1), 'ds:sysKefu:kefu:index', '', '', '', 1, 0, CAST('{"title":"列表","type":"B","i18n":"crud.list"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysKefu:kefu' LIMIT 1), 'ds:sysKefu:kefu:save', '', '', '', 1, 0, CAST('{"title":"添加","type":"B","i18n":"crud.add"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysKefu:kefu' LIMIT 1), 'ds:sysKefu:kefu:update', '', '', '', 1, 0, CAST('{"title":"修改","type":"B","i18n":"crud.edit"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysKefu:kefu' LIMIT 1), 'ds:sysKefu:kefu:delete', '', '', '', 1, 0, CAST('{"title":"删除","type":"B","i18n":"crud.delete"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysKefu' LIMIT 1), 'ds:sysKefu:kefuConversation', '/sysKefu/kefuConversation', 'ds/sysKefu/views/kefuConversation/index', '', 1, 3, CAST('{"title":"会话列表","i18n":"kefu.KefuConversation","icon":"mdi:menu","type":"M","hidden":false,"componentPath":"modules\\/","componentSuffix":".vue","breadcrumbEnable":true,"copyright":true,"cache":true,"affix":false}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysKefu:kefuConversation' LIMIT 1), 'ds:sysKefu:kefuConversation:index', '', '', '', 1, 0, CAST('{"title":"列表","type":"B","i18n":"crud.list"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysKefu:kefuConversation' LIMIT 1), 'ds:sysKefu:kefuConversation:delete', '', '', '', 1, 0, CAST('{"title":"删除","type":"B","i18n":"crud.delete"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysKefu' LIMIT 1), 'ds:syskefu:kefu_auto_reply', '/ds/sysKefu/admin/kefuAutoReply', 'ds/sysKefu/views/kefuAutoReply/index', '', 1, 4, CAST('{"title":"客服自动回复规则","i18n":"admin.KefuAutoReply","icon":"mdi:menu","type":"M","hidden":false,"componentPath":"plugins\\/","componentSuffix":".vue","breadcrumbEnable":true,"copyright":true,"cache":true,"affix":false}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:syskefu:kefu_auto_reply' LIMIT 1), 'ds:syskefu:kefu_auto_reply:list', '', '', '', 1, 0, CAST('{"title":"List","type":"B","i18n":"crud.list"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:syskefu:kefu_auto_reply' LIMIT 1), 'ds:syskefu:kefu_auto_reply:create', '', '', '', 1, 0, CAST('{"title":"Add","type":"B","i18n":"crud.add"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:syskefu:kefu_auto_reply' LIMIT 1), 'ds:syskefu:kefu_auto_reply:save', '', '', '', 1, 0, CAST('{"title":"Edit","type":"B","i18n":"crud.edit"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:syskefu:kefu_auto_reply' LIMIT 1), 'ds:syskefu:kefu_auto_reply:delete', '', '', '', 1, 0, CAST('{"title":"Delete","type":"B","i18n":"crud.delete"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

