-- sysCms 业务种子：分类等（非菜单、非 system_config）
SET NAMES utf8mb4;

INSERT INTO `{{prefix}}category` (`id`, `name`, `icon`, `sort`, `parent_id`, `status`, `remark`, `code`, `created_by`, `updated_by`, `created_at`, `updated_at`)
VALUES (1, CAST('[{"lang": "zh_CN", "text": "公告"}, {"lang": "en", "text": "Notice"}]' AS JSON), '', 100, 0, 1, NULL, 'notice', 1, NULL, '2025-12-17 09:10:52', '2025-12-17 09:10:52')
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`), `icon` = VALUES(`icon`), `sort` = VALUES(`sort`), `parent_id` = VALUES(`parent_id`),
  `status` = VALUES(`status`), `remark` = VALUES(`remark`), `code` = VALUES(`code`),
  `created_by` = VALUES(`created_by`), `updated_by` = VALUES(`updated_by`), `updated_at` = VALUES(`updated_at`);

INSERT INTO `{{prefix}}category` (`id`, `name`, `icon`, `sort`, `parent_id`, `status`, `remark`, `code`, `created_by`, `updated_by`, `created_at`, `updated_at`)
VALUES (2, CAST('[{"lang": "zh_CN", "text": "新闻"}, {"lang": "en", "text": "News"}]' AS JSON), '', 100, 0, 1, NULL, 'news', 1, NULL, '2025-12-17 09:11:15', '2025-12-17 09:11:15')
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`), `icon` = VALUES(`icon`), `sort` = VALUES(`sort`), `parent_id` = VALUES(`parent_id`),
  `status` = VALUES(`status`), `remark` = VALUES(`remark`), `code` = VALUES(`code`),
  `created_by` = VALUES(`created_by`), `updated_by` = VALUES(`updated_by`), `updated_at` = VALUES(`updated_at`);

INSERT INTO `{{prefix}}category` (`id`, `name`, `icon`, `sort`, `parent_id`, `status`, `remark`, `code`, `created_by`, `updated_by`, `created_at`, `updated_at`)
VALUES (3, CAST('[{"lang": "zh_CN", "text": "帮助手册 1"}, {"lang": "en", "text": "help2"}]' AS JSON), '', 100, 0, 1, NULL, 'help_manual', 1, 1, '2025-12-17 09:12:20', '2025-12-17 09:30:17')
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`), `icon` = VALUES(`icon`), `sort` = VALUES(`sort`), `parent_id` = VALUES(`parent_id`),
  `status` = VALUES(`status`), `remark` = VALUES(`remark`), `code` = VALUES(`code`),
  `created_by` = VALUES(`created_by`), `updated_by` = VALUES(`updated_by`), `updated_at` = VALUES(`updated_at`);

INSERT INTO `{{prefix}}category` (`id`, `name`, `icon`, `sort`, `parent_id`, `status`, `remark`, `code`, `created_by`, `updated_by`, `created_at`, `updated_at`)
VALUES (4, CAST('[{"lang": "zh_CN", "text": "帮助手册 2"}, {"lang": "en", "text": "help2"}]' AS JSON), '', 100, 0, 1, NULL, 'help_manual', 1, 1, '2025-12-17 09:12:30', '2025-12-17 09:30:07')
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`), `icon` = VALUES(`icon`), `sort` = VALUES(`sort`), `parent_id` = VALUES(`parent_id`),
  `status` = VALUES(`status`), `remark` = VALUES(`remark`), `code` = VALUES(`code`),
  `created_by` = VALUES(`created_by`), `updated_by` = VALUES(`updated_by`), `updated_at` = VALUES(`updated_at`);
