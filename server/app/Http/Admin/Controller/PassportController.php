<?php

declare(strict_types=1);


namespace App\Http\Admin\Controller;

use App\Common\AbstractController;
use App\Common\Middleware\AccessTokenMiddleware;
use App\Common\Result;
use App\Exception\BusinessException;
use App\Http\Admin\Request\PassportLoginRequest;
use App\Http\CurrentUser;
use App\Model\Enums\User\Type;
use Hyperf\Collection\Arr;
use Hyperf\Context\ApplicationContext;
use Hyperf\Context\RequestContext;
use Hyperf\HttpServer\Annotation\Controller;
use Hyperf\HttpServer\Annotation\GetMapping;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\HttpServer\Annotation\PostMapping;
use Hyperf\Redis\Redis;
use PragmaRX\Google2FA\Google2FA;

#[Controller]
final class PassportController extends AbstractController
{

    public function __construct(
        private readonly CurrentUser $currentUser,
    )
    {
    }

    #[PostMapping(path: '/admin/passport/login')]
    public function login(PassportLoginRequest $request): Result
    {
        $validated = $request->validated();
        $username = (string)$validated['username'];
        $password = (string)$validated['password'];

        // 查找用户
        $user = $this->currentUser->findUser(['username' => $username, 'user_type' => Type::SYSTEM]);
        if (!$user || !$user->verifyPassword($password)) {
            throw new BusinessException(message: trans('user.password_error'));
        }
        // 开发环境无需验证
        $isProd = \Hyperf\Config\config('env') === 'prod';

        // 根据验证码类型进行验证
        if ($isProd) {
            // 验证图形验证码
            $code = $validated['code'] ?? '';
            $cacheKey = 'admin:captcha:' . $request->ip();
            $redis = ApplicationContext::getContainer()->get(Redis::class);
            $storedCode = $redis->get($cacheKey);

            if (!$storedCode || strtolower($storedCode) !== strtolower($code)) {
                throw new BusinessException(message: '验证码错误无效');
            }

            // 验证成功后删除验证码
            $redis->del($cacheKey);
        }
        if (empty($validated['google2fa_code']) && $user->google2fa) {
            return $this->success(['verify_again' => 'google2fa_code']);
        }

        if ($user->google2fa) {
            // 验证Google2FA
            $google2fa = new Google2FA();
            $valid = $google2fa->verifyKey($user->google2fa, $validated['google2fa_code'], 2); // 允许2个时间窗口的误差
            if (!$valid) {
                throw new BusinessException(message: trans('auth.google_code_invalid'));
            }
        }

        $browser = $request->header('User-Agent') ?: 'unknown';
        return $this->success(
            $this->currentUser->formatToken(
                $user,
                $request->ip(),
                $browser,
                $request->os()
            )
        );
    }

    #[PostMapping(path: '/admin/passport/logout')]
    #[Middleware(AccessTokenMiddleware::class)]
    public function logout(): Result
    {
        $this->currentUser->logout(RequestContext::get()->getAttribute('token'));
        return $this->success();
    }

    #[GetMapping(path: '/admin/passport/getInfo')]
    #[Middleware(AccessTokenMiddleware::class)]
    public function getInfo(): Result
    {
        return $this->success(
            Arr::only(
                $this->currentUser->getInfo($this->currentUser->id())?->toArray() ?: [],
                ['username', 'nickname', 'avatar', 'signed', 'backend_setting', 'phone', 'email']
            )
        );
    }

    #[PostMapping(path: '/admin/passport/refresh')]
    #[Middleware(AccessTokenMiddleware::class)]
    public function refresh(): Result
    {
        return $this->success($this->currentUser->refreshToken($this->currentUser->getToken()));
    }

    #[GetMapping(path: '/admin/passport/captcha')]
    public function captcha(): Result
    {
        // 生成验证码
        $code = $this->generateCaptchaCode();
        $image = $this->generateCaptchaImage($code);

        // 保存验证码到Redis（5分钟有效期）
        $request = RequestContext::get();
        $serverParams = $request->getServerParams();
        $ip = $serverParams['remote_addr'] ?? '0.0.0.0';
        $cacheKey = 'admin:captcha:' . $ip;
        $redis = ApplicationContext::getContainer()->get(Redis::class);
        $redis->setex($cacheKey, 300, $code);

        return $this->success([
            'image' => 'data:image/png;base64,' . base64_encode($image),
        ]);
    }

    /**
     * 生成验证码字符串
     */
    private function generateCaptchaCode(int $length = 4): string
    {
        $pool = 'abcdefghjkmnpqrstuvwxyz23456789';
        $code = '';
        for ($i = 0; $i < $length; $i++) {
            $code .= $pool[random_int(0, strlen($pool) - 1)];
        }
        return $code;
    }

    /**
     * 生成验证码图片
     */
    private function generateCaptchaImage(string $code): string
    {
        $width = 120;
        $height = 36;

        // 创建画布
        $image = imagecreatetruecolor($width, $height);

        // 设置背景色（浅色）
        $bgColor = imagecolorallocate($image, random_int(230, 255), random_int(230, 255), random_int(230, 255));
        imagefill($image, 0, 0, $bgColor);

        // 绘制验证码文字
        $fontSize = 20;
        $x = 15;
        $fontPath = '';//字体


        for ($i = 0; $i < strlen($code); $i++) {
            $textColor = imagecolorallocate($image, random_int(80, 150), random_int(80, 150), random_int(80, 150));
            $y = $height / 2 + 8;

            if ($fontPath) {
                imagettftext($image, $fontSize, 0, $x, $y, $textColor, $fontPath, $code[$i]);
            } else {
                imagestring($image, 5, $x, $y - 12, $code[$i], $textColor);
            }
            $x += 24;
        }

        // 绘制干扰线
        for ($i = 0; $i < 5; $i++) {
            $lineColor = imagecolorallocate($image, random_int(180, 230), random_int(180, 230), random_int(180, 230));
            imageline($image, random_int(0, $width), random_int(0, $height), random_int(0, $width), random_int(0, $height), $lineColor);
        }

        // 绘制干扰点
        for ($i = 0; $i < 40; $i++) {
            $pointColor = imagecolorallocate($image, random_int(150, 200), random_int(150, 200), random_int(150, 200));
            imagesetpixel($image, random_int(0, $width), random_int(0, $height), $pointColor);
        }

        // 输出图片
        ob_start();
        imagepng($image);
        $imageData = ob_get_contents();
        ob_end_clean();
        imagedestroy($image);

        return $imageData;
    }
}
