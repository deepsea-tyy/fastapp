<?php
/**
 * FastApp.
 * 10/16/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Http\Api\Controller\User;

use App\Common\AbstractController;
use App\Common\Middleware\AccessTokenMiddleware;
use App\Common\Middleware\TokenMiddleware;
use App\Common\Request\Request;
use App\Common\Result;
use App\Common\Service\VerifyCodeService;
use App\Common\Swagger\ResultResponse;
use App\Common\Tools;
use App\Exception\BusinessException;
use App\Http\Api\Request\UserRequest;
use App\Http\CurrentUser;
use App\Model\Enums\User\LoginType;
use App\Model\Enums\User\Type;
use BaconQrCode\Renderer\ImageRenderer;
use BaconQrCode\Renderer\Image\SvgImageBackEnd;
use BaconQrCode\Renderer\Image\ImagickImageBackEnd;
use BaconQrCode\Renderer\GDLibRenderer;
use BaconQrCode\Renderer\RendererStyle\RendererStyle;
use BaconQrCode\Writer;
use Hyperf\Context\RequestContext;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\Swagger\Annotation\Get;
use Hyperf\Swagger\Annotation\HyperfServer;
use Hyperf\Swagger\Annotation\JsonContent;
use Hyperf\Swagger\Annotation\Post;
use Hyperf\Swagger\Annotation\QueryParameter;
use Hyperf\Swagger\Annotation\RequestBody;
use PragmaRX\Google2FA\Google2FA;

#[HyperfServer(name: 'http')]
class UserController extends AbstractController
{
    public function __construct(
        private readonly CurrentUser $userService,
    )
    {
    }

    #[Post(
        path: '/api/user/register',
        operationId: 'ApiUserRegister',
        summary: '注册',
        security: [['token' => []]],
        tags: ['用户接口'],
    )]
    #[RequestBody(content: new JsonContent(
        ref: UserRequest::class,
        title: '注册请求参数',
        required: ['register_type'],
        example: '{ "username": "deepsea", "password": "123456", "password_confirmation": "123456", "mobile": "18111111111", "code": "12345", "openid": "oFvZO197qeVdsnFyKh7gDrqUpsf0", "type": 1, "invite_code": "ABC12345" }'
    ))]
    #[ResultResponse(instance: new Result(), example: '{"code":200,"message":"成功","data":{"access_token":"eyJ0eXAiO","expire_at":300}}')]
    public function register(UserRequest $request): Result
    {
        $validated = $request->validated();
        $validated['user_type'] = Type::USER;
        $user = '';
        if ($validated['type'] == LoginType::USERNAME_PASSWORD->value) {
            $user = $this->userService->findUser(['username' => $validated['username']]);
            if ($user) return $this->error(Tools::__('user.username_exist'));
            $user = $this->userService->create($validated);
        }
        if ($validated['type'] == LoginType::MOBILE_CODE->value) {
            // 验证手机验证码
            $scene = $validated['scene'] ?? VerifyCodeService::SCENE_REGISTER;
            if (!VerifyCodeService::verify(
                VerifyCodeService::TYPE_SMS,
                $validated['mobile'],
                $validated['code'] ?? '',
                $scene
            )) {
                throw new BusinessException(message: '验证码错误或已过期');
            }
            $user = $this->userService->create($validated);
        }
        if ($validated['type'] == LoginType::WECHAT_MINI->value) {
            $validated['wxmini_openid'] = $request->post('openid');
            $user = $this->userService->create($validated);
        }
        if ($validated['type'] == LoginType::WECHAT_OPEN->value) {
            $validated['wx_openid'] = $request->post('openid');
            $user = $this->userService->create($validated);
        }
        if (!$user) throw new BusinessException(message: trans('user.register_fail'));
        return $this->success($this->userService->formatToken($user, $request->ip(), $request->header('User-Agent') ?: 'unknown', $request->os()));
    }

    #[Get(
        path: '/api/user/isRegister',
        operationId: 'ApiUserIsRegister',
        summary: '是否注册',
        security: [['token' => []]],
        tags: ['用户接口'],
    )]
    #[ResultResponse(instance: new Result())]
    #[QueryParameter(name: 'mobile', description: 'mobile')]
    #[QueryParameter(name: 'username', description: 'username')]
    #[ResultResponse(instance: new Result(), example: '{"code":200, "data": {"status": 0}}')]
    public function isRegister(Request $request): Result
    {
        return $this->success(['status' => $this->userService->findUser($request->query()) ? 1 : 0]);
    }

    #[Get(
        path: '/api/sms',
        operationId: 'ApiUserSms',
        summary: '获取验证码',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['用户接口'],
    )]
    #[QueryParameter(name: 'mobile', description: '手机号', example: '1311111111')]
    #[QueryParameter(name: 'scene', description: '验证码场景：login(登录)、register(注册)、reset_password(找回密码)、bind(绑定)、change(修改)、default(默认)', required: false, example: 'login')]
    #[ResultResponse(instance: new Result(), example: '{"code":200, "data": {}}')]
    public function sms(UserRequest $request): Result
    {
        $request->validated();
        $mobile = $request->query('mobile');
        $scene = $request->query('scene', VerifyCodeService::SCENE_DEFAULT);
        $result = VerifyCodeService::send(
            VerifyCodeService::TYPE_SMS,
            $mobile,
            $scene
        );
        return $result['success'] ? $this->success(null, $result['message']) : $this->error($result['message']);
    }

    #[Post(
        path: '/api/user/login',
        operationId: 'ApiUserLogin',
        summary: '登录',
        tags: ['用户接口'],
    )]
    #[ResultResponse(instance: new Result(), example: '{"code":200,"message":"成功","data":{"access_token":"eyJ0eXAi","refresh_token":"eyxxx", "expire_at":300}}')]
    #[RequestBody(content: new JsonContent(
        ref: UserRequest::class,
        title: '登录请求参数',
        required: ['type'],
        example: '{ "username": "deepsea", "password": "123456", "mobile": "", "code": "", "google2fa_code": 1111, "type": 1 }'
    ))]
    public function login(UserRequest $request): Result
    {
        $validated = $request->validated();
        $user = '';
        if ($validated['type'] == LoginType::USERNAME_PASSWORD->value) {
            // type=1 时，可以使用 username、mobile 或 email 登录
            $findParams = [];
            if (!empty($validated['username'])) {
                $findParams['username'] = $validated['username'];
            } elseif (!empty($validated['mobile'])) {
                $findParams['code'] = $validated['code'];
                $findParams['mobile'] = $validated['mobile'];
            } elseif (!empty($validated['email'])) {
                $findParams['email'] = $validated['email'];
            }
            $user = $this->userService->findUser($findParams);
        } else if ($validated['type'] == LoginType::MOBILE_CODE->value) {
            $user = $this->userService->findUser(['mobile' => $validated['mobile']]);
        } else if ($validated['type'] == LoginType::EMAIL_CODE->value) {
            $user = $this->userService->findUser(['email' => $validated['mobile']]);
        }
        if (!$user) throw new BusinessException(message: trans('auth.user_not_register'));
        if ($validated['type'] == LoginType::USERNAME_PASSWORD->value && !$user->verifyPassword($validated['password'])) {
            throw new BusinessException(message: trans('auth.password_error'));
        }
        $verifyAgain = '';
        if ($user->google2fa) {
            $verifyAgain = 'google2fa_code';
        } elseif ($user->email) {
            $verifyAgain = 'email_code';
        }
        if (empty($validated['google2fa_code']) && empty($validated['vcode']) && $verifyAgain) {
            return $this->success(['verify_again' => $verifyAgain]);
        }
        if ($validated['type'] == LoginType::EMAIL_CODE->value) {
            $scene = $validated['scene'] ?? VerifyCodeService::SCENE_LOGIN;
            if (!VerifyCodeService::verify(
                VerifyCodeService::TYPE_EMAIL,
                $validated['mobile'],
                $validated['vcode'],
                $scene
            )) {
                throw new BusinessException(message: trans('auth.email_code_invalid'));
            }
        }
        if ($validated['type'] == LoginType::MOBILE_CODE->value) {
            $scene = $validated['scene'] ?? VerifyCodeService::SCENE_LOGIN;
            if (!VerifyCodeService::verify(
                VerifyCodeService::TYPE_SMS,
                $validated['mobile'],
                $validated['vcode'],
                $scene
            )) {
                throw new BusinessException(message: trans('auth.mobile_code_invalid'));
            }
        }
        if ($user->google2fa) {
            $google2fa = new Google2FA();
            try {
                $valid = $google2fa->verifyKey($user->google2fa, $validated['google2fa_code'], 2); // 允许2个时间窗口的误差
                if (!$valid) throw new BusinessException(message: trans('auth.google_code_invalid'));
            } catch (\Throwable) {
                throw new BusinessException(message: trans('auth.google_code_invalid'));
            }
        }
        return $this->success($this->userService->setScene('api')->formatToken($user, $request->ip(), $request->header('User-Agent') ?: 'unknown', $request->os()));
    }

    #[Post(
        path: '/api/user/logout',
        operationId: 'ApiUserLogout',
        summary: '登出',
        tags: ['用户接口'],
    )]
    #[ResultResponse(instance: new Result(), example: '{"code":200,"message":"成功","data":{}}')]
    #[Middleware(AccessTokenMiddleware::class)]
    public function logout(): Result
    {
        $this->userService->setScene('api')->logout(RequestContext::get()->getAttribute('token'));
        return $this->success();
    }

    #[Post(
        path: '/api/user/refreshToken',
        operationId: 'ApiUserRefreshToken',
        summary: '刷新token',
        tags: ['用户接口'],
    )]
    #[ResultResponse(instance: new Result(), example: '{"code":200,"message":"成功","data":{"access_token":"eyJ0eXAi","refresh_token":"eyxxx", "expire_at":300}}')]
    #[Middleware(TokenMiddleware::class)]
    public function refreshToken(): Result
    {
        $tokenData = $this->userService->setScene('api')->refreshToken(RequestContext::get()->getAttribute('token'));
        return $this->success($tokenData);
    }

    #[Get(
        path: '/api/user/info',
        operationId: 'ApiUserGetInfo',
        summary: '用户信息',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['用户接口'],
    )]
    #[ResultResponse(instance: new Result())]
    #[Middleware(TokenMiddleware::class)]
    public function info(): Result
    {
        $user = $this->userService->user();
        $user->is_google2fa = $user->google2fa ? 1 : 0;
        $user->is_trans_password = $user->profile?->trans_password ? 1 : 0;
        return $this->success($user);
    }

    #[Get(
        path: '/api/user/google2fa/qrcode',
        operationId: 'ApiUserGoogle2faQrcode',
        summary: '获取Google2FA二维码',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['用户接口'],
    )]
    #[ResultResponse(instance: new Result(), example: '{"code":200,"message":"成功","data":{"google2fa":"JBSWY3DPEHPK3PXP","qrcode":"data:image/svg+xml;base64,..."}}')]
    #[Middleware(TokenMiddleware::class)]
    public function google2faQrcode(): Result
    {
        $user = $this->userService->user();

        // 如果已经绑定，返回错误
        if (!empty($user->google2fa)) {
            throw new BusinessException(message: trans('auth.google_code_bind'));
        }

        $google2fa = new Google2FA();
        $appName = \Hyperf\Config\config('app_name', 'FastApp');
        $secret = $google2fa->generateSecretKey();

        // 生成二维码URL (otpauth://totp/...)
        $qrCodeUrl = $google2fa->getQRCodeUrl(
            $appName,
            $user->email ?: ($user->username ?: $user->mobile),
            $secret
        );

        // 生成PNG格式二维码（Flutter直接支持PNG图片）
        $qrcodeBase64 = null;

        // 优先使用 Imagick 生成 PNG
        if (extension_loaded('imagick')) {
            $renderer = new ImageRenderer(
                new RendererStyle(400),
                new ImagickImageBackEnd()
            );
            $writer = new Writer($renderer);
            $qrcodePng = $writer->writeString($qrCodeUrl);
            $qrcodeBase64 = 'data:image/png;base64,' . base64_encode($qrcodePng);
        }

        // 如果没有 Imagick 或失败，尝试使用 GD 库
        if (!$qrcodeBase64) {
            $renderer = new GDLibRenderer(400);
            $writer = new Writer($renderer);
            $qrcodePng = $writer->writeString($qrCodeUrl);
            $qrcodeBase64 = 'data:image/png;base64,' . base64_encode($qrcodePng);
        }

        return $this->success([
            'google2fa' => $secret,
            'qrcode' => $qrcodeBase64,
        ]);
    }

    #[Post(
        path: '/api/user/google2fa/bind',
        operationId: 'ApiUserGoogle2faBind',
        summary: '绑定Google2FA',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['用户接口'],
    )]
    #[RequestBody(content: new JsonContent(
        ref: UserRequest::class,
        title: '绑定Google2FA请求参数',
        required: ['google2fa', 'code'],
        example: '{ "google2fa": "JBSWY3DPEHPK3PXP", "google2fa_code": "123456" }'
    ))]
    #[ResultResponse(instance: new Result())]
    #[Middleware(TokenMiddleware::class)]
    public function google2faBind(UserRequest $request): Result
    {
        $validated = $request->validated();
        $user = $this->userService->user();
        $secret = $validated['google2fa'];
        $code = $validated['google2fa_code'];

        // 如果已经绑定，返回错误
        if (!empty($user->google2fa)) {
            throw new BusinessException(message: trans('auth.google_code_bind'));
        }

        // 验证验证码
        $google2fa = new Google2FA();
        $valid = $google2fa->verifyKey($secret, $code, 2); // 允许2个时间窗口的误差

        if (!$valid) {
            throw new BusinessException(message: trans('auth.google_code_invalid'));
        }

        // 保存密钥
        $user->google2fa = $secret;
        $user->save();

        return $this->success(message: trans('auth.bind_success'));
    }

    #[Post(
        path: '/api/user/google2fa/unbind',
        operationId: 'ApiUserGoogle2faUnbind',
        summary: '解绑Google2FA',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['用户接口'],
    )]
    #[RequestBody(content: new JsonContent(
        ref: UserRequest::class,
        title: '解绑Google2FA请求参数',
        required: ['google2fa_code'],
        example: '{ "google2fa_code": "123456" }'
    ))]
    #[ResultResponse(instance: new Result())]
    #[Middleware(TokenMiddleware::class)]
    public function google2faUnbind(UserRequest $request): Result
    {
        $validated = $request->validated();
        $user = $this->userService->user();
        $code = $validated['google2fa_code'];

        if (empty($user->google2fa)) {
            throw new BusinessException(message: trans('auth.google_code_unbind'));
        }

        // 验证验证码
        $google2fa = new Google2FA();
        $valid = $google2fa->verifyKey($user->google2fa, $code, 2);

        if (!$valid) {
            throw new BusinessException(message: trans('auth.google_code_invalid'));
        }
        // 清除密钥
        $user->google2fa = '';
        $user->save();
        return $this->success(message: trans('auth.unbind_success'));
    }

}