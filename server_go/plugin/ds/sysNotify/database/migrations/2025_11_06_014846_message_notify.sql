SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE `{{prefix}}message_notify` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `title` json DEFAULT NULL COMMENT '通知标题',
  `content` json DEFAULT NULL COMMENT '通知内容',
  `type` tinyint NOT NULL DEFAULT '1' COMMENT '通知类型:1-全局,2-个人',
  `user_id` bigint unsigned NOT NULL DEFAULT '0' COMMENT '用户ID 全局通知为0',
  `notify_type` tinyint NOT NULL DEFAULT '1' COMMENT '通知分类:1-公告,2-业务通知(活动等),3-账号,4-广场,5-资金',
  `link` varchar(512) DEFAULT NULL COMMENT '跳转链接',
  `created_by` bigint unsigned DEFAULT NULL COMMENT '创建者',
  `updated_by` bigint unsigned DEFAULT NULL COMMENT '更新者',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `message_notify_type_index` (`type`),
  KEY `message_notify_user_id_index` (`user_id`),
  KEY `message_notify_notify_type_index` (`notify_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='消息通知表';

CREATE TABLE `{{prefix}}message_notify_read` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `notify_type` bigint unsigned NOT NULL COMMENT '通知分类',
  `notify_id` bigint unsigned NOT NULL DEFAULT '0' COMMENT '已读最大ID',
  `user_id` bigint unsigned NOT NULL COMMENT '用户ID',
  PRIMARY KEY (`id`),
  KEY `message_notify_read_user_id_index` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='消息已读状态表';

SET FOREIGN_KEY_CHECKS = 1;
