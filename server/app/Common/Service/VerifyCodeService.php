<?php
/**
 * FastApp.
 * 统一验证码服务
 * 支持手机短信和邮箱验证码，支持场景定义
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

declare(strict_types=1);

namespace App\Common\Service;

use App\Common\Tools;
use Hyperf\Context\ApplicationContext;
use Hyperf\Redis\Redis;
use Overtrue\EasySms\EasySms;
use Overtrue\EasySms\PhoneNumber;
use Overtrue\EasySms\Strategies\OrderStrategy;
use Plugin\Ds\SystemConfig\Helper\CacheConfig;

class VerifyCodeService
{
    /**
     * 验证码类型：手机短信
     */
    public const TYPE_SMS = 'sms';

    /**
     * 验证码类型：邮箱
     */
    public const TYPE_EMAIL = 'email';

    /**
     * 默认场景
     */
    public const SCENE_DEFAULT = 'default';

    /**
     * 登录场景
     */
    public const SCENE_LOGIN = 'login';

    /**
     * 注册场景
     */
    public const SCENE_REGISTER = 'register';

    /**
     * 找回密码场景
     */
    public const SCENE_RESET_PASSWORD = 'reset_password';

    /**
     * 绑定手机/邮箱场景
     */
    public const SCENE_BIND = 'bind';

    /**
     * 修改手机/邮箱场景
     */
    public const SCENE_CHANGE = 'change';

    /**
     * 默认验证码长度
     */
    protected const DEFAULT_CODE_LENGTH = 6;

    /**
     * 默认验证码有效期（秒）
     */
    protected const DEFAULT_TTL = 600; // 10分钟

    /**
     * 默认发送间隔（秒）
     */
    protected const DEFAULT_INTERVAL = 60; // 1分钟

    /**
     * 发送验证码
     *
     * @param string $type 验证码类型：sms（手机短信）或 email（邮箱）
     * @param string $target 目标地址：手机号或邮箱地址
     * @param string $scene 使用场景，如：login, register, reset_password 等
     * @param int $codeLength 验证码长度，默认6位
     * @param int $ttl 验证码有效期（秒），默认600秒（10分钟）
     * @param int $interval 发送间隔（秒），默认60秒
     * @param int $countryCode 国家代码（仅手机短信需要），默认86
     * @return array 返回结果 ['success' => bool, 'message' => string, 'code' => string|null]
     */
    public static function send(
        string $type,
        string $target,
        string $scene = self::SCENE_DEFAULT,
        int $codeLength = self::DEFAULT_CODE_LENGTH,
        int $ttl = self::DEFAULT_TTL,
        int $interval = self::DEFAULT_INTERVAL,
        int $countryCode = 86
    ): array {
        // 开发环境直接返回成功
        if (config('env') == 'dev') {
            return [
                'success' => true,
                'message' => '验证码发送成功（开发环境）',
                'code' => '123456',
            ];
        }

        // 验证目标地址格式
        if ($type === self::TYPE_SMS) {
            if (!self::validateMobile($target)) {
                return [
                    'success' => false,
                    'message' => '手机号格式不正确',
                    'code' => null,
                ];
            }
        } elseif ($type === self::TYPE_EMAIL) {
            if (!self::validateEmail($target)) {
                return [
                    'success' => false,
                    'message' => '邮箱格式不正确',
                    'code' => null,
                ];
            }
        } else {
            return [
                'success' => false,
                'message' => '不支持的验证码类型',
                'code' => null,
            ];
        }

        // 生成缓存键
        $cacheKey = self::getCacheKey($type, $target, $scene, $countryCode);
        $redis = ApplicationContext::getContainer()->get(Redis::class);

        // 检查发送间隔（只有验证码存在且未过期时才检查）
        $ttlRemaining = (int)$redis->ttl($cacheKey);
        if ($ttlRemaining > 0) {
            $elapsed = $ttl - $ttlRemaining; // 已过去的时间
            if ($elapsed < $interval) {
                $waitTime = $interval - $elapsed;
                return [
                    'success' => false,
                    'message' => "发送过于频繁，请 {$waitTime} 秒后再试",
                    'code' => null,
                ];
            }
        }

        // 生成验证码
        $code = self::generateCode($codeLength);

        // 保存验证码到Redis
        $redis->setex($cacheKey, $ttl, $code);

        // 发送验证码
        $sendResult = false;
        if ($type === self::TYPE_SMS) {
            $sendResult = self::sendSms($target, $code, $countryCode);
        } elseif ($type === self::TYPE_EMAIL) {
            $sendResult = self::sendEmail($target, $code, $scene);
        }

        if (!$sendResult) {
            // 发送失败，删除已保存的验证码
            $redis->del($cacheKey);
            return [
                'success' => false,
                'message' => '验证码发送失败，请稍后重试',
                'code' => null,
            ];
        }

        return [
            'success' => true,
            'message' => '验证码发送成功',
            'code' => null, // 生产环境不返回验证码
        ];
    }

    /**
     * 验证验证码
     *
     * @param string $type 验证码类型：sms 或 email
     * @param string $target 目标地址：手机号或邮箱地址
     * @param string $code 用户输入的验证码
     * @param string $scene 使用场景，必须与发送时一致
     * @param bool $clean 验证成功后是否删除验证码，默认true
     * @param int $countryCode 国家代码（仅手机短信需要），默认86
     * @return bool 验证是否成功
     */
    public static function verify(
        string $type,
        string $target,
        string $code,
        string $scene = self::SCENE_DEFAULT,
        bool $clean = true,
        int $countryCode = 86
    ): bool {
        // 开发环境直接返回成功
        if (config('env') == 'dev') {
            return true;
        }

        if (empty($code)) {
            return false;
        }

        $cacheKey = self::getCacheKey($type, $target, $scene, $countryCode);
        $redis = ApplicationContext::getContainer()->get(Redis::class);
        $storedCode = $redis->get($cacheKey);

        if ($storedCode && $storedCode === $code) {
            if ($clean) {
                $redis->del($cacheKey);
            }
            return true;
        }

        return false;
    }

    /**
     * 发送手机短信验证码
     *
     * @param string $mobile 手机号
     * @param string $code 验证码
     * @param int $countryCode 国家代码
     * @return bool 是否发送成功
     */
    protected static function sendSms(string $mobile, string $code, int $countryCode = 86): bool
    {
        try {
            $config = CacheConfig::getConfigByGroupKey('sms')->pluck('value', 'key');
            $gateways = [
                'errorlog' => [
                    'file' => BASE_PATH . '/runtime/sms.log',
                ],
            ];

            $data = [
                'data' => [$code],
                'template' => $config['template_id_verify'] ?? '',
            ];

            if ($config['platform'] == 'tencent') {
                $gateways = array_merge($gateways, [
                    'qcloud' => [
                        'sdk_app_id' => $config['sdk_app_id'] ?? '',
                        'secret_id' => $config['secret_id'] ?? '',
                        'secret_key' => $config['secret_key'] ?? '',
                        'sign_name' => $config['sign_name'] ?? '',
                    ],
                ]);
            }

            $easySmsConfig = [
                'timeout' => 5.0,
                'default' => [
                    'strategy' => OrderStrategy::class,
                    'gateways' => ['qcloud'],
                ],
                'gateways' => $gateways,
            ];

            $easySms = new EasySms($easySmsConfig);
            $mobileNumber = new PhoneNumber((int)$mobile, (string)$countryCode);
            $easySms->send($mobileNumber, $data);

            return true;
        } catch (\Throwable $e) {
            Tools::logAsync('SMS send failed: ' . $e->getMessage(), 'error', 'sms');
            return false;
        }
    }

    /**
     * 发送邮箱验证码
     *
     * @param string $email 邮箱地址
     * @param string $code 验证码
     * @param string $scene 使用场景
     * @return bool 是否发送成功
     */
    protected static function sendEmail(string $email, string $code, string $scene): bool
    {
        try {
            // 获取场景对应的邮件模板内容
            $subject = self::getEmailSubject($scene);
            $content = self::getEmailContent($scene, $code);

            // 尝试从系统配置获取邮件配置
            $emailConfig = CacheConfig::getConfigByGroupKey('email')->pluck('value', 'key') ?? [];

            // 如果配置了邮件服务，使用配置的服务发送
            if (!empty($emailConfig['enabled']) && $emailConfig['enabled'] == '1') {
                return self::sendEmailViaService($email, $subject, $content, $emailConfig);
            }

            // 未配置邮件服务时，记录日志（开发环境）
            Tools::logAsync("Email verify code for {$email} (scene: {$scene}): {$code}", 'info', 'email');
            return true;
        } catch (\Throwable $e) {
            Tools::logAsync('Email send failed: ' . $e->getMessage(), 'error', 'email');
            return false;
        }
    }

    /**
     * 通过邮件服务发送邮件
     *
     * @param string $email 邮箱地址
     * @param string $subject 邮件主题
     * @param string $content 邮件内容
     * @param array $config 邮件配置
     * @return bool 是否发送成功
     */
    protected static function sendEmailViaService(string $email, string $subject, string $content, array $config): bool
    {
        try {
            $platform = $config['platform'] ?? 'smtp';

            switch ($platform) {
                case 'smtp':
                    return self::sendEmailViaSmtp($email, $subject, $content, $config);
                case 'aliyun':
                    return self::sendEmailViaAliyun($email, $subject, $content, $config);
                case 'tencent':
                    return self::sendEmailViaTencent($email, $subject, $content, $config);
                default:
                    Tools::logAsync("Unsupported email platform: {$platform}", 'warning', 'email');
                    return false;
            }
        } catch (\Throwable $e) {
            Tools::logAsync('Email service send failed: ' . $e->getMessage(), 'error', 'email');
            return false;
        }
    }

    /**
     * 通过SMTP发送邮件
     *
     * @param string $email 邮箱地址
     * @param string $subject 邮件主题
     * @param string $content 邮件内容
     * @param array $config SMTP配置
     * @return bool 是否发送成功
     */
    protected static function sendEmailViaSmtp(string $email, string $subject, string $content, array $config): bool
    {
        // TODO: 实现SMTP邮件发送
        // 可以使用 PHPMailer 或 SwiftMailer
        Tools::logAsync("SMTP email send to {$email}: {$subject}", 'info', 'email');
        return true;
    }

    /**
     * 通过阿里云邮件推送发送
     *
     * @param string $email 邮箱地址
     * @param string $subject 邮件主题
     * @param string $content 邮件内容
     * @param array $config 阿里云配置
     * @return bool 是否发送成功
     */
    protected static function sendEmailViaAliyun(string $email, string $subject, string $content, array $config): bool
    {
        // TODO: 实现阿里云邮件推送
        Tools::logAsync("Aliyun email send to {$email}: {$subject}", 'info', 'email');
        return true;
    }

    /**
     * 通过腾讯云邮件发送
     *
     * @param string $email 邮箱地址
     * @param string $subject 邮件主题
     * @param string $content 邮件内容
     * @param array $config 腾讯云配置
     * @return bool 是否发送成功
     */
    protected static function sendEmailViaTencent(string $email, string $subject, string $content, array $config): bool
    {
        // TODO: 实现腾讯云邮件发送
        Tools::logAsync("Tencent email send to {$email}: {$subject}", 'info', 'email');
        return true;
    }

    /**
     * 生成验证码
     *
     * @param int $length 验证码长度
     * @return string 验证码
     */
    protected static function generateCode(int $length = self::DEFAULT_CODE_LENGTH): string
    {
        $min = pow(10, $length - 1);
        $max = pow(10, $length) - 1;
        return (string)random_int($min, $max);
    }

    /**
     * 获取缓存键
     *
     * @param string $type 验证码类型
     * @param string $target 目标地址
     * @param string $scene 使用场景
     * @param int $countryCode 国家代码
     * @return string 缓存键
     */
    protected static function getCacheKey(string $type, string $target, string $scene, int $countryCode): string
    {
        $prefix = $type === self::TYPE_SMS ? 'sms' : 'email';
        $key = $type === self::TYPE_SMS ? "{$prefix}:{$scene}:{$countryCode}:{$target}" : "{$prefix}:{$scene}:{$target}";
        return $key;
    }

    /**
     * 验证手机号格式
     *
     * @param string $mobile 手机号
     * @return bool 是否有效
     */
    protected static function validateMobile(string $mobile): bool
    {
        // 简单的手机号验证，可根据实际需求调整
        return preg_match('/^1[3-9]\d{9}$/', $mobile) === 1;
    }

    /**
     * 验证邮箱格式
     *
     * @param string $email 邮箱地址
     * @return bool 是否有效
     */
    protected static function validateEmail(string $email): bool
    {
        return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
    }

    /**
     * 获取邮件主题
     *
     * @param string $scene 使用场景
     * @return string 邮件主题
     */
    protected static function getEmailSubject(string $scene): string
    {
        $subjects = [
            self::SCENE_LOGIN => '登录验证码',
            self::SCENE_REGISTER => '注册验证码',
            self::SCENE_RESET_PASSWORD => '找回密码验证码',
            self::SCENE_BIND => '绑定验证码',
            self::SCENE_CHANGE => '修改验证码',
            self::SCENE_DEFAULT => '验证码',
        ];

        return $subjects[$scene] ?? '验证码';
    }

    /**
     * 获取邮件内容
     *
     * @param string $scene 使用场景
     * @param string $code 验证码
     * @return string 邮件内容
     */
    protected static function getEmailContent(string $scene, string $code): string
    {
        $templates = [
            self::SCENE_LOGIN => "您的登录验证码是：{$code}，有效期10分钟，请勿泄露给他人。",
            self::SCENE_REGISTER => "您的注册验证码是：{$code}，有效期10分钟，请勿泄露给他人。",
            self::SCENE_RESET_PASSWORD => "您的找回密码验证码是：{$code}，有效期10分钟，请勿泄露给他人。",
            self::SCENE_BIND => "您的绑定验证码是：{$code}，有效期10分钟，请勿泄露给他人。",
            self::SCENE_CHANGE => "您的修改验证码是：{$code}，有效期10分钟，请勿泄露给他人。",
            self::SCENE_DEFAULT => "您的验证码是：{$code}，有效期10分钟，请勿泄露给他人。",
        ];

        return $templates[$scene] ?? "您的验证码是：{$code}，有效期10分钟，请勿泄露给他人。";
    }

    /**
     * 检查验证码是否存在且未过期
     *
     * @param string $type 验证码类型
     * @param string $target 目标地址
     * @param string $scene 使用场景
     * @param int $countryCode 国家代码
     * @return bool 是否存在且未过期
     */
    public static function exists(string $type, string $target, string $scene = self::SCENE_DEFAULT, int $countryCode = 86): bool
    {
        $cacheKey = self::getCacheKey($type, $target, $scene, $countryCode);
        $redis = ApplicationContext::getContainer()->get(Redis::class);
        return $redis->exists($cacheKey) > 0;
    }

    /**
     * 获取验证码剩余有效时间（秒）
     *
     * @param string $type 验证码类型
     * @param string $target 目标地址
     * @param string $scene 使用场景
     * @param int $countryCode 国家代码
     * @return int 剩余时间（秒），-1表示不存在，-2表示永久有效
     */
    public static function getRemainingTime(string $type, string $target, string $scene = self::SCENE_DEFAULT, int $countryCode = 86): int
    {
        $cacheKey = self::getCacheKey($type, $target, $scene, $countryCode);
        $redis = ApplicationContext::getContainer()->get(Redis::class);
        return (int)$redis->ttl($cacheKey);
    }

    /**
     * 删除验证码
     *
     * @param string $type 验证码类型
     * @param string $target 目标地址
     * @param string $scene 使用场景
     * @param int $countryCode 国家代码
     * @return bool 是否删除成功
     */
    public static function delete(string $type, string $target, string $scene = self::SCENE_DEFAULT, int $countryCode = 86): bool
    {
        $cacheKey = self::getCacheKey($type, $target, $scene, $countryCode);
        $redis = ApplicationContext::getContainer()->get(Redis::class);
        return $redis->del($cacheKey) > 0;
    }
}

