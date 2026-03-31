-- App 页面内容种子（login + 原 PHP menu_sys_cms 中的首页导航）
-- login：根据 app/lib/presentation/views/user/login.dart

SET NAMES utf8mb4;

INSERT INTO `{{prefix}}app_page_content` (`code`, `page_code`, `component_code`, `content_type`, `data`, `platform`, `start_at`, `end_at`, `fixed`, `status`, `sort`, `remark`, `created_by`, `updated_by`, `created_at`, `updated_at`) VALUES
(
  'home.navIcon',
  'home',
  NULL,
  1,
  CAST('[{"icon": "", "label": "c2c买币"}]' AS JSON),
  3,
  NULL,
  NULL,
  1,
  1,
  100,
  '首页导航快捷图标',
  1,
  NULL,
  NOW(),
  NOW()
)
ON DUPLICATE KEY UPDATE
  `page_code` = VALUES(`page_code`),
  `component_code` = VALUES(`component_code`),
  `content_type` = VALUES(`content_type`),
  `data` = VALUES(`data`),
  `platform` = VALUES(`platform`),
  `start_at` = VALUES(`start_at`),
  `end_at` = VALUES(`end_at`),
  `fixed` = VALUES(`fixed`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `remark` = VALUES(`remark`),
  `updated_by` = VALUES(`updated_by`),
  `updated_at` = VALUES(`updated_at`);

-- ========== Login 页面 ==========

-- 页面标题
INSERT INTO `{{prefix}}app_page_content` (`code`, `page_code`, `component_code`, `content_type`, `data`, `platform`, `fixed`, `status`, `sort`, `remark`, `created_at`, `updated_at`) VALUES
('login.title', 'login', 'title', 1, '{"zh_CN":"登录","en":"Login"}', 2, 1, 1, 100, '登录页面标题', NOW(), NOW());

-- Tab标签
INSERT INTO `{{prefix}}app_page_content` (`code`, `page_code`, `component_code`, `content_type`, `data`, `platform`, `fixed`, `status`, `sort`, `remark`, `created_at`, `updated_at`) VALUES
('login.tab.phone', 'login', 'tab', 1, '{"zh_CN":"手机号","en":"Phone"}', 2, 1, 1, 101, '手机号Tab标签', NOW(), NOW()),
('login.tab.email', 'login', 'tab', 1, '{"zh_CN":"邮箱","en":"Email"}', 2, 1, 1, 102, '邮箱Tab标签', NOW(), NOW());

-- 切换登录方式按钮
INSERT INTO `{{prefix}}app_page_content` (`code`, `page_code`, `component_code`, `content_type`, `data`, `platform`, `fixed`, `status`, `sort`, `remark`, `created_at`, `updated_at`) VALUES
('login.switch.code', 'login', 'switch_button', 1, '{"zh_CN":"使用验证码登录","en":"Login with Code"}', 2, 1, 1, 103, '切换到验证码登录', NOW(), NOW()),
('login.switch.password', 'login', 'switch_button', 1, '{"zh_CN":"使用密码登录","en":"Login with Password"}', 2, 1, 1, 104, '切换到密码登录', NOW(), NOW());

-- 输入框提示文本
INSERT INTO `{{prefix}}app_page_content` (`code`, `page_code`, `component_code`, `content_type`, `data`, `platform`, `fixed`, `status`, `sort`, `remark`, `created_at`, `updated_at`) VALUES
('login.input.phone.placeholder', 'login', 'input', 1, '{"zh_CN":"请输入手机号码","en":"Please enter phone number"}', 2, 1, 1, 105, '手机号输入框提示', NOW(), NOW()),
('login.input.email.placeholder', 'login', 'input', 1, '{"zh_CN":"请输入邮箱地址","en":"Please enter email address"}', 2, 1, 1, 106, '邮箱输入框提示', NOW(), NOW()),
('login.input.password.placeholder', 'login', 'input', 1, '{"zh_CN":"请输入密码","en":"Please enter password"}', 2, 1, 1, 107, '密码输入框提示', NOW(), NOW()),
('login.input.code.placeholder', 'login', 'input', 1, '{"zh_CN":"请输入验证码","en":"Please enter verification code"}', 2, 1, 1, 108, '验证码输入框提示', NOW(), NOW());

-- 验证码按钮
INSERT INTO `{{prefix}}app_page_content` (`code`, `page_code`, `component_code`, `content_type`, `data`, `platform`, `fixed`, `status`, `sort`, `remark`, `created_at`, `updated_at`) VALUES
('login.button.get_code', 'login', 'button', 1, '{"zh_CN":"获取验证码","en":"Get Code"}', 2, 1, 1, 109, '获取验证码按钮', NOW(), NOW()),
('login.button.retry_code', 'login', 'button', 1, '{"zh_CN":"{count}秒后重试","en":"Retry in {count} seconds"}', 2, 1, 1, 110, '验证码倒计时重试文本（{count}为占位符）', NOW(), NOW());

-- 主要操作按钮
INSERT INTO `{{prefix}}app_page_content` (`code`, `page_code`, `component_code`, `content_type`, `data`, `platform`, `fixed`, `status`, `sort`, `remark`, `created_at`, `updated_at`) VALUES
('login.button.continue', 'login', 'button', 1, '{"zh_CN":"继续","en":"Continue"}', 2, 1, 1, 111, '登录继续按钮', NOW(), NOW());

-- 链接文本
INSERT INTO `{{prefix}}app_page_content` (`code`, `page_code`, `component_code`, `content_type`, `data`, `platform`, `fixed`, `status`, `sort`, `remark`, `created_at`, `updated_at`) VALUES
('login.link.forgot_password', 'login', 'link', 1, '{"zh_CN":"忘记密码","en":"Forgot Password"}', 2, 1, 1, 112, '忘记密码链接', NOW(), NOW()),
('login.link.register', 'login', 'link', 1, '{"zh_CN":"立即注册","en":"Register Now"}', 2, 1, 1, 113, '立即注册链接', NOW(), NOW());

-- 分隔符
INSERT INTO `{{prefix}}app_page_content` (`code`, `page_code`, `component_code`, `content_type`, `data`, `platform`, `fixed`, `status`, `sort`, `remark`, `created_at`, `updated_at`) VALUES
('login.divider.or', 'login', 'divider', 1, '{"zh_CN":"或","en":"Or"}', 2, 1, 1, 114, '分隔符文本', NOW(), NOW());

-- 第三方登录按钮
INSERT INTO `{{prefix}}app_page_content` (`code`, `page_code`, `component_code`, `content_type`, `data`, `platform`, `fixed`, `status`, `sort`, `remark`, `created_at`, `updated_at`) VALUES
('login.button.google', 'login', 'button', 1, '{"zh_CN":"通过 Google 继续","en":"Continue with Google"}', 2, 1, 1, 115, 'Google登录按钮', NOW(), NOW());

-- 错误提示消息
INSERT INTO `{{prefix}}app_page_content` (`code`, `page_code`, `component_code`, `content_type`, `data`, `platform`, `fixed`, `status`, `sort`, `remark`, `created_at`, `updated_at`) VALUES
('login.error.phone_required', 'login', 'error_message', 1, '{"zh_CN":"请输入手机号码","en":"Please enter phone number"}', 2, 1, 1, 116, '手机号必填错误提示', NOW(), NOW()),
('login.error.email_required', 'login', 'error_message', 1, '{"zh_CN":"请输入邮箱地址","en":"Please enter email address"}', 2, 1, 1, 117, '邮箱必填错误提示', NOW(), NOW()),
('login.error.password_required', 'login', 'error_message', 1, '{"zh_CN":"请输入密码","en":"Please enter password"}', 2, 1, 1, 118, '密码必填错误提示', NOW(), NOW()),
('login.error.code_required', 'login', 'error_message', 1, '{"zh_CN":"请输入验证码","en":"Please enter verification code"}', 2, 1, 1, 119, '验证码必填错误提示', NOW(), NOW()),
('login.error.code_send_success', 'login', 'error_message', 1, '{"zh_CN":"验证码发送成功","en":"Verification code sent successfully"}', 2, 1, 1, 120, '验证码发送成功提示', NOW(), NOW()),
('login.error.code_send_failed', 'login', 'error_message', 1, '{"zh_CN":"验证码发送失败","en":"Failed to send verification code"}', 2, 1, 1, 121, '验证码发送失败提示', NOW(), NOW());

