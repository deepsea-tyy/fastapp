<?php

declare(strict_types=1);

return [
    'id' => '用戶ID，主鍵',
    'username' => '用戶名',
    'user_type' => '用戶類型：(100系統用戶)',
    'nickname' => '用戶暱稱',
    'phone' => '手機',
    'email' => '用戶郵箱',
    'avatar' => '用戶頭像',
    'signed' => '個人簽名',
    'dashboard' => '後台首頁類型',
    'status' => '狀態 (1正常 2停用)',
    'code' => '手機號區號',
    'mobile' => '登錄手機號',
    'invite_code' => '邀請碼',
    'google2fa' => 'Google2FA密鑰',
    'login_ip' => '最後登錄IP',
    'login_time' => '最後登錄時間',
    'backend_setting' => '後台設置數據',
    'created_by' => '創建者',
    'updated_by' => '更新者',
    'created_at' => '創建時間',
    'updated_at' => '更新時間',
    'remark' => '備註',
    'username_exist' => '用戶名已存在',
    'enums' => [
        'type' => [
            100 => '系統用戶',
            200 => '普通用戶',
        ],
        'status' => [
            1 => '正常',
            2 => '停用',
        ],
    ],
    'vcode' => '驗證碼',
    'password' => '密碼',
    'password_error' => '密碼錯誤',
    'disable' => '賬號已停用',
    'old_password_error' => '舊密碼錯誤',
    'old_password' => '舊密碼',
    'password_confirmation' => '確認密碼',
    'password_change_success' => '重置密碼成功',
];
