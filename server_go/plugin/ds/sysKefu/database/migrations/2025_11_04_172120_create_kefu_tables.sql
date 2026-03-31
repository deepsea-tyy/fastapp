SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE `{{prefix}}kefu` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `nickname` varchar(50) DEFAULT NULL COMMENT '昵称',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '1启用2禁用',
  `max_concurrent` int NOT NULL DEFAULT '0' COMMENT '最大会话数 0不限',
  `current_concurrent` int NOT NULL DEFAULT '0' COMMENT '当前会话数',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `created_by` bigint unsigned DEFAULT NULL COMMENT '创建者',
  `updated_by` bigint unsigned DEFAULT NULL COMMENT '更新者',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='客服表';

CREATE TABLE `{{prefix}}kefu_conversation` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `kefu_id` bigint NOT NULL COMMENT '关联客服表',
  `user_id` bigint NOT NULL COMMENT '用户id',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '会话状态：1-进行中，2-已结束',
  `last_message_at` timestamp NULL DEFAULT NULL COMMENT '最后消息时间',
  `unread_count` int NOT NULL DEFAULT '0' COMMENT '未读消息数（用户侧）',
  `kefu_unread_count` int NOT NULL DEFAULT '0' COMMENT '未读消息数（客服侧）',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `kefu_conversation_kefu_id_index` (`kefu_id`),
  KEY `kefu_conversation_user_id_index` (`user_id`),
  KEY `kefu_conversation_last_message_at_index` (`last_message_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='客服会话表';

CREATE TABLE `{{prefix}}kefu_message` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `conversation_id` bigint NOT NULL COMMENT '会话ID',
  `sender_id` bigint NOT NULL COMMENT '发送者ID',
  `sender_type` tinyint NOT NULL COMMENT '发送者类型：1-用户，2-客服',
  `content` text NOT NULL COMMENT '消息内容',
  `message_type` tinyint NOT NULL DEFAULT '1' COMMENT '消息类型：1-文本，2-图片，3-文件',
  `file_url` varchar(255) DEFAULT NULL COMMENT '文件URL（图片或文件类型时使用）',
  `is_read` tinyint NOT NULL DEFAULT '0' COMMENT '是否已读：0-未读，1-已读',
  `read_at` timestamp NULL DEFAULT NULL COMMENT '阅读时间',
  `is_auto_reply` tinyint NOT NULL DEFAULT '0' COMMENT '是否自动回复：0=否，1=是',
  `auto_reply_rule_id` bigint unsigned DEFAULT NULL COMMENT '自动回复规则ID',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `kefu_message_conversation_id_index` (`conversation_id`),
  KEY `kefu_message_sender_id_index` (`sender_id`),
  KEY `kefu_message_created_at_index` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='客服消息表';

CREATE TABLE `{{prefix}}kefu_knowledge` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `keywords` varchar(255) NOT NULL COMMENT '关键词列表(,分割)',
  `content` text NOT NULL COMMENT '回复内容',
  `match_type` tinyint NOT NULL DEFAULT '2' COMMENT '匹配类型：1-精确匹配，2-包含匹配，3-模糊匹配',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态：1-启用，2-禁用',
  `sort` int NOT NULL DEFAULT '0' COMMENT '排序',
  `priority` int NOT NULL DEFAULT '0' COMMENT '优先级（数字越大优先级越高）',
  `hit_count` int NOT NULL DEFAULT '0' COMMENT '命中次数',
  `created_by` bigint unsigned DEFAULT NULL COMMENT '创建者',
  `updated_by` bigint unsigned DEFAULT NULL COMMENT '更新者',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='客服知识库表';

CREATE TABLE `{{prefix}}kefu_visitor` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `visitor_id` varchar(255) NOT NULL COMMENT '游客标识',
  `kefu_id` varchar(255) NOT NULL COMMENT '客服ID',
  `sender_type` tinyint NOT NULL DEFAULT '1',
  `content` text NOT NULL COMMENT '消息内容',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `kefu_visitor_visitor_id_index` (`visitor_id`),
  KEY `kefu_visitor_kefu_id_index` (`kefu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='客服游客消息表';

CREATE TABLE `{{prefix}}kefu_auto_reply` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '规则ID',
  `title` varchar(100) NOT NULL COMMENT '规则名称',
  `trigger_type` tinyint NOT NULL DEFAULT '1' COMMENT '触发类型：1=关键词精确匹配，2=关键词模糊匹配，3=正则匹配',
  `keywords` text NOT NULL COMMENT '关键词列表（JSON数组）',
  `reply_type` tinyint NOT NULL DEFAULT '1' COMMENT '回复类型：1=纯文本，2=图片，3=文件，4=多条消息',
  `reply_content` text NOT NULL COMMENT '回复内容（JSON格式，支持多语言）',
  `lang` varchar(10) NOT NULL DEFAULT 'zh_CN' COMMENT '语言',
  `priority` int NOT NULL DEFAULT '0' COMMENT '优先级',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态：0=禁用，1=启用',
  `hit_count` int NOT NULL DEFAULT '0' COMMENT '命中次数',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `created_by` bigint unsigned DEFAULT NULL COMMENT '创建者',
  `updated_by` bigint unsigned DEFAULT NULL COMMENT '更新者',
  PRIMARY KEY (`id`),
  KEY `idx_status_priority_lang` (`status`,`priority`,`lang`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='客服自动回复规则表';

CREATE TABLE `{{prefix}}kefu_auto_reply_log` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `conversation_id` bigint unsigned NOT NULL COMMENT '会话ID',
  `user_id` bigint unsigned NOT NULL COMMENT '用户ID',
  `kefu_id` bigint unsigned DEFAULT NULL COMMENT '客服ID',
  `rule_id` bigint unsigned NOT NULL COMMENT '命中的规则ID',
  `user_message` varchar(500) NOT NULL COMMENT '用户发送的消息内容',
  `reply_content` text NOT NULL COMMENT '自动回复的内容',
  `lang` varchar(10) NOT NULL DEFAULT 'zh_CN' COMMENT '回复语言',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_conversation` (`conversation_id`),
  KEY `idx_rule` (`rule_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='客服自动回复日志表';

SET FOREIGN_KEY_CHECKS = 1;
