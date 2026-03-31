-- 自 server/plugin/ds/sysKefu/database/seeders/Data.php（kefu_config 分组与 system_config 项）
-- 依赖 ds/sysConfig 的 system_config 表结构；与同目录 2025_12_30_data.sql 分离：凡 system_config_group / system_config 均放 _config.sql
-- 凡 INSERT 均带 NOT EXISTS：对应 code / (group_code,key) 已存在则跳过，不覆盖已有数据

SET NAMES utf8mb4;

INSERT INTO `{{prefix}}system_config_group` (`name`, `code`, `icon`, `created_at`, `updated_at`)
SELECT CAST('[{"lang": "zh_CN", "text": "客服配置"}, {"lang": "en", "text": "customer service"}]' AS JSON), 'kefu_config', 'ri:customer-service-2-line', NOW(), NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}system_config_group` g WHERE g.code = 'kefu_config' LIMIT 1);

INSERT INTO `{{prefix}}system_config` (`group_code`, `key`, `value`, `name`, `input_type`, `config_select_data`, `sort`, `remark`, `created_at`, `updated_at`)
SELECT 'kefu_config', 'auto_reply_enabled', CAST('"1"' AS JSON), CAST('[{"lang": "zh_CN", "text": "是否启用自动回复"}, {"lang": "en", "text": "Do you want to enable automatic replies"}]' AS JSON), 'input', CAST('[]' AS JSON), 99, NULL, NOW(), NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}system_config` c WHERE c.group_code = 'kefu_config' AND c.key = 'auto_reply_enabled' LIMIT 1);

INSERT INTO `{{prefix}}system_config` (`group_code`, `key`, `value`, `name`, `input_type`, `config_select_data`, `sort`, `remark`, `created_at`, `updated_at`)
SELECT 'kefu_config', 'work_time_start', CAST('"09:00"' AS JSON), CAST('[{"lang": "zh_CN", "text": "工作时间开始"}, {"lang": "en", "text": "Starting working hours "}]' AS JSON), 'input', CAST('[]' AS JSON), 98, NULL, NOW(), NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}system_config` c WHERE c.group_code = 'kefu_config' AND c.key = 'work_time_start' LIMIT 1);

INSERT INTO `{{prefix}}system_config` (`group_code`, `key`, `value`, `name`, `input_type`, `config_select_data`, `sort`, `remark`, `created_at`, `updated_at`)
SELECT 'kefu_config', 'work_time_end', CAST('"22:00"' AS JSON), CAST('[{"lang": "zh_CN", "text": "工作时间结束"}, {"lang": "en", "text": "End of working hours"}]' AS JSON), 'input', CAST('[]' AS JSON), 97, NULL, NOW(), NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}system_config` c WHERE c.group_code = 'kefu_config' AND c.key = 'work_time_end' LIMIT 1);

INSERT INTO `{{prefix}}system_config` (`group_code`, `key`, `value`, `name`, `input_type`, `config_select_data`, `sort`, `remark`, `created_at`, `updated_at`)
SELECT 'kefu_config', 'auto_reply_delay', CAST('"1"' AS JSON), CAST('[{"lang": "zh_CN", "text": "自动回复延迟秒数（模拟真人）"}, {"lang": "en", "text": "Automatic reply delay in seconds (simulating a real person)"}]' AS JSON), 'input', CAST('[]' AS JSON), 96, NULL, NOW(), NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}system_config` c WHERE c.group_code = 'kefu_config' AND c.key = 'auto_reply_delay' LIMIT 1);

INSERT INTO `{{prefix}}system_config` (`group_code`, `key`, `value`, `name`, `input_type`, `config_select_data`, `sort`, `remark`, `created_at`, `updated_at`)
SELECT 'kefu_config', 'auto_reply_throttle', CAST('"30"' AS JSON), CAST('[{"lang": "zh_CN", "text": "同一会话同一规则触发间隔（秒）"}, {"lang": "en", "text": "Same session, same rule trigger interval (seconds)"}]' AS JSON), 'input', CAST('[]' AS JSON), 96, NULL, NOW(), NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}system_config` c WHERE c.group_code = 'kefu_config' AND c.key = 'auto_reply_throttle' LIMIT 1);

INSERT INTO `{{prefix}}system_config` (`group_code`, `key`, `value`, `name`, `input_type`, `config_select_data`, `sort`, `remark`, `created_at`, `updated_at`)
SELECT 'kefu_config', 'welcome_message', CAST('"zh_CN"' AS JSON), CAST('[{"lang": "zh_CN", "text": "欢迎语"}, {"lang": "en", "text": "Welcome message"}]' AS JSON), 'keyValuePair', CAST('[{"label": "您好！我是智能客服小助手，很高兴为您服务。请问有什么可以帮助您的？", "value": "zh_CN"}, {"label": "Hello! I am your AI customer service assistant. How may I help you today?", "value": "en"}]' AS JSON), 95, NULL, NOW(), NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}system_config` c WHERE c.group_code = 'kefu_config' AND c.key = 'welcome_message' LIMIT 1);

INSERT INTO `{{prefix}}system_config` (`group_code`, `key`, `value`, `name`, `input_type`, `config_select_data`, `sort`, `remark`, `created_at`, `updated_at`)
SELECT 'kefu_config', 'offline_message', CAST('"zh_CN"' AS JSON), CAST('[{"lang": "zh_CN", "text": "离线提示语"}, {"lang": "en", "text": "Offline prompt lang"}]' AS JSON), 'keyValuePair', CAST('[{"label": "抱歉，当前为非工作时间（09:00-22:00），请留言或稍后再试。", "value": "zh_CN"}, {"label": "Sorry, we are currently offline (working hours: 09:00-22:00). Please leave a message or try again later.", "value": "en"}]' AS JSON), 94, NULL, NOW(), NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}system_config` c WHERE c.group_code = 'kefu_config' AND c.key = 'offline_message' LIMIT 1);
