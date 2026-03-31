SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE `{{prefix}}system_config_group` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` json NOT NULL COMMENT '配置组名称',
  `code` varchar(64) NOT NULL COMMENT '配置组标识',
  `icon` varchar(128) DEFAULT NULL COMMENT '配置组图标',
  `created_by` bigint DEFAULT NULL COMMENT '创建者',
  `updated_by` bigint DEFAULT NULL COMMENT '更新者',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `system_config_group_code_unique` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='配置组';

CREATE TABLE `{{prefix}}system_config` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `group_code` varchar(64) DEFAULT NULL COMMENT '组code',
  `key` varchar(32) NOT NULL COMMENT '配置键名',
  `value` json DEFAULT NULL COMMENT '配置值',
  `name` json DEFAULT NULL COMMENT '配置名称',
  `input_type` varchar(32) DEFAULT NULL COMMENT '数据输入类型',
  `config_select_data` json DEFAULT NULL COMMENT '配置选项数据',
  `sort` smallint unsigned NOT NULL DEFAULT '0' COMMENT '排序',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `created_by` bigint DEFAULT NULL COMMENT '创建者',
  `updated_by` bigint DEFAULT NULL COMMENT '更新者',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `system_config_group_code_key_unique` (`group_code`,`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
