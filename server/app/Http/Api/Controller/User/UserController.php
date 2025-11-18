<?php
/**
 * FastApp.
 * 10/16/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Http\Api\Controller\User;

use App\Common\AbstractController;
use App\Common\Middleware\TokenMiddleware;
use App\Common\Request\Request;
use App\Common\Result;
use App\Common\ResultCode;
use App\Common\Service\VerifyCodeService;
use App\Common\Swagger\ResultResponse;
use App\Common\Tools;
use App\Exception\BusinessException;
use App\Http\Api\Request\UserRequest;
use App\Http\CurrentUser;
use App\Http\PassportService;
use App\Model\Enums\User\LoginType;
use App\Model\Enums\User\Type;
use BaconQrCode\Renderer\ImageRenderer;
use BaconQrCode\Renderer\Image\SvgImageBackEnd;
use BaconQrCode\Renderer\RendererStyle\RendererStyle;
use BaconQrCode\Writer;
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
        private readonly PassportService $passportService,
        private readonly CurrentUser     $currentUser,
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
            $user = $this->passportService->findUser(['username' => $validated['username']]);
            if ($user) return $this->error(Tools::__('user.username_exist'));
            $user = $this->passportService->create($validated);
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
                throw new BusinessException(ResultCode::UNPROCESSABLE_ENTITY, '验证码错误或已过期');
            }
            $user = $this->passportService->create($validated);
        }
        if ($validated['type'] == LoginType::WECHAT_MINI->value) {
            $validated['wxmini_openid'] = $request->post('openid');
            $user = $this->passportService->create($validated);
        }
        if ($validated['type'] == LoginType::WECHAT_OPEN->value) {
            $validated['wx_openid'] = $request->post('openid');
            $user = $this->passportService->create($validated);
        }
        if (!$user) throw new BusinessException(ResultCode::FAIL, trans('user.register_fail'));
        return $this->success($this->passportService->formatToken($user, $request->ip(), $request->header('User-Agent') ?: 'unknown', $request->os()));
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
    public function isRegister(Request $request): Result
    {
        return $this->success(['status' => $this->passportService->findUser($request->query()) ? 1 : 0]);
    }

    #[Get(
        path: '/api/sms',
        operationId: 'ApiUserSms',
        summary: '获取验证码',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['用户接口'],
    )]
    #[QueryParameter(name: 'mobile', description: '手机号', example: '1311111111')]
    #[QueryParameter(name: 'scene', description: '验证码场景：login(登录)、register(注册)、reset_password(找回密码)、bind(绑定)、change(修改)、default(默认)', example: 'login', required: false)]
    #[ResultResponse(instance: new Result())]
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
    #[ResultResponse(instance: new Result(), example: '{"code":200,"message":"成功","data":{"access_token":"eyJ0eXAi","expire_at":300}}')]
    #[RequestBody(content: new JsonContent(
        ref: UserRequest::class,
        title: '登录请求参数',
        required: ['type'],
        example: '{ "username": "deepsea", "password": "123456", "mobile": "", "code": "", "type": 1 }'
    ))]
    public function login(UserRequest $request): Result
    {
        $validated = $request->validated();
        $user = '';
        if ($validated['type'] == 1) {
            $user = $this->passportService->findUsernamePassword($validated['username'], $validated['password']);
        }
        if ($validated['type'] == 2) {
            // 验证手机验证码
            $scene = $validated['scene'] ?? VerifyCodeService::SCENE_LOGIN;
            if (!VerifyCodeService::verify(
                VerifyCodeService::TYPE_SMS,
                $validated['mobile'],
                $validated['code'] ?? '',
                $scene
            )) {
                throw new BusinessException(ResultCode::UNPROCESSABLE_ENTITY, '验证码错误或已过期');
            }
            $user = $this->passportService->findUser(['mobile' => $validated['mobile']]);
        }
        if (!$user) throw new BusinessException(ResultCode::UNPROCESSABLE_ENTITY, '用户不存在');
        return $this->success($this->passportService->setScene('api')->formatToken($user, $request->ip(), $request->header('User-Agent') ?: 'unknown', $request->os()));
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
        return $this->success($this->currentUser->user());
    }

    #[Get(
        path: '/api/user/google2fa/qrcode',
        operationId: 'ApiUserGoogle2faQrcode',
        summary: '获取Google2FA二维码',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['用户接口'],
    )]
    #[ResultResponse(instance: new Result(), example: '{"code":200,"message":"成功","data":{"secret":"JBSWY3DPEHPK3PXP","qrcode":"data:image/svg+xml;base64,..."}}')]
    #[Middleware(TokenMiddleware::class)]
    public function google2faQrcode(): Result
    {
        $user = $this->currentUser->user();

        // 如果已经绑定，返回错误
        if (!empty($user->google2fa)) {
            throw new BusinessException(ResultCode::UNPROCESSABLE_ENTITY, 'Google2FA已绑定，请先解绑');
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

        // 生成SVG二维码
        $renderer = new ImageRenderer(
            new RendererStyle(400),
            new SvgImageBackEnd()
        );
        $writer = new Writer($renderer);
        $qrcodeSvg = $writer->writeString($qrCodeUrl);
        $qrcodeBase64 = 'data:image/svg+xml;base64,' . base64_encode($qrcodeSvg);

        return $this->success([
            'secret' => $secret,
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
        required: ['secret', 'code'],
        example: '{ "secret": "JBSWY3DPEHPK3PXP", "code": "123456" }'
    ))]
    #[ResultResponse(instance: new Result())]
    #[Middleware(TokenMiddleware::class)]
    public function google2faBind(UserRequest $request): Result
    {
        $validated = $request->validated();
        $user = $this->currentUser->user();
        $secret = $validated['secret'];
        $code = $validated['code'];

        // 如果已经绑定，返回错误
        if (!empty($user->google2fa)) {
            throw new BusinessException(ResultCode::UNPROCESSABLE_ENTITY, 'Google2FA已绑定');
        }

        // 验证验证码
        $google2fa = new Google2FA();
        $valid = $google2fa->verifyKey($secret, $code, 2); // 允许2个时间窗口的误差

        if (!$valid) {
            throw new BusinessException(ResultCode::UNPROCESSABLE_ENTITY, '验证码错误');
        }

        // 保存密钥
        $user->google2fa = $secret;
        $user->save();

        return $this->success(null, '绑定成功');
    }

    #[Post(
        path: '/api/user/google2fa/verify',
        operationId: 'ApiUserGoogle2faVerify',
        summary: '验证Google2FA',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['用户接口'],
    )]
    #[RequestBody(content: new JsonContent(
        ref: UserRequest::class,
        title: '验证Google2FA请求参数',
        required: ['code'],
        example: '{ "code": "123456" }'
    ))]
    #[ResultResponse(instance: new Result())]
    #[Middleware(TokenMiddleware::class)]
    public function google2faVerify(UserRequest $request): Result
    {
        $validated = $request->validated();
        $user = $this->currentUser->user();
        $code = $validated['code'];

        if (empty($user->google2fa)) {
            throw new BusinessException(ResultCode::UNPROCESSABLE_ENTITY, '未绑定Google2FA');
        }

        // 验证验证码
        $google2fa = new Google2FA();
        $valid = $google2fa->verifyKey($user->google2fa, $code, 2); // 允许2个时间窗口的误差

        if (!$valid) {
            throw new BusinessException(ResultCode::UNPROCESSABLE_ENTITY, '验证码错误');
        }

        return $this->success(null, '验证成功');
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
        required: ['code'],
        example: '{ "code": "123456" }'
    ))]
    #[ResultResponse(instance: new Result())]
    #[Middleware(TokenMiddleware::class)]
    public function google2faUnbind(UserRequest $request): Result
    {
        $validated = $request->validated();
        $user = $this->currentUser->user();
        $code = $validated['code'];

        if (empty($user->google2fa)) {
            throw new BusinessException(ResultCode::UNPROCESSABLE_ENTITY, '未绑定Google2FA');
        }

        // 验证验证码
        $google2fa = new Google2FA();
        $valid = $google2fa->verifyKey($user->google2fa, $code, 2);

        if (!$valid) {
            throw new BusinessException(ResultCode::UNPROCESSABLE_ENTITY, '验证码错误');
        }

        // 清除密钥
        $user->google2fa = '';
        $user->save();

        return $this->success(null, '解绑成功');
    }

}