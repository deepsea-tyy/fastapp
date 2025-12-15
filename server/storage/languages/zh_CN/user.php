<?php

declare(strict_types=1);

return [
    'id' => '用户ID，主键',
    'username' => '用户名',
    'user_type' => '用户类型',
    'code' => '手机号区号',
    'mobile' => '登录手机号',
    'email' => '登录邮箱',
    'avatar' => '用户头像',
    'nickname' => '用户昵称',
    'phone' => '联系电话',
    'signed' => '个人签名',
    'dashboard' => '后台首页类型',
    'status' => '状态',
    'invite_code' => '邀请码',
    'google2fa' => 'Google2FA密钥',
    'login_ip' => '最后登录IP',
    'login_time' => '最后登录时间',
    'backend_setting' => '后台设置数据',
    'created_by' => '创建者',
    'updated_by' => '更新者',
    'created_at' => '创建时间',
    'updated_at' => '更新时间',
    'remark' => '备注',
    'username_exist' => '用户名已存在',
    'enums' => [
        'type' => [
            100 => '系统用户',
            200 => '普通用户',
        ],
        'status' => [
            1 => '正常',
            2 => '停用',
        ],
    ],
    'vcode' => '验证码',
    'vcode_invalid' => '验证码错误',
    'password' => '密码',
    'password_error' => '密码错误',
    'old_password_error' => '旧密码错误',
    'old_password' => '旧密码',
    'password_confirmation' => '确认密码',
    'password_change_success' => '重置密码成功',
    'disable' => '账号已停用',
];
