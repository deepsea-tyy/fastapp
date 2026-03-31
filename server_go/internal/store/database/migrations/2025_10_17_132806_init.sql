SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 自 PHP databases/migrations/2025_10_17_132806_init.php 迁出；表名使用 {{prefix}}

CREATE TABLE `{{prefix}}user` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `username` varchar(64) DEFAULT NULL COMMENT '用户名',
  `email` varchar(50) DEFAULT NULL COMMENT '用户邮箱',
  `code` smallint DEFAULT NULL COMMENT '手机code',
  `mobile` varchar(11) DEFAULT NULL COMMENT '手机',
  `password` varchar(100) NOT NULL COMMENT '密码',
  `user_type` varchar(3) NOT NULL DEFAULT '100' COMMENT '用户类型:100=系统用户,200=普通用户,300=通用账户',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态:1=正常,2=停用',
  `google2fa` varchar(50) DEFAULT NULL COMMENT 'google2fa',
  `remark` varchar(255) NOT NULL DEFAULT '' COMMENT '备注',
  `created_by` bigint unsigned DEFAULT NULL COMMENT '创建者',
  `updated_by` bigint unsigned DEFAULT NULL COMMENT '更新者',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_username_unique` (`username`),
  UNIQUE KEY `user_email_unique` (`email`),
  UNIQUE KEY `user_mobile_code_unique` (`mobile`,`code`),
  KEY `user_user_type_index` (`user_type`),
  KEY `user_status_index` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='账户表';

CREATE TABLE `{{prefix}}user_admin_setting` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `phone` varchar(255) DEFAULT NULL COMMENT '联系电话',
  `dept_id` json DEFAULT NULL COMMENT '部门ID',
  `backend_setting` json DEFAULT NULL COMMENT '后台设置数据',
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_admin_setting_user_id_unique` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='管理员信息表';

CREATE TABLE `{{prefix}}user_admin_login_log` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username` varchar(20) NOT NULL COMMENT '用户名',
  `ip` varchar(45) DEFAULT NULL COMMENT '登录IP地址',
  `os` varchar(255) DEFAULT NULL COMMENT '操作系统',
  `browser` varchar(255) DEFAULT NULL COMMENT '浏览器',
  `status` smallint NOT NULL DEFAULT '1' COMMENT '登录状态 (1成功 2失败)',
  `message` varchar(50) DEFAULT NULL COMMENT '提示消息',
  `login_time` datetime NOT NULL COMMENT '登录时间',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  KEY `user_admin_login_log_username_index` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='登录日志表';

CREATE TABLE `{{prefix}}user_admin_operation_log` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(20) NOT NULL COMMENT '用户名',
  `method` varchar(20) NOT NULL COMMENT '请求方式',
  `router` varchar(500) NOT NULL COMMENT '请求路由',
  `service_name` varchar(30) NOT NULL COMMENT '业务名称',
  `ip` varchar(45) DEFAULT NULL COMMENT '请求IP地址',
  `request_params` json DEFAULT NULL COMMENT '请求参数',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `user_admin_operation_log_username_index` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='操作日志表';

CREATE TABLE `{{prefix}}user_profile` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `nickname` varchar(30) NOT NULL DEFAULT '' COMMENT '用户昵称',
  `avatar` varchar(255) DEFAULT NULL COMMENT '用户头像',
  `signed` varchar(255) DEFAULT NULL COMMENT '个人签名',
  `lang` varchar(8) DEFAULT NULL COMMENT '言语',
  `trans_password` varchar(50) DEFAULT NULL COMMENT '交易密码',
  `setting` json DEFAULT NULL COMMENT '用户设置',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_profile_user_id_unique` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户信息表';

CREATE TABLE `{{prefix}}user_account_log` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '用户id',
  `type` tinyint NOT NULL DEFAULT '1' COMMENT '类型1:登录,2:注册,3:重置密码,4:绑定手机,5:绑定邮箱,6:解绑手机,7:解绑邮箱,8:禁用账户,9:删除账户,10:绑定2fa,11:解绑2fa',
  `ip` varchar(45) NOT NULL COMMENT 'IP',
  `os` varchar(255) NOT NULL COMMENT '操作系统',
  `device_id` varchar(128) DEFAULT NULL COMMENT '设备唯一标识（iOS/Android/Web通用）',
  `country_code` varchar(64) DEFAULT NULL COMMENT '国家代码',
  `country` varchar(64) DEFAULT NULL COMMENT '国家',
  `region` varchar(64) DEFAULT NULL COMMENT '省',
  `city` varchar(64) DEFAULT NULL COMMENT '市',
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_account_log_user_id_index` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户账户日志';

CREATE TABLE `{{prefix}}rules` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `ptype` varchar(255) DEFAULT NULL COMMENT '策略类型（p=策略，g=角色继承）',
  `v0` varchar(255) DEFAULT NULL COMMENT '规则参数0',
  `v1` varchar(255) DEFAULT NULL COMMENT '规则参数1',
  `v2` varchar(255) DEFAULT NULL COMMENT '规则参数2',
  `v3` varchar(255) DEFAULT NULL COMMENT '规则参数3',
  `v4` varchar(255) DEFAULT NULL COMMENT '规则参数4',
  `v5` varchar(255) DEFAULT NULL COMMENT '规则参数5',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Casbin权限规则表';

CREATE TABLE `{{prefix}}menu` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `parent_id` bigint unsigned NOT NULL COMMENT '父ID',
  `name` varchar(50) NOT NULL DEFAULT '' COMMENT '菜单名称',
  `meta` json DEFAULT NULL COMMENT '附加属性',
  `path` varchar(60) NOT NULL DEFAULT '' COMMENT '路径',
  `component` varchar(150) NOT NULL DEFAULT '' COMMENT '组件路径',
  `redirect` varchar(100) NOT NULL DEFAULT '' COMMENT '重定向地址',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态:1=正常,2=停用',
  `sort` smallint NOT NULL DEFAULT '0' COMMENT '排序',
  `created_by` bigint unsigned DEFAULT NULL COMMENT '创建者',
  `updated_by` bigint unsigned DEFAULT NULL COMMENT '更新者',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `remark` varchar(60) NOT NULL DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`id`),
  UNIQUE KEY `menu_name_unique` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='菜单信息表';

CREATE TABLE `{{prefix}}role` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(30) NOT NULL COMMENT '角色名称',
  `code` varchar(100) NOT NULL COMMENT '角色代码',
  `data_scope` tinyint NOT NULL DEFAULT '5' COMMENT '数据范围（1：全部数据权限 2：自定义数据权限 3：本部门数据权限 4：本部门及以下数据权限 5：本人数据权限）',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态:1=正常,2=停用',
  `sort` smallint NOT NULL DEFAULT '0' COMMENT '排序',
  `created_by` bigint unsigned DEFAULT NULL COMMENT '创建者',
  `updated_by` bigint unsigned DEFAULT NULL COMMENT '更新者',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `remark` varchar(255) NOT NULL DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`id`),
  UNIQUE KEY `role_code_unique` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色信息表';

CREATE TABLE `{{prefix}}attachment` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `storage_mode` varchar(20) NOT NULL DEFAULT 'local' COMMENT '存储模式:local=本地,oss=阿里云,qiniu=七牛云,cos=腾讯云',
  `origin_name` varchar(255) DEFAULT NULL COMMENT '原文件名',
  `object_name` varchar(50) DEFAULT NULL COMMENT '新文件名',
  `hash` varchar(64) DEFAULT NULL COMMENT '文件hash',
  `mime_type` varchar(255) DEFAULT NULL COMMENT '资源类型',
  `suffix` varchar(20) DEFAULT NULL COMMENT '文件后缀',
  `size_byte` bigint DEFAULT NULL COMMENT '字节数',
  `size_info` varchar(50) DEFAULT NULL COMMENT '文件大小',
  `url` varchar(255) DEFAULT NULL COMMENT 'url地址',
  `created_by` bigint unsigned DEFAULT NULL COMMENT '创建者',
  `updated_by` bigint unsigned DEFAULT NULL COMMENT '更新者',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  UNIQUE KEY `attachment_hash_unique` (`hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='上传文件信息表';

CREATE TABLE `{{prefix}}user_belongs_role` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '用户id',
  `role_id` bigint NOT NULL COMMENT '角色id',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_role` (`user_id`,`role_id`),
  KEY `idx_ubr_user_id` (`user_id`),
  KEY `idx_ubr_role_id` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户角色关联表';

CREATE TABLE `{{prefix}}role_belongs_menu` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `role_id` bigint NOT NULL COMMENT '角色id',
  `menu_id` bigint NOT NULL COMMENT '菜单id',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_menu` (`role_id`,`menu_id`),
  KEY `idx_rbm_role_id` (`role_id`),
  KEY `idx_rbm_menu_id` (`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色菜单关联表';

CREATE TABLE `{{prefix}}department` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(50) NOT NULL COMMENT '部门名称',
  `code` varchar(50) DEFAULT NULL COMMENT '部门代码',
  `parent_id` bigint unsigned NOT NULL DEFAULT '0' COMMENT '父部门ID',
  `sort` smallint NOT NULL DEFAULT '0' COMMENT '排序',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态:1=正常,2=停用',
  `created_by` bigint unsigned DEFAULT NULL COMMENT '创建者',
  `updated_by` bigint unsigned DEFAULT NULL COMMENT '更新者',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `remark` varchar(255) NOT NULL DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`id`),
  UNIQUE KEY `department_code_unique` (`code`),
  KEY `department_parent_id_index` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='部门表';

CREATE TABLE `{{prefix}}role_belongs_department` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `role_id` bigint NOT NULL COMMENT '角色id',
  `dept_id` bigint NOT NULL COMMENT '部门id',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_rbd_role_id` (`role_id`),
  KEY `idx_rbd_dept_id` (`dept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色部门关联表（用于自定义数据权限）';

SET FOREIGN_KEY_CHECKS = 1;
