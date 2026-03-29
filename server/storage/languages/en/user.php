<?php

declare(strict_types=1);

return [
    'id' => 'User ID, primary key',
    'username' => 'Username',
    'user_type' => 'User type: (100 system users)',
    'nickname' => 'User nickname',
    'phone' => 'Phone',
    'email' => 'User Email',
    'avatar' => 'User avatar',
    'signed' => 'Personal signature',
    'dashboard' => 'Backstage Home Type',
    'status' => 'Status (1 normal 2 deactivated)',
    'code' => 'Mobile area code',
    'mobile' => 'Login mobile',
    'invite_code' => 'Invite code',
    'google2fa' => 'Google2FA secret key',
    'login_ip' => 'Last login IP',
    'login_time' => 'Last login time',
    'backend_setting' => 'Background settings data',
    'created_by' => 'Creator',
    'updated_by' => 'Updater',
    'created_at' => 'Creation time',
    'updated_at' => 'Update time',
    'remark' => 'Remark',
    'username_exist' => 'Username already exists',
    'enums' => [
        'type' => [
            100 => 'System user',
            200 => 'Normal user',
        ],
        'status' => [
            1 => 'Normal',
            2 => 'Deactivated',
        ],
    ],
    'vcode' => 'Verification code',
    'vcode_invalid' => 'Verification code error',
    'password' => 'Password',
    'password_error' => 'Password error',
    'old_password_error' => 'Old password error',
    'old_password' => 'Old password',
    'password_confirmation' => 'Confirm password',
    'password_change_success' => 'Reset password success',
    'disable' => 'Account deactivated',
];
