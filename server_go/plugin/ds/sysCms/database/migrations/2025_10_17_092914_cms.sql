SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE `{{prefix}}article` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `title` varchar(255) DEFAULT NULL COMMENT '标题',
  `subtitle` varchar(255) DEFAULT NULL COMMENT '副标题',
  `lang` char(8) DEFAULT NULL COMMENT '语言',
  `author` varchar(32) DEFAULT NULL COMMENT '作者',
  `cover` varchar(255) DEFAULT NULL COMMENT '封面',
  `video` varchar(255) DEFAULT NULL COMMENT '视频',
  `release_at` varchar(255) DEFAULT NULL COMMENT '发布日期',
  `brief` varchar(300) DEFAULT NULL COMMENT '摘要',
  `content` text COMMENT '内容',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `sort` int NOT NULL DEFAULT '100' COMMENT '排序',
  `view_count` int unsigned NOT NULL DEFAULT '0' COMMENT '浏览数',
  `like_count` int unsigned NOT NULL DEFAULT '0' COMMENT '点赞数',
  `comment_count` int unsigned NOT NULL DEFAULT '0' COMMENT '评论数',
  `share_count` int unsigned NOT NULL DEFAULT '0' COMMENT '分享数',
  `collect_count` int unsigned NOT NULL DEFAULT '0' COMMENT '收藏数',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '1显示',
  `code` char(32) DEFAULT NULL COMMENT '调用代码',
  `created_by` bigint unsigned DEFAULT NULL COMMENT '创建者',
  `updated_by` bigint unsigned DEFAULT NULL COMMENT '更新者',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `article_code_unique` (`code`),
  KEY `article_created_by_index` (`created_by`),
  KEY `article_created_at_index` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文章表';

CREATE TABLE `{{prefix}}category` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `name` json DEFAULT NULL COMMENT '名称',
  `icon` varchar(255) DEFAULT NULL COMMENT 'icon',
  `sort` int NOT NULL DEFAULT '100' COMMENT '排序',
  `parent_id` bigint NOT NULL DEFAULT '0' COMMENT '上级',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '1显示',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `code` char(32) DEFAULT NULL COMMENT '调用代码',
  `created_by` bigint unsigned DEFAULT NULL COMMENT '创建者',
  `updated_by` bigint unsigned DEFAULT NULL COMMENT '更新者',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `category_code_index` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='分类表';

CREATE TABLE `{{prefix}}category_correlation` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `category_id` bigint DEFAULT NULL COMMENT '分类id',
  `data_id` bigint DEFAULT NULL COMMENT '数据id',
  `type` tinyint DEFAULT NULL COMMENT '1:article',
  PRIMARY KEY (`id`),
  KEY `category_correlation_category_id_index` (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='分类关联表';

CREATE TABLE `{{prefix}}placement_position` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `code` varchar(32) DEFAULT NULL COMMENT '调用代码',
  `name` varchar(128) DEFAULT NULL COMMENT '位置名称',
  `status` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '状态',
  `created_by` bigint unsigned DEFAULT NULL COMMENT '创建者',
  `updated_by` bigint unsigned DEFAULT NULL COMMENT '更新者',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `placement_position_code_unique` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='投放位置表';

CREATE TABLE `{{prefix}}placement_content` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `code` varchar(32) DEFAULT NULL COMMENT '调用代码',
  `name` varchar(128) DEFAULT NULL COMMENT '内容名称',
  `object_type` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '数据类型',
  `object_id` bigint unsigned DEFAULT '0' COMMENT '关联数据ID',
  `url` varchar(512) DEFAULT NULL COMMENT '链接地址',
  `target` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '链接打开方式',
  `title` json DEFAULT NULL COMMENT '标题',
  `cover` varchar(512) DEFAULT NULL COMMENT '封面',
  `desc` json DEFAULT NULL COMMENT '描述',
  `content` json DEFAULT NULL COMMENT '分享内容',
  `start_at` int unsigned DEFAULT NULL COMMENT '开始时间',
  `end_at` int unsigned DEFAULT NULL COMMENT '结束时间',
  `fixed` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '永久有效',
  `status` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '状态',
  `sort` int unsigned NOT NULL DEFAULT '0' COMMENT '排序',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `views` int unsigned NOT NULL DEFAULT '0' COMMENT '展示次数',
  `clicks` int unsigned NOT NULL DEFAULT '0' COMMENT '点击次数',
  `created_by` bigint unsigned DEFAULT NULL COMMENT '创建者',
  `updated_by` bigint unsigned DEFAULT NULL COMMENT '更新者',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `placement_content_code_unique` (`code`),
  KEY `placement_content_object_type_object_id_index` (`object_type`,`object_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='投放内容表';

CREATE TABLE `{{prefix}}placement_position_content` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `position_id` bigint unsigned NOT NULL COMMENT '投放位置ID',
  `content_id` bigint unsigned NOT NULL COMMENT '投放内容ID',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `placement_position_content_position_id_index` (`position_id`),
  KEY `placement_position_content_content_id_index` (`content_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='投放位置内容关联表';

CREATE TABLE `{{prefix}}app_page_content` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `code` varchar(64) DEFAULT NULL COMMENT '内容标识',
  `page_code` varchar(32) NOT NULL COMMENT '页面标识',
  `component_code` varchar(32) DEFAULT NULL COMMENT '组件标识',
  `content_type` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '内容类型',
  `data` json DEFAULT NULL COMMENT '内容数据',
  `platform` tinyint unsigned NOT NULL DEFAULT '2' COMMENT '平台',
  `start_at` int unsigned DEFAULT NULL COMMENT '开始时间',
  `end_at` int unsigned DEFAULT NULL COMMENT '结束时间',
  `fixed` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '永久有效',
  `status` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '状态',
  `sort` int unsigned NOT NULL DEFAULT '100' COMMENT '排序',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `created_by` bigint unsigned DEFAULT NULL COMMENT '创建者',
  `updated_by` bigint unsigned DEFAULT NULL COMMENT '更新者',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `app_page_content_code_unique` (`code`),
  KEY `app_page_content_page_component_index` (`page_code`,`component_code`),
  KEY `app_page_content_platform_index` (`platform`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='App页面内容表';

CREATE TABLE `{{prefix}}app_page_content_sync` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `version` varchar(32) NOT NULL COMMENT '版本号',
  `platform` tinyint unsigned NOT NULL COMMENT '平台',
  `file_path` varchar(255) NOT NULL COMMENT '文件路径',
  `file_size` int unsigned NOT NULL DEFAULT '0' COMMENT '文件大小',
  `record_count` int unsigned NOT NULL DEFAULT '0' COMMENT '记录数量',
  `generated_at` timestamp NULL DEFAULT NULL COMMENT '生成时间',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `app_page_content_sync_platform_index` (`platform`),
  KEY `app_page_content_sync_version_index` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='App页面内容同步版本管理表';

SET FOREIGN_KEY_CHECKS = 1;
