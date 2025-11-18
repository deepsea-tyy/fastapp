<?php

declare(strict_types=1);


namespace App\Http\Admin\Controller;

use App\Common\AbstractController;
use App\Common\Middleware\AccessTokenMiddleware;
use App\Common\Middleware\RefreshTokenMiddleware;
use App\Common\Result;
use App\Common\ResultCode;
use App\Common\Swagger\ResultResponse;
use App\Exception\BusinessException;
use App\Http\Admin\Request\PassportLoginRequest;
use App\Http\Admin\Vo\PassportLoginVo;
use App\Http\CurrentUser;
use App\Http\PassportService;
use App\Schema\UserSchema;
use Hyperf\Collection\Arr;
use Hyperf\Context\ApplicationContext;
use Hyperf\Context\RequestContext;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\Redis\Redis;
use Hyperf\Swagger\Annotation as OA;
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\Post;
use PragmaRX\Google2FA\Google2FA;

#[OA\HyperfServer(name: 'http')]
final class PassportController extends AbstractController
{

    public function __construct(
        private readonly PassportService $passportService,
        private readonly CurrentUser     $currentUser
    )
    {
    }

    #[Post(
        path: '/admin/passport/login',
        operationId: 'passportLogin',
        summary: '系统登录',
        tags: ['admin:passport']
    )]
    #[ResultResponse(
        instance: new Result(data: new PassportLoginVo()),
        title: '登录成功',
        description: '登录成功返回对象',
        example: '{"code":200,"message":"成功","data":{"access_token":"eyJ0eXAiOi","expire_at":300}}'
    )]
    #[OA\RequestBody(content: new OA\JsonContent(
        ref: PassportLoginRequest::class,
        title: '登录请求参数',
        required: ['username', 'password'],
        example: '{"username":"admin","password":"123456"}'
    ))]
    public function login(PassportLoginRequest $request): Result
    {
        $validated = $request->validated();
        $username = (string)$validated['username'];
        $password = (string)$validated['password'];

        // 查找用户
        $user = $this->passportService->findUsernamePassword($username, $password, 100);
        if (!$user) {
            throw new BusinessException(ResultCode::UNPROCESSABLE_ENTITY, '用户名或密码错误');
        }

        // 开发环境无需验证
        $isDev = config('env') === 'dev';
        $type = config('captcha');

        // 根据验证码类型进行验证
        if ($type === 'captcha' && !$isDev) {
            // 验证图形验证码
            $code = $validated['code'] ?? '';
            $cacheKey = 'admin:captcha:' . $request->ip();
            $redis = ApplicationContext::getContainer()->get(Redis::class);
            $storedCode = $redis->get($cacheKey);

            if (!$storedCode || strtolower($storedCode) !== strtolower($code)) {
                throw new BusinessException(ResultCode::UNPROCESSABLE_ENTITY, '验证码错误无效');
            }

            // 验证成功后删除验证码
            $redis->del($cacheKey);
        } elseif ($type === 'google2fa' && !$isDev) {
            // 验证Google2FA
            if (empty($user->google2fa)) {
                throw new BusinessException(ResultCode::UNPROCESSABLE_ENTITY, '未绑定Google2FA');
            }

            $google2faCode = $validated['google2fa'] ?? '';
            $google2fa = new Google2FA();
            $valid = $google2fa->verifyKey($user->google2fa, $google2faCode, 2); // 允许2个时间窗口的误差

            if (!$valid) {
                throw new BusinessException(ResultCode::UNPROCESSABLE_ENTITY, '验证码错误');
            }
        }

        $browser = $request->header('User-Agent') ?: 'unknown';
        return $this->success(
            $this->passportService->formatToken(
                $user,
                $request->ip(),
                $browser,
                $request->os()
            )
        );
    }

    #[Post(
        path: '/admin/passport/logout',
        operationId: 'passportLogout',
        summary: '退出',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['admin:passport']
    )]
    #[ResultResponse(instance: new Result(), example: '{"code":200,"message":"成功","data":[]}')]
    #[Middleware(AccessTokenMiddleware::class)]
    public function logout(): Result
    {
        $this->passportService->logout(RequestContext::get()->getAttribute('token'));
        return $this->success();
    }

    #[OA\Get(
        path: '/admin/passport/getInfo',
        operationId: 'getInfo',
        summary: '获取用户信息',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['admin:passport']
    )]
    #[Middleware(AccessTokenMiddleware::class)]
    #[ResultResponse(
        instance: new Result(data: UserSchema::class),
    )]
    public function getInfo(): Result
    {
        return $this->success(
            Arr::only(
                $this->currentUser->adminUser()?->toArray() ?: [],
                ['username', 'nickname', 'avatar', 'signed', 'backend_setting', 'phone', 'email']
            )
        );
    }

    #[Post(
        path: '/admin/passport/refresh',
        operationId: 'refresh',
        summary: '刷新token',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['admin:passport']
    )]
    #[Middleware(RefreshTokenMiddleware::class)]
    #[ResultResponse(
        instance: new Result(data: new PassportLoginVo())
    )]
    public function refresh(CurrentUser $user): Result
    {
        return $this->success($user->refresh());
    }

    #[Get(
        path: '/admin/passport/captcha',
        operationId: 'getCaptcha',
        summary: '获取平台验证码图片',
        tags: ['admin:passport']
    )]
    #[ResultResponse(instance: new Result(), example: '{"code":200,"message":"成功","data":{"code":"abcd","image":"data:image/png;base64,..."}}')]
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
