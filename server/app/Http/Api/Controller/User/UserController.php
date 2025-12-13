<?php
/**
 * FastApp.
 * 10/16/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Http\Api\Controller\User;

use App\Common\AbstractController;
use App\Common\Event\UserAccountEvent;
use App\Common\Middleware\AccessTokenMiddleware;
use App\Common\Middleware\TokenMiddleware;
use App\Common\Result;
use App\Common\Service\VerifyCodeService;
use App\Common\Swagger\ResultResponse;
use App\Common\Tools;
use App\Exception\BusinessException;
use App\Http\Api\Request\UserRequest;
use App\Http\CurrentUser;
use App\Model\Enums\User\LoginType;
use App\Model\Enums\User\Status;
use App\Model\Enums\User\Type;
use App\Model\User;
use App\Model\UserAccountLog;
use BaconQrCode\Renderer\ImageRenderer;
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
use Plugin\Ds\SysConfig\Helper\CacheConfigHelper;
use PragmaRX\Google2FA\Google2FA;
use Ramsey\Uuid\Uuid;

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
        example: '{ "username": "deepsea", "password": "123456", "password_confirmation": "123456", "mobile": "18111111111", "code": "86","vcode": "1234", "openid": "oFvZO197qeVdsnFyKh7gDrqUpsf0", "type": 1, "invite_code": "ABC12345" }'
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

        $deviceId = $validated['device_id'] ?? '';
        if (empty($deviceId)) {
            $deviceId = Uuid::uuid4()->toString();
        }

        $tokenData = $this->userService->setScene('api')->formatToken(
            $user,
            $request->ip(),
            $request->header('User-Agent') ?: 'unknown',
            $request->os(),
            $deviceId
        );
        $tokenData['device_id'] = $deviceId;
        return $this->success($tokenData);
    }

    #[Get(
        path: '/api/user/isRegister',
        operationId: 'ApiUserIsRegister',
        summary: '是否注册',
        security: [['token' => []]],
        tags: ['用户接口'],
    )]
    #[ResultResponse(instance: new Result())]
    #[QueryParameter(name: 'code', description: 'code')]
    #[QueryParameter(name: 'mobile', description: 'mobile')]
    #[QueryParameter(name: 'username', description: 'username')]
    #[ResultResponse(instance: new Result(), example: '{"code":200, "data": {"status": 0}}')]
    public function isRegister(): Result
    {
        return $this->success(['status' => $this->userService->findUser($this->getRequestData()) ? 1 : 0]);
    }

    #[Get(
        path: '/api/sms',
        operationId: 'ApiUserSms',
        summary: '获取验证码',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['用户接口'],
    )]
    #[QueryParameter(name: 'type', description: '验证码类型：sms(手机短信)或email(邮箱)', required: true, example: 'sms')]
    #[QueryParameter(name: 'to', description: '接收地址：手机号或邮箱地址', required: true, example: '1311111111')]
    #[QueryParameter(name: 'code', description: '国家代码（仅手机短信需要），默认86', required: false, example: '86')]
    #[QueryParameter(name: 'scene', description: '验证码场景：login(登录)、register(注册)、reset_password(找回密码)、bind(绑定)、change(修改)、default(默认)', required: false, example: 'login')]
    #[ResultResponse(instance: new Result(), example: '{"code":200, "data": {}}')]
    public function sms(UserRequest $request): Result
    {
        $validated = $request->validated();
        $type = $validated['type'];
        $to = $validated['to'];
        $scene = $validated['scene'] ?? VerifyCodeService::SCENE_DEFAULT;
        $countryCode = (int)($validated['code'] ?? 86);

        $result = VerifyCodeService::send(
            $type === 'sms' ? VerifyCodeService::TYPE_SMS : VerifyCodeService::TYPE_EMAIL,
            $to,
            $scene,
            countryCode: $countryCode
        );
        return $result['success'] ? $this->success(message: $result['message']) : $this->error($result['message']);
    }

    #[Post(
        path: '/api/user/smsCheck',
        operationId: 'ApiUserSmsCheck',
        summary: '登录',
        tags: ['用户接口'],
    )]
    #[ResultResponse(instance: new Result())]
    #[RequestBody(content: new JsonContent(
        ref: UserRequest::class,
        title: '验证码验证',
        required: ['type'],
        example: '{ "type": "smm", to": "", "code": "",  "vcode": "", "scene": "" }'
    ))]
    public function smsCheck(UserRequest $request): Result
    {
        $validated = $request->validated();
        $type = $validated['type'];

        return VerifyCodeService::verify(
            $type === 'sms' ? VerifyCodeService::TYPE_SMS : VerifyCodeService::TYPE_EMAIL,
            $validated['to'],
            $validated['vcode'],
            $validated['scene'] ?? VerifyCodeService::SCENE_DEFAULT,
            false,
            (int)($validated['code'] ?? 86),
        ) ? $this->success() : $this->error(trans('auth.mobile_code_invalid'));
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
        if ($user->status == Status::DISABLE->value) throw new BusinessException(message: trans('result.disabled'));
        if ($validated['type'] == LoginType::USERNAME_PASSWORD->value && !$user->verifyPassword($validated['password'])) {
            throw new BusinessException(message: trans('user.password_error'));
        }

        $deviceId = $validated['device_id'] ?? '';
        if (empty($deviceId)) {
            $deviceId = Uuid::uuid4()->toString();
        }
        $verifyAgain = '';
        $fa = CacheConfigHelper::getConfigByKey('user_2FA')['value'] ?? true;
        if ($fa) {
            if ($user->google2fa) {
                $verifyAgain = 'google2fa_code';
            } elseif ($user->email) {
                $verifyAgain = 'email_code';
            } elseif ($user->mobile) {
                $verifyAgain = 'mobile_code';
            }
            if (empty($validated['google2fa_code']) && empty($validated['vcode']) && $verifyAgain) {
                return $this->success([
                    'verify_again' => $verifyAgain,
                    'email' => $user->email,
                    'mobile' => $user->mobile,
                    'code' => (string)$user->code,
                    'device_id' => $deviceId,
                ]);
            }
        }
        if ($validated['type'] == LoginType::EMAIL_CODE->value || $verifyAgain == 'email_code') {
            $scene = $validated['scene'] ?? VerifyCodeService::SCENE_LOGIN;
            if (!VerifyCodeService::verify(
                VerifyCodeService::TYPE_EMAIL,
                $validated['email'],
                $validated['vcode'],
                $scene
            )) {
                throw new BusinessException(message: trans('auth.email_code_invalid'));
            }
        }
        if ($validated['type'] == LoginType::MOBILE_CODE->value || $verifyAgain == 'mobile_code') {
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
        if ($user->google2fa && $verifyAgain == 'google2fa_code') {
            $this->verifyGoogle2fa($user->google2fa, $validated['google2fa_code'] ?? '');
        }

        $tokenData = $this->userService->setScene('api')->formatToken(
            $user,
            $request->ip(),
            $request->header('User-Agent') ?: 'unknown',
            $request->os(),
            $deviceId
        );
        $tokenData['device_id'] = $deviceId;
        return $this->success($tokenData);
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
        $user->is_password = $user->getOriginal('password') ? 1 : 0;
        $user->is_kyc = 0; //0未填写1待认证2失败3成功
        return $this->success($user);
    }

    #[Post(
        path: '/api/user/password/change',
        operationId: 'ApiUserPasswordChange',
        summary: '修改密码',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['用户接口'],
    )]
    #[RequestBody(content: new JsonContent(
        ref: UserRequest::class,
        title: '修改密码请求参数',
        required: ['password', 'password_confirmation'],
        example: '{ "old_password": "123456", "password": "newpassword", "password_confirmation": "newpassword", "google2fa_code": "123456" }'
    ))]
    #[ResultResponse(instance: new Result())]
    #[Middleware(TokenMiddleware::class)]
    public function changePassword(UserRequest $request): Result
    {
        $validated = $request->validated();
        $user = $this->userService->user();

        $oldPassword = '';
        if (!empty($user->getOriginal('password'))) {
            if (empty($validated['old_password'])) {
                throw new BusinessException(message: trans('user.old_password_required'));
            }
            if (!$user->verifyPassword($validated['old_password'])) {
                throw new BusinessException(message: trans('user.old_password_error'));
            }
            $oldPassword = $validated['old_password'];
        }

        $scene = VerifyCodeService::SCENE_CHANGE;
        $this->verifyPasswordAndCode($user, $validated, $oldPassword, $scene);

        $user->password = $validated['password'];
        $user->save();

        $token = RequestContext::get()->getAttribute('token');
        if ($token) {
            $this->userService->setScene('api')->logout($token);
        }

        return $this->success(message: trans('user.password_change_success'));
    }

    #[Post(
        path: '/api/user/account/disable',
        operationId: 'ApiUserAccountDisable',
        summary: '禁用账户',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['用户接口'],
    )]
    #[RequestBody(content: new JsonContent(
        ref: UserRequest::class,
        title: '禁用账户请求参数',
        example: '{ "password": "123456", "google2fa_code": "123456", "vcode": "123456" }'
    ))]
    #[ResultResponse(instance: new Result())]
    #[Middleware(TokenMiddleware::class)]
    public function disableAccount(UserRequest $request): Result
    {
        $validated = $request->validated();
        $user = $this->userService->user();

        $this->verifyPasswordAndCode($user, $validated, $validated['password'] ?? '', VerifyCodeService::SCENE_CHANGE);

        $user->status = Status::DISABLE->value;
        $user->save();

        $token = RequestContext::get()->getAttribute('token');
        if ($token) {
            $this->userService->setScene('api')->logout($token);
        }
        $this->dispatchUserLoginEvent($user, $request, 8);
        return $this->success(message: trans('auth.account_disable_success'));
    }

    #[Post(
        path: '/api/user/account/delete',
        operationId: 'ApiUserAccountDelete',
        summary: '删除账户',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['用户接口'],
    )]
    #[RequestBody(content: new JsonContent(
        ref: UserRequest::class,
        title: '删除账户请求参数',
        example: '{ "password": "123456", "google2fa_code": "123456", "vcode": "123456" }'
    ))]
    #[ResultResponse(instance: new Result())]
    #[Middleware(TokenMiddleware::class)]
    public function deleteAccount(UserRequest $request): Result
    {
        $validated = $request->validated();
        $user = $this->userService->user();

        $this->verifyPasswordAndCode($user, $validated, $validated['password'] ?? '', VerifyCodeService::SCENE_CHANGE);

        $parts = array_filter([$user->username ?: '', $user->email ?: "", $user->mobile ?: '']);
        $newUsername = 'del' . implode('|', $parts);

        $user->email = null;
        $user->mobile = null;
        $user->username = $newUsername;
        $user->status = Status::DISABLE->value;
        $user->save();

        $token = RequestContext::get()->getAttribute('token');
        if ($token) {
            $this->userService->setScene('api')->logout($token);
        }
        $this->dispatchUserLoginEvent($user, $request, 9);
        return $this->success(message: trans('auth.account_delete_success'));
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

        if (!empty($user->google2fa)) {
            throw new BusinessException(message: trans('auth.google_code_bind'));
        }

        $google2fa = new Google2FA();
        $appName = \Hyperf\Config\config('app_name', 'FastApp');
        $secret = $google2fa->generateSecretKey();

        $qrCodeUrl = $google2fa->getQRCodeUrl(
            $appName,
            $user->email ?: ($user->username ?: $user->mobile),
            $secret
        );

        $qrcodeBase64 = $this->generateQrCodeBase64($qrCodeUrl);

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

        if (!empty($user->google2fa)) {
            throw new BusinessException(message: trans('auth.google_code_bind'));
        }

        $this->verifyGoogle2fa($secret, $code);

        $user->google2fa = $secret;
        $user->save();
        $this->dispatchUserLoginEvent($user, $request, 10);
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

        $this->verifyGoogle2fa($user->google2fa, $code);
        $user->google2fa = '';
        $user->save();
        $this->dispatchUserLoginEvent($user, $request, 11);
        return $this->success(message: trans('auth.unbind_success'));
    }

    #[Post(
        path: '/api/user/email/bind',
        operationId: 'ApiUserEmailBind',
        summary: '绑定邮箱',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['用户接口'],
    )]
    #[RequestBody(content: new JsonContent(
        ref: UserRequest::class,
        title: '绑定邮箱请求参数',
        required: ['email', 'vcode'],
        example: '{ "email": "user@example.com", "vcode": "123456", "google2fa_code": "123456" }'
    ))]
    #[ResultResponse(instance: new Result())]
    #[Middleware(TokenMiddleware::class)]
    public function emailBind(UserRequest $request): Result
    {
        $validated = $request->validated();
        $user = $this->userService->user();
        $email = $validated['email'];
        $vcode = $validated['vcode'];

        $existingUser = $this->userService->findUser(['email' => $email]);
        if ($existingUser && $existingUser->id !== $user->id) {
            throw new BusinessException(message: trans('auth.email_used'));
        }

        if (!empty($user->email)) {
            throw new BusinessException(message: trans('auth.email_bind'));
        }

        if (!empty($user->google2fa)) {
            if (empty($validated['google2fa_code'])) {
                throw new BusinessException(message: trans('auth.google_code_required'));
            }
            $this->verifyGoogle2fa($user->google2fa, $validated['google2fa_code']);
        }

        $scene = VerifyCodeService::SCENE_BIND;
        if (!VerifyCodeService::verify(
            VerifyCodeService::TYPE_EMAIL,
            $email,
            $vcode,
            $scene,
        )) {
            throw new BusinessException(message: trans('auth.email_code_invalid'));
        }

        $user->email = $email;
        $user->save();
        $this->dispatchUserLoginEvent($user, $request, 5);
        return $this->success(message: trans('auth.bind_success'));
    }

    #[Post(
        path: '/api/user/email/unbind',
        operationId: 'ApiUserEmailUnbind',
        summary: '解绑邮箱',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['用户接口'],
    )]
    #[RequestBody(content: new JsonContent(
        ref: UserRequest::class,
        title: '解绑邮箱请求参数',
        required: ['vcode'],
        example: '{ "vcode": "123456", "google2fa_code": "123456" }'
    ))]
    #[ResultResponse(instance: new Result())]
    #[Middleware(TokenMiddleware::class)]
    public function emailUnbind(UserRequest $request): Result
    {
        $validated = $request->validated();
        $user = $this->userService->user();
        $vcode = $validated['vcode'];

        if (empty($user->email)) {
            throw new BusinessException(message: trans('auth.email_unbind'));
        }

        if (!empty($user->google2fa)) {
            if (empty($validated['google2fa_code'])) {
                throw new BusinessException(message: trans('auth.google_code_required'));
            }
            $this->verifyGoogle2fa($user->google2fa, $validated['google2fa_code']);
        }

        $scene = VerifyCodeService::SCENE_BIND;
        if (!VerifyCodeService::verify(
            VerifyCodeService::TYPE_EMAIL,
            $user->email,
            $vcode,
            $scene,
        )) {
            throw new BusinessException(message: trans('auth.email_code_invalid'));
        }

        $user->email = null;
        $user->save();
        $this->dispatchUserLoginEvent($user, $request, 7);
        return $this->success(message: trans('auth.unbind_success'));
    }

    #[Post(
        path: '/api/user/mobile/bind',
        operationId: 'ApiUserMobileBind',
        summary: '绑定手机号',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['用户接口'],
    )]
    #[RequestBody(content: new JsonContent(
        ref: UserRequest::class,
        title: '绑定手机号请求参数',
        required: ['mobile', 'vcode', 'code'],
        example: '{ "mobile": "18111111111", "code": "86", "vcode": "123456", "google2fa_code": "123456" }'
    ))]
    #[ResultResponse(instance: new Result())]
    #[Middleware(TokenMiddleware::class)]
    public function mobileBind(UserRequest $request): Result
    {
        $validated = $request->validated();
        $user = $this->userService->user();
        $mobile = $validated['mobile'];
        $vcode = $validated['vcode'];
        $countryCode = (int)($validated['code'] ?? 86);

        $existingUser = $this->userService->findUser(['mobile' => $mobile]);
        if ($existingUser && $existingUser->id !== $user->id) {
            throw new BusinessException(message: trans('auth.mobile_used'));
        }

        if (!empty($user->mobile)) {
            throw new BusinessException(message: trans('auth.mobile_bind'));
        }

        if (!empty($user->google2fa)) {
            if (empty($validated['google2fa_code'])) {
                throw new BusinessException(message: trans('auth.google_code_required'));
            }
            $this->verifyGoogle2fa($user->google2fa, $validated['google2fa_code']);
        }

        $scene = VerifyCodeService::SCENE_BIND;
        if (!VerifyCodeService::verify(
            VerifyCodeService::TYPE_SMS,
            $mobile,
            $vcode,
            $scene,
            countryCode: $countryCode
        )) {
            throw new BusinessException(message: trans('auth.mobile_code_invalid'));
        }

        $user->mobile = $mobile;
        $user->save();
        $this->dispatchUserLoginEvent($user, $request, 4);
        return $this->success(message: trans('auth.bind_success'));
    }

    #[Post(
        path: '/api/user/mobile/unbind',
        operationId: 'ApiUserMobileUnbind',
        summary: '解绑手机号',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['用户接口'],
    )]
    #[RequestBody(content: new JsonContent(
        ref: UserRequest::class,
        title: '解绑手机号请求参数',
        required: ['vcode'],
        example: '{ "code": "86", "vcode": "123456", "google2fa_code": "123456" }'
    ))]
    #[ResultResponse(instance: new Result())]
    #[Middleware(TokenMiddleware::class)]
    public function mobileUnbind(UserRequest $request): Result
    {
        $validated = $request->validated();
        $user = $this->userService->user();
        $vcode = $validated['vcode'];

        if (empty($user->mobile)) {
            throw new BusinessException(message: trans('auth.mobile_unbind'));
        }

        if (!empty($user->google2fa)) {
            if (empty($validated['google2fa_code'])) {
                throw new BusinessException(message: trans('auth.google_code_required'));
            }
            $this->verifyGoogle2fa($user->google2fa, $validated['google2fa_code']);
        }

        $scene = VerifyCodeService::SCENE_BIND;
        $countryCode = (int)($validated['code'] ?? $user->code ?? 86);
        if (!VerifyCodeService::verify(
            VerifyCodeService::TYPE_SMS,
            $user->mobile,
            $vcode,
            $scene,
            countryCode: $countryCode
        )) {
            throw new BusinessException(message: trans('auth.mobile_code_invalid'));
        }

        $user->mobile = null;
        $user->save();
        $this->dispatchUserLoginEvent($user, $request, 6);
        return $this->success(message: trans('auth.unbind_success'));
    }

    #[Get(
        path: '/api/user/accountLogs',
        operationId: 'ApiUserAccountLogs',
        summary: '获取账户日志',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['用户接口'],
    )]
    #[QueryParameter(name: 'page', description: '页码', required: false, example: '1')]
    #[QueryParameter(name: 'page_size', description: '每页数量', required: false, example: '20')]
    #[QueryParameter(name: 'type', description: '日志类型：1:登录,2:注册,3:重置密码,4:绑定手机,5:绑定邮箱,6:解绑手机,7:解绑邮箱,8:禁用账户,9:删除账户,10:绑定2fa,11:解绑2fa', required: false, example: '1')]
    #[ResultResponse(instance: new Result(), example: '{"code":200,"message":"成功","data":{"list":[{"id":1,"type":1,"ip":"192.168.1.1","os":"Android","device_id":"xxx","country":"中国","region":"北京","city":"北京","created_at":"2025-11-29 21:13:44"}],"total":10}}')]
    #[Middleware(TokenMiddleware::class)]
    public function accountLogs(UserRequest $request): Result
    {
        $map['user_id'] = $this->userService->id();
        $type = (int)$request->input('type');
        if ($type) {
            $map['type'] = $type;
        }
        $query = UserAccountLog::query()->where($map);
        if (!$type) $query->where('type', '!=', 1);
        $logs = $query->orderByDesc('id')
            ->simplePaginate($this->getPageSize());
        return $this->success([
            'list' => $logs->items(),
        ]);
    }

    #[Post(
        path: '/api/user/profile/update',
        operationId: 'ApiUserProfileUpdate',
        summary: '更新用户资料',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['用户接口'],
    )]
    #[RequestBody(content: new JsonContent(
        ref: UserRequest::class,
        title: '更新用户资料请求参数',
        example: '{ "nickname": "新昵称" }'
    ))]
    #[ResultResponse(instance: new Result(), example: '{"code":200,"message":"成功","data":{}}')]
    #[Middleware(TokenMiddleware::class)]
    public function profileUpdate(UserRequest $request): Result
    {
        $validated = $request->validated();
        if (!$validated) return $this->success();
        $user = $this->userService->user();
        $user->profile->fill($validated)->save();

        return $this->success(message: trans('user.profile_update_success'));
    }

    #[Post(
        path: '/api/user/resetPassword',
        operationId: 'ApiUserResetPassword',
        summary: '重置密码',
        security: [['Bearer' => [], 'ApiKey' => []]],
        tags: ['用户接口'],
    )]
    #[RequestBody(content: new JsonContent(
        ref: UserRequest::class,
        title: '重置密码请求参数',
    ))]
    #[ResultResponse(instance: new Result(), example: '{"code":200,"vcode":200,"message":"成功","data":{}}')]
    public function resetPassword(UserRequest $request): Result
    {
        $validated = $request->validated();
        $findParams = [];
        if ($validated['type'] == LoginType::MOBILE_CODE->value) {
            $findParams['code'] = $validated['code'];
            $findParams['mobile'] = $validated['mobile'];
        } elseif ($validated['type'] == LoginType::EMAIL_CODE->value) {
            $findParams['email'] = $validated['email'];
        }
        $user = $this->userService->findUser($findParams);
        if (!$user) throw new BusinessException(message: trans('auth.user_not_register'));

        $verifyAgain = $user->google2fa ? 'google2fa_code' : '';

        if ($validated['step'] == 1 && $verifyAgain && empty($validated['google2fa_code'])) {
            return $this->success([
                'verify_again' => $verifyAgain,
            ]);
        }
        if ($validated['step'] == 2 && $user->google2fa) {
            $this->verifyGoogle2fa($user->google2fa, $validated['google2fa_code']);
            return $this->success();
        }
        $scene = VerifyCodeService::SCENE_RESET_PASSWORD;
        if ($validated['type'] == LoginType::EMAIL_CODE->value) {
            if (!VerifyCodeService::verify(
                VerifyCodeService::TYPE_EMAIL,
                $user->email,
                $validated['vcode'],
                $scene
            )) {
                throw new BusinessException(message: trans('auth.email_code_invalid'));
            }
        } else if ($validated['type'] == LoginType::MOBILE_CODE->value) {
            if (!VerifyCodeService::verify(
                VerifyCodeService::TYPE_SMS,
                $user->mobile,
                $validated['vcode'],
                $scene
            )) {
                throw new BusinessException(message: trans('auth.mobile_code_invalid'));
            }
        }
        $user->password = $validated['password'];
        $user->save();
        $this->dispatchUserLoginEvent($user, $request, 3);
        return $this->success();
    }

    /**
     * 分发用户登录事件
     *
     * @param User $user 用户对象
     * @param UserRequest $request 请求对象
     * @param int $type 事件类型
     */
    private function dispatchUserLoginEvent(User $user, UserRequest $request, int $type): void
    {
        Tools::eventDispatcher(new UserAccountEvent(
            $user,
            $request->ip(),
            $request->header('User-Agent') ?: 'unknown',
            $request->os(),
            type: $type
        ));
    }

    /**
     * 验证密码和验证码（通用方法）
     *
     * @param object $user 用户对象
     * @param array $validated 验证后的请求数据
     * @param string $password 密码（如果用户已设置密码则必填）
     * @param string $scene 验证码场景
     */
    private function verifyPasswordAndCode(object $user, array $validated, string $password, string $scene = VerifyCodeService::SCENE_CHANGE): void
    {
        if (!empty($user->getOriginal('password'))) {
            if (empty($password)) {
                throw new BusinessException(message: trans('user.password_required'));
            }
            if (!$user->verifyPassword($password)) {
                throw new BusinessException(message: trans('user.password_error'));
            }
        }

        if (!empty($user->google2fa)) {
            if (empty($validated['google2fa_code'])) {
                throw new BusinessException(message: trans('auth.google_code_required'));
            }
            $this->verifyGoogle2fa($user->google2fa, $validated['google2fa_code']);
        } else if (!empty($user->email)) {
            if (empty($validated['vcode'])) {
                throw new BusinessException(message: trans('auth.email_code_required'));
            }
            if (!VerifyCodeService::verify(
                VerifyCodeService::TYPE_EMAIL,
                $user->email,
                $validated['vcode'],
                $scene
            )) {
                throw new BusinessException(message: trans('auth.email_code_invalid'));
            }
        } else if (!empty($user->mobile)) {
            if (empty($validated['vcode'])) {
                throw new BusinessException(message: trans('auth.mobile_code_required'));
            }
            if (!VerifyCodeService::verify(
                VerifyCodeService::TYPE_SMS,
                $user->mobile,
                $validated['vcode'],
                $scene
            )) {
                throw new BusinessException(message: trans('auth.mobile_code_invalid'));
            }
        }
    }

    /**
     * 验证 Google2FA 验证码
     */
    private function verifyGoogle2fa(string $secret, string $code): void
    {
        if (\Hyperf\Config\config('env') == 'dev') return;
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
     * 生成二维码 Base64
     */
    private function generateQrCodeBase64(string $qrCodeUrl): ?string
    {
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
            }
        }

        try {
            $renderer = new GDLibRenderer(400);
            $writer = new Writer($renderer);
            $qrcodePng = $writer->writeString($qrCodeUrl);
            return 'data:image/png;base64,' . base64_encode($qrcodePng);
        } catch (\Throwable) {
            return null;
        }
    }

}