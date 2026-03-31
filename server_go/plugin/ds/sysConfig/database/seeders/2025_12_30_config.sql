-- 自 server/plugin/ds/sysConfig/database/seeders/Data.php（name JSON 已修正为合法数组）
-- 文件命名：YYYY_MM_DD_config.sql（system_config / system_config_group）；本文件先于同目录 _menu.sql 执行
-- 凡 INSERT 均带 NOT EXISTS：对应 code / (group_code,key) 已存在则跳过，不覆盖已有数据

SET NAMES utf8mb4;

INSERT INTO `{{prefix}}system_config_group` (`name`, `code`, `icon`, `created_at`, `updated_at`)
SELECT
  CAST('[{"lang": "zh_CN", "text": "存储设置"}, {"lang": "en", "text": "save setting"}]' AS JSON),
  'sys_storage',
  'ri:folder-history-fill',
  NOW(),
  NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}system_config_group` g WHERE g.code = 'sys_storage' LIMIT 1);

INSERT INTO `{{prefix}}system_config` (`group_code`, `key`, `value`, `name`, `input_type`, `config_select_data`, `sort`, `remark`, `created_at`, `updated_at`)
SELECT 'sys_storage', 'storage_mode', CAST('"local"' AS JSON), CAST('[{"lang": "zh_CN", "text": "存储方式"}]' AS JSON), 'select',
  CAST('[{"label": "本地", "value": "local"}, {"label": "七牛云", "value": "qiniu"}, {"label": "阿里云", "value": "oss"}, {"label": "腾讯云", "value": "cos"}]' AS JSON), 100, NULL, NOW(), NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}system_config` c WHERE c.group_code = 'sys_storage' AND c.key = 'storage_mode' LIMIT 1);

INSERT INTO `{{prefix}}system_config` (`group_code`, `key`, `value`, `name`, `input_type`, `config_select_data`, `sort`, `remark`, `created_at`, `updated_at`)
SELECT 'sys_storage', 'oss_access_id', NULL, CAST('[{"lang": "zh_CN", "text": "阿里云_access_id"}]' AS JSON), 'input', CAST('[]' AS JSON), 99, NULL, NOW(), NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}system_config` c WHERE c.group_code = 'sys_storage' AND c.key = 'oss_access_id' LIMIT 1);

INSERT INTO `{{prefix}}system_config` (`group_code`, `key`, `value`, `name`, `input_type`, `config_select_data`, `sort`, `remark`, `created_at`, `updated_at`)
SELECT 'sys_storage', 'oss_access_secret', NULL, CAST('[{"lang": "zh_CN", "text": "阿里云access_secret"}]' AS JSON), 'input', CAST('[]' AS JSON), 98, NULL, NOW(), NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}system_config` c WHERE c.group_code = 'sys_storage' AND c.key = 'oss_access_secret' LIMIT 1);

INSERT INTO `{{prefix}}system_config` (`group_code`, `key`, `value`, `name`, `input_type`, `config_select_data`, `sort`, `remark`, `created_at`, `updated_at`)
SELECT 'sys_storage', 'oss_bucket', NULL, CAST('[{"lang": "zh_CN", "text": "阿里云bucket"}]' AS JSON), 'input', CAST('[]' AS JSON), 97, NULL, NOW(), NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}system_config` c WHERE c.group_code = 'sys_storage' AND c.key = 'oss_bucket' LIMIT 1);

INSERT INTO `{{prefix}}system_config` (`group_code`, `key`, `value`, `name`, `input_type`, `config_select_data`, `sort`, `remark`, `created_at`, `updated_at`)
SELECT 'sys_storage', 'oss_endpoint', NULL, CAST('[{"lang": "zh_CN", "text": "阿里云endpoint"}]' AS JSON), 'input', CAST('[]' AS JSON), 96, NULL, NOW(), NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}system_config` c WHERE c.group_code = 'sys_storage' AND c.key = 'oss_endpoint' LIMIT 1);

INSERT INTO `{{prefix}}system_config` (`group_code`, `key`, `value`, `name`, `input_type`, `config_select_data`, `sort`, `remark`, `created_at`, `updated_at`)
SELECT 'sys_storage', 'oss_domain', NULL, CAST('[{"lang": "zh_CN", "text": "阿里云domain"}]' AS JSON), 'input', CAST('[]' AS JSON), 95, NULL, NOW(), NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}system_config` c WHERE c.group_code = 'sys_storage' AND c.key = 'oss_domain' LIMIT 1);

INSERT INTO `{{prefix}}system_config` (`group_code`, `key`, `value`, `name`, `input_type`, `config_select_data`, `sort`, `remark`, `created_at`, `updated_at`)
SELECT 'sys_storage', 'qiniu_access_key', NULL, CAST('[{"lang": "zh_CN", "text": "七牛access_key"}]' AS JSON), 'input', CAST('[]' AS JSON), 89, NULL, NOW(), NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}system_config` c WHERE c.group_code = 'sys_storage' AND c.key = 'qiniu_access_key' LIMIT 1);

INSERT INTO `{{prefix}}system_config` (`group_code`, `key`, `value`, `name`, `input_type`, `config_select_data`, `sort`, `remark`, `created_at`, `updated_at`)
SELECT 'sys_storage', 'qiniu_secret_key', NULL, CAST('[{"lang": "zh_CN", "text": "七牛secret_key"}]' AS JSON), 'input', CAST('[]' AS JSON), 88, NULL, NOW(), NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}system_config` c WHERE c.group_code = 'sys_storage' AND c.key = 'qiniu_secret_key' LIMIT 1);

INSERT INTO `{{prefix}}system_config` (`group_code`, `key`, `value`, `name`, `input_type`, `config_select_data`, `sort`, `remark`, `created_at`, `updated_at`)
SELECT 'sys_storage', 'qiniu_bucket', NULL, CAST('[{"lang": "zh_CN", "text": "七牛bucket"}]' AS JSON), 'input', CAST('[]' AS JSON), 87, NULL, NOW(), NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}system_config` c WHERE c.group_code = 'sys_storage' AND c.key = 'qiniu_bucket' LIMIT 1);

INSERT INTO `{{prefix}}system_config` (`group_code`, `key`, `value`, `name`, `input_type`, `config_select_data`, `sort`, `remark`, `created_at`, `updated_at`)
SELECT 'sys_storage', 'qiniu_domain', NULL, CAST('[{"lang": "zh_CN", "text": "七牛domain"}]' AS JSON), 'input', CAST('[]' AS JSON), 86, NULL, NOW(), NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}system_config` c WHERE c.group_code = 'sys_storage' AND c.key = 'qiniu_domain' LIMIT 1);

INSERT INTO `{{prefix}}system_config` (`group_code`, `key`, `value`, `name`, `input_type`, `config_select_data`, `sort`, `remark`, `created_at`, `updated_at`)
SELECT 'sys_storage', 'cos_app_id', NULL, CAST('[{"lang": "zh_CN", "text": "腾讯云app_id"}]' AS JSON), 'input', CAST('[]' AS JSON), 79, NULL, NOW(), NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}system_config` c WHERE c.group_code = 'sys_storage' AND c.key = 'cos_app_id' LIMIT 1);

INSERT INTO `{{prefix}}system_config` (`group_code`, `key`, `value`, `name`, `input_type`, `config_select_data`, `sort`, `remark`, `created_at`, `updated_at`)
SELECT 'sys_storage', 'cos_secret_id', NULL, CAST('[{"lang": "zh_CN", "text": "腾讯云secret_id"}]' AS JSON), 'input', CAST('[]' AS JSON), 78, NULL, NOW(), NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}system_config` c WHERE c.group_code = 'sys_storage' AND c.key = 'cos_secret_id' LIMIT 1);

INSERT INTO `{{prefix}}system_config` (`group_code`, `key`, `value`, `name`, `input_type`, `config_select_data`, `sort`, `remark`, `created_at`, `updated_at`)
SELECT 'sys_storage', 'cos_secret_key', NULL, CAST('[{"lang": "zh_CN", "text": "腾讯云secret_key"}]' AS JSON), 'input', CAST('[]' AS JSON), 77, NULL, NOW(), NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}system_config` c WHERE c.group_code = 'sys_storage' AND c.key = 'cos_secret_key' LIMIT 1);

INSERT INTO `{{prefix}}system_config` (`group_code`, `key`, `value`, `name`, `input_type`, `config_select_data`, `sort`, `remark`, `created_at`, `updated_at`)
SELECT 'sys_storage', 'cos_bucket', NULL, CAST('[{"lang": "zh_CN", "text": "腾讯云bucket"}]' AS JSON), 'input', CAST('[]' AS JSON), 76, NULL, NOW(), NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}system_config` c WHERE c.group_code = 'sys_storage' AND c.key = 'cos_bucket' LIMIT 1);

INSERT INTO `{{prefix}}system_config` (`group_code`, `key`, `value`, `name`, `input_type`, `config_select_data`, `sort`, `remark`, `created_at`, `updated_at`)
SELECT 'sys_storage', 'cos_domain', NULL, CAST('[{"lang": "zh_CN", "text": "腾讯云domain"}]' AS JSON), 'input', CAST('[]' AS JSON), 75, NULL, NOW(), NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}system_config` c WHERE c.group_code = 'sys_storage' AND c.key = 'cos_domain' LIMIT 1);

INSERT INTO `{{prefix}}system_config` (`group_code`, `key`, `value`, `name`, `input_type`, `config_select_data`, `sort`, `remark`, `created_at`, `updated_at`)
SELECT 'sys_storage', 'cos_region', NULL, CAST('[{"lang": "zh_CN", "text": "腾讯云region"}]' AS JSON), 'input', CAST('[]' AS JSON), 74, NULL, NOW(), NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}system_config` c WHERE c.group_code = 'sys_storage' AND c.key = 'cos_region' LIMIT 1);
