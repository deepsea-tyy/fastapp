-- 菜单种子：维护请直接改本 SQL（migrate seed / 插件安装会执行 database/seeders）
-- 菜单 name 统一为插件路径「/」换「:」作前缀（本插件 ds/sysCms → ds:sysCms…）；plugin uninstall 会 DELETE menu + role_belongs_menu WHERE name LIKE 'ds:sysCms%'

SET NAMES utf8mb4;

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT 0, 'ds:sysCms', '/ds/sysCms', '', '', 1, 0, CAST('{"title":"内容管理","i18n":"article.ArticleManager","icon":"mdi:menu","type":"M","hidden":false,"componentPath":"modules\\/","componentSuffix":".vue","breadcrumbEnable":true,"copyright":true,"cache":true,"affix":false}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysCms' LIMIT 1), 'ds:sysCms:article', '/article/article', 'ds/sysCms/views/article/index', '', 1, 0, CAST('{"title":"文章列表","i18n":"article.Article","icon":"mdi:menu","type":"M","hidden":false,"componentPath":"modules\\/","componentSuffix":".vue","breadcrumbEnable":true,"copyright":true,"cache":true,"affix":false}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysCms:article' LIMIT 1), 'ds:sysCms:article:list', '', '', '', 1, 0, CAST('{"title":"List","i18n":"crud.list","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysCms:article' LIMIT 1), 'ds:sysCms:article:create', '', '', '', 1, 0, CAST('{"title":"Add","i18n":"crud.add","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysCms:article' LIMIT 1), 'ds:sysCms:article:save', '', '', '', 1, 0, CAST('{"title":"Edit","i18n":"crud.edit","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysCms:article' LIMIT 1), 'ds:sysCms:article:delete', '', '', '', 1, 0, CAST('{"title":"Delete","i18n":"crud.delete","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysCms' LIMIT 1), 'ds:sysCms:category', '/article/category', 'ds/sysCms/views/category/index', '', 1, 0, CAST('{"title":"分类列表","i18n":"article.Category","icon":"mdi:menu","type":"M","hidden":false,"componentPath":"modules\\/","componentSuffix":".vue","breadcrumbEnable":true,"copyright":true,"cache":true,"affix":false}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysCms:category' LIMIT 1), 'ds:sysCms:category:list', '', '', '', 1, 0, CAST('{"title":"List","i18n":"crud.list","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysCms:category' LIMIT 1), 'ds:sysCms:category:create', '', '', '', 1, 0, CAST('{"title":"Add","i18n":"crud.add","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysCms:category' LIMIT 1), 'ds:sysCms:category:save', '', '', '', 1, 0, CAST('{"title":"Edit","i18n":"crud.edit","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysCms:category' LIMIT 1), 'ds:sysCms:category:delete', '', '', '', 1, 0, CAST('{"title":"Delete","i18n":"crud.delete","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysCms' LIMIT 1), 'ds:sysCms:placement_position', '/ds/sysCms/admin/placementPosition', 'ds/sysCms/views/placementPosition/index', '', 1, 0, CAST('{"title":"投放位置","i18n":"admin.PlacementPosition","icon":"mdi:menu","type":"M","hidden":false,"componentPath":"plugins\\/","componentSuffix":".vue","breadcrumbEnable":true,"copyright":true,"cache":true,"affix":false}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysCms:placement_position' LIMIT 1), 'ds:sysCms:placement_position:list', '', '', '', 1, 0, CAST('{"title":"List","i18n":"crud.list","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysCms:placement_position' LIMIT 1), 'ds:sysCms:placement_position:create', '', '', '', 1, 0, CAST('{"title":"Add","i18n":"crud.add","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysCms:placement_position' LIMIT 1), 'ds:sysCms:placement_position:save', '', '', '', 1, 0, CAST('{"title":"Edit","i18n":"crud.edit","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysCms:placement_position' LIMIT 1), 'ds:sysCms:placement_position:delete', '', '', '', 1, 0, CAST('{"title":"Delete","i18n":"crud.delete","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysCms' LIMIT 1), 'ds:sysCms:placement_content', '/ds/sysCms/admin/placementContent', 'ds/sysCms/views/placementContent/index', '', 1, 0, CAST('{"title":"投放内容","i18n":"admin.PlacementContent","icon":"mdi:menu","type":"M","hidden":false,"componentPath":"plugins\\/","componentSuffix":".vue","breadcrumbEnable":true,"copyright":true,"cache":true,"affix":false}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysCms:placement_content' LIMIT 1), 'ds:sysCms:placement_content:list', '', '', '', 1, 0, CAST('{"title":"List","i18n":"crud.list","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysCms:placement_content' LIMIT 1), 'ds:sysCms:placement_content:create', '', '', '', 1, 0, CAST('{"title":"Add","i18n":"crud.add","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysCms:placement_content' LIMIT 1), 'ds:sysCms:placement_content:save', '', '', '', 1, 0, CAST('{"title":"Edit","i18n":"crud.edit","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysCms:placement_content' LIMIT 1), 'ds:sysCms:placement_content:delete', '', '', '', 1, 0, CAST('{"title":"Delete","i18n":"crud.delete","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysCms' LIMIT 1), 'ds:sysCms:app_page_content', '/ds/sysCms/admin/appPageContent', 'ds/sysCms/views/appPageContent/index', '', 1, 0, CAST('{"title":"App页面内容","i18n":"admin.AppPageContent","icon":"mdi:menu","type":"M","hidden":false,"componentPath":"plugins\\/","componentSuffix":".vue","breadcrumbEnable":true,"copyright":true,"cache":true,"affix":false}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysCms:app_page_content' LIMIT 1), 'ds:sysCms:app_page_content:list', '', '', '', 1, 0, CAST('{"title":"List","i18n":"crud.list","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysCms:app_page_content' LIMIT 1), 'ds:sysCms:app_page_content:create', '', '', '', 1, 0, CAST('{"title":"Add","i18n":"crud.add","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysCms:app_page_content' LIMIT 1), 'ds:sysCms:app_page_content:save', '', '', '', 1, 0, CAST('{"title":"Edit","i18n":"crud.edit","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysCms:app_page_content' LIMIT 1), 'ds:sysCms:app_page_content:delete', '', '', '', 1, 0, CAST('{"title":"Delete","i18n":"crud.delete","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysCms' LIMIT 1), 'ds:sysCms:app_page_content_sync', '/ds/sysCms/admin/appPageContentSync', 'ds/sysCms/views/appPageContentSync/index', '', 1, 0, CAST('{"title":"App页面内容同步","i18n":"admin.AppPageContentSync","icon":"mdi:menu","type":"M","hidden":false,"componentPath":"plugins\\/","componentSuffix":".vue","breadcrumbEnable":true,"copyright":true,"cache":true,"affix":false}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysCms:app_page_content_sync' LIMIT 1), 'ds:sysCms:app_page_content_sync:list', '', '', '', 1, 0, CAST('{"title":"List","i18n":"crud.list","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);

INSERT INTO `{{prefix}}menu` (`parent_id`, `name`, `path`, `component`, `redirect`, `status`, `sort`, `meta`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`)
SELECT (SELECT p.id FROM `{{prefix}}menu` p WHERE p.name = 'ds:sysCms:app_page_content_sync' LIMIT 1), 'ds:sysCms:app_page_content_sync:generate', '', '', '', 1, 0, CAST('{"title":"Generate","i18n":"admin.AppPageContentSyncFields.generate","type":"B"}' AS JSON), '', 0, 0, NOW(), NOW()
FROM DUAL
ON DUPLICATE KEY UPDATE `parent_id` = VALUES(`parent_id`), `path` = VALUES(`path`), `component` = VALUES(`component`), `redirect` = VALUES(`redirect`), `status` = VALUES(`status`), `sort` = VALUES(`sort`), `meta` = VALUES(`meta`), `updated_at` = VALUES(`updated_at`), `id` = LAST_INSERT_ID(`id`);
