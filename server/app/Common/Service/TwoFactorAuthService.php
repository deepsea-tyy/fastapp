<?php

declare(strict_types=1);

namespace App\Common\Service;

use App\Exception\BusinessException;
use App\Model\User;
use BaconQrCode\Renderer\GDLibRenderer;
use BaconQrCode\Renderer\Image\ImagickImageBackEnd;
use BaconQrCode\Renderer\ImageRenderer;
use BaconQrCode\Renderer\RendererStyle\RendererStyle;
use BaconQrCode\Writer;
use Hyperf\Config\Annotation\Value;
use Plugin\Ds\SysConfig\Helper\CacheConfigHelper;
use PragmaRX\Google2FA\Google2FA;

/**
 * 双因素认证服务
 *
 * 统一管理 Google2FA、邮箱验证码、手机验证码等二次验证逻辑
 */
class TwoFactorAuthService
{
    /**
     * 验证方式常量
     */
    public const VERIFY_TYPE_GOOGLE2FA = 'google2fa_code';
    public const VERIFY_TYPE_EMAIL = 'email_code';
    public const VERIFY_TYPE_MOBILE = 'mobile_code';
    public const VERIFY_TYPE_NONE = '';

    #[Value('env')]
    private string $env = '';

    /**
     * 检测用户需要的二次验证方式
     *
     * 优先级：Google2FA > Email > Mobile > Password
     * 规则：只有当用户拥有多种验证方式时才需要二次验证
     *
     * @param User $user 用户对象
     * @param bool $check2faConfig 是否检查全局2FA配置（默认true）
     * @return array{
     *     verify_again: string,
     *     email?: string,
     *     mobile?: string,
     *     code?: string
     * }
     */
    public function detectVerifyMethod(User $user, bool $check2faConfig = false): array
    {
        $result = [
            'verify_again' => self::VERIFY_TYPE_NONE,
        ];

        // 如果需要检查全局2FA配置 并且开启全局设置 否则走账号二次验证
        if ($check2faConfig && (CacheConfigHelper::getConfigByKey('user_2FA')['value'] ?? false)) {
            return $result;
        }
        // 按优先级返回需要的二次验证方式
        if (!empty($user->google2fa)) {
            $result['verify_again'] = self::VERIFY_TYPE_GOOGLE2FA;
        } elseif (!empty($user->email)) {
            $result['verify_again'] = self::VERIFY_TYPE_EMAIL;
            $result['email'] = $user->email;
        } elseif (!empty($user->mobile)) {
            $result['verify_again'] = self::VERIFY_TYPE_MOBILE;
            $result['mobile'] = $user->mobile;
            $result['code'] = (string)$user->code;
        }
        return $result;
    }

    /**
     * 验证二次认证码
     *
     * @param User $user 用户对象
     * @param array $params 验证参数 ['google2fa_code' => '', 'vcode' => '', 'email' => '', 'mobile' => '', 'code' => '区号']
     * @param string $scene 验证码场景（用于短信/邮箱验证）
     * @return bool 验证是否成功
     * @throws BusinessException
     */
    public function verify(User $user, array $params, string $scene = VerifyCodeService::SCENE_LOGIN): bool
    {
        // 1. 优先验证 Google2FA
        if (!empty($user->google2fa)) {
            $code = $params['google2fa_code'] ?? '';
            if (empty($code)) {
                throw new BusinessException(message: trans('auth.google_code_required'));
            }
            $this->verifyGoogle2fa($user->google2fa, $code);
            return true;
        }

        // 2. 验证邮箱验证码
        if (!empty($user->email)) {
            $email = $params['email'] ?? $user->email;
            $vcode = $params['vcode'] ?? '';

            if (empty($vcode)) {
                throw new BusinessException(message: trans('auth.email_code_required'));
            }

            if (!VerifyCodeService::verify(
                VerifyCodeService::TYPE_EMAIL,
                $email,
                $vcode,
                $scene
            )) {
                throw new BusinessException(message: trans('auth.email_code_invalid'));
            }
            return true;
        }

        // 3. 验证手机验证码
        if (!empty($user->mobile)) {
            $mobile = $params['mobile'] ?? $user->mobile;
            $vcode = $params['vcode'] ?? '';

            if (empty($vcode)) {
                throw new BusinessException(message: trans('auth.mobile_code_required'));
            }

            $countryCode = (int)($params['code'] ?? $user->code ?? 86);

            if (!VerifyCodeService::verify(
                VerifyCodeService::TYPE_SMS,
                $mobile,
                $vcode,
                $scene,
                countryCode: $countryCode
            )) {
                throw new BusinessException(message: trans('auth.mobile_code_invalid'));
            }
        }
        return true;
    }

    /**
     * 验证 Google2FA 验证码
     *
     * @param string $secret Google2FA密钥
     * @param string|int $code 用户输入的验证码
     */
    public function verifyGoogle2fa(string $secret, string|int $code): void
    {
        // 开发环境跳过验证
        if ($this->env === 'dev') {
            return;
        }

        $google2fa = new Google2FA();
        try {
            $valid = $google2fa->verifyKey($secret, $code, 2);
            if (!$valid) {
                throw new BusinessException(message: trans('auth.google_code_invalid'));
            }
        } catch (\Throwable $e) {
            if ($e instanceof BusinessException) {
                throw $e;
            }
            throw new BusinessException(message: trans('auth.google_code_invalid'));
        }
    }

    /**
     * 生成 Google2FA 密钥
     *
     * @return string
     */
    public function generateSecret(): string
    {
        $google2fa = new Google2FA();
        return $google2fa->generateSecretKey();
    }

    /**
     * 生成 Google2FA 二维码 URL
     *
     * @param string $secret 密钥
     * @param string $identifier 用户标识（邮箱/用户名/手机号）
     * @return string
     */
    public function generateQrCodeUrl(string $secret, string $identifier): string
    {
        $google2fa = new Google2FA();
        return $google2fa->getQRCodeUrl(
            \Hyperf\Config\config('app_name') ?? 'FastApp',
            $identifier,
            $secret
        );
    }

    /**
     * 生成二维码 Base64 图片
     *
     * @param string $qrCodeUrl 二维码URL
     * @return string|null Base64编码的图片
     */
    public function generateQrCodeBase64(string $qrCodeUrl): ?string
    {
        // 优先使用 Imagick
        if (extension_loaded('imagick')) {
            try {
                $renderer = new ImageRenderer(
                    new RendererStyle(400),
                    new ImagickImageBackEnd()
                );
                $writer = new Writer($renderer);
                $qrcodePng = $writer->writeString($qrCodeUrl);
                return 'data:image/png;base64,' . base64_encode($qrcodePng);
            } catch (\Throwable) {
                // 忽略错误，尝试使用 GD
            }
        }

        // 使用 GD 库
        try {
            $renderer = new GDLibRenderer(400);
            $writer = new Writer($renderer);
            $qrcodePng = $writer->writeString($qrCodeUrl);
            return 'data:image/png;base64,' . base64_encode($qrcodePng);
        } catch (\Throwable) {
            return null;
        }
    }

    /**
     * 检查用户是否需要二次验证
     *
     * @param array|User $verifyInfo
     * @param array $params 已提交的参数
     * @return bool true=需要二次验证, false=不需要
     */
    public function needsVerification(array|User $verifyInfo, array $params): bool
    {
        if ($verifyInfo instanceof User) {
            $verifyInfo = $this->detectVerifyMethod($verifyInfo);
        }
        if ($verifyInfo['verify_again'] === self::VERIFY_TYPE_NONE) {
            return false;
        }

        // 检查是否已提供验证码
        return match ($verifyInfo['verify_again']) {
            self::VERIFY_TYPE_GOOGLE2FA => empty($params['google2fa_code']),
            self::VERIFY_TYPE_EMAIL, self::VERIFY_TYPE_MOBILE => empty($params['vcode']),
            default => false,
        };
    }

    /**
     * 验证密码和二次认证（通用方法）
     *
     * @param User $user 用户对象
     * @param array $validated 验证后的请求数据
     * @param string $password 密码（如果用户已设置密码则必填）
     * @param string $scene 验证码场景
     * @throws BusinessException
     */
    public function verifyPasswordAndTwoFactor(
        User   $user,
        array  $validated,
        string $password,
        string $scene = VerifyCodeService::SCENE_CHANGE
    ): void
    {
        // 1. 验证密码
        if (!empty($user->getOriginal('password'))) {
            if (empty($password)) {
                throw new BusinessException(message: trans('user.password_required'));
            }
            if (!$user->verifyPassword($password)) {
                throw new BusinessException(message: trans('user.password_error'));
            }
        }

        // 2. 验证二次认证
        $this->verify($user, $validated, $scene);
    }
}
