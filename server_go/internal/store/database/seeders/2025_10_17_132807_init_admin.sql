-- 对齐原 PHP 初始化：admin 用户、SuperAdmin 角色、用户-角色关联、Casbin g（admin -> superAdmin）
-- 密码明文 123456，bcrypt（cost=10）
-- 执行：migrate seed internal/store/database（须已 migrate up）

INSERT INTO `{{prefix}}user` (`username`, `email`, `code`, `mobile`, `password`, `user_type`, `status`, `remark`, `created_at`, `updated_at`)
VALUES (
  'admin',
  '649909457@qq.com',
  NULL,
  NULL,
  '$2a$10$6qLdTaexyoQHPfVeK9FZm.HmaZdkB86/cGmJsC550jUu6cG5MSwV6',
  '100',
  1,
  '',
  NOW(),
  NOW()
)
ON DUPLICATE KEY UPDATE
  `email` = VALUES(`email`),
  `password` = VALUES(`password`),
  `user_type` = VALUES(`user_type`),
  `status` = VALUES(`status`),
  `updated_at` = VALUES(`updated_at`);

INSERT INTO `{{prefix}}role` (`name`, `code`, `data_scope`, `status`, `sort`, `remark`, `created_at`, `updated_at`)
VALUES ('超级管理员', 'SuperAdmin', 5, 1, 0, '', NOW(), NOW())
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`),
  `data_scope` = VALUES(`data_scope`),
  `status` = VALUES(`status`),
  `updated_at` = VALUES(`updated_at`);

INSERT INTO `{{prefix}}user_belongs_role` (`user_id`, `role_id`)
SELECT u.id, r.id
FROM `{{prefix}}user` u
CROSS JOIN `{{prefix}}role` r
WHERE u.username = 'admin' AND r.code = 'SuperAdmin'
  AND NOT EXISTS (
    SELECT 1 FROM `{{prefix}}user_belongs_role` ur
    WHERE ur.user_id = u.id AND ur.role_id = r.id
  );

INSERT INTO `{{prefix}}rules` (`ptype`, `v0`, `v1`, `created_at`, `updated_at`)
SELECT 'g', 'admin', 'superAdmin', NOW(), NOW()
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `{{prefix}}rules` t
  WHERE t.`ptype` = 'g' AND t.`v0` = 'admin' AND t.`v1` = 'superAdmin'
  LIMIT 1
);
