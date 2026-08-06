<?php
/**
 * FastApp.
 * 10/16/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Http\Api\Controller;

use App\Common\AbstractController;
use App\Common\Event\UserAccountEvent;
use App\Common\Middleware\TokenMiddleware;
use App\Common\Result;
use App\Common\Service\TwoFactorAuthService;
use App\Common\Service\VerifyCodeService;
use App\Common\Tools;
use App\Exception\BusinessException;
use App\Http\Api\Request\UserRequest;
use App\Http\CurrentUser;
use App\Model\Enums\User\LoginType;
use App\Model\Enums\User\Status;
use App\Model\Enums\User\Type;
use App\Model\User;
use App\Model\UserAccountLog;
use Hyperf\Collection\Arr;
use Hyperf\HttpServer\Annotation\Controller;
use Hyperf\HttpServer\Annotation\GetMapping;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\HttpServer\Annotation\PostMapping;
use Ramsey\Uuid\Uuid;

#[Controller]
class UserController extends AbstractController
{
    public function __construct(
        private readonly CurrentUser          $currentUser,
        private readonly TwoFactorAuthService $twoFAService,
    )
    {
    }

    #[PostMapping(path: '/api/user/register')]
    public function register(UserRequest $request): Result
    {
        $validated = $request->validated();
        $validated['user_type'] = Type::USER;
        $user = '';
        if ($validated['type'] == LoginType::USERNAME_PASSWORD->value) {
            $user = $this->currentUser->findUser(['username' => $validated['username']]);
            if ($user) return $this->error(Tools::__('user.username_exist'));
            $user = $this->currentUser->create($validated);
        }
        if ($validated['type'] == LoginType::MOBILE_CODE->value) {
            $scene = $validated['scene'] ?? VerifyCodeService::SCENE_REGISTER;
            if (!VerifyCodeService::verify(
                VerifyCodeService::TYPE_SMS,
                $validated['mobile'],
                $validated['vcode'] ?? '',
                $scene,
                countryCode: (int)($validated['code'] ?? 86)
            )) {
                throw new BusinessException(message: '验证码错误或已过期');
            }
            $user = $this->currentUser->create($validated);
        }
        if ($validated['type'] == LoginType::WECHAT_MINI->value) {
            $validated['wxmini_openid'] = $request->post('openid');
            $user = $this->currentUser->create($validated);
        }
        if ($validated['type'] == LoginType::WECHAT_OPEN->value) {
            $validated['wx_openid'] = $request->post('openid');
            $user = $this->currentUser->create($validated);
        }
        if (!$user) throw new BusinessException(message: trans('user.register_fail'));

        $deviceId = $validated['device_id'] ?? '';
        if (empty($deviceId)) {
            $deviceId = Uuid::uuid4()->toString();
        }

        $tokenData = $this->currentUser->setScene('api')->formatToken(
            $user,
            $request->ip(),
            $request->header('User-Agent') ?: 'unknown',
            $request->os(),
            $deviceId
        );
        $tokenData['device_id'] = $deviceId;
        return $this->success($tokenData);
    }

    #[GetMapping(path: '/api/user/isRegister')]
    public function isRegister(): Result
    {
        return $this->success(['status' => $this->currentUser->findUser($this->getRequestData()) ? 1 : 0]);
    }

    #[GetMapping(path: '/api/sms')]
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

    #[PostMapping(path: '/api/user/smsCheck')]
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

    #[PostMapping(path: '/api/user/login')]
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
            $user = $this->currentUser->findUser($findParams);
        } else if ($validated['type'] == LoginType::MOBILE_CODE->value) {
            $user = $this->currentUser->findUser(['mobile' => $validated['mobile']]);
        } else if ($validated['type'] == LoginType::EMAIL_CODE->value) {
            $user = $this->currentUser->findUser(['email' => $validated['mobile']]);
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

        $verifyInfo = $this->twoFAService->detectVerifyMethod($user);
        if ($this->twoFAService->needsVerification($verifyInfo, $validated)) {
            $verifyInfo['device_id'] = $deviceId;
            return $this->success($verifyInfo);
        }

        if ($validated['type'] == LoginType::EMAIL_CODE->value) {
            $scene = $validated['scene'] ?? VerifyCodeService::SCENE_LOGIN;
            if (!VerifyCodeService::verify(
                VerifyCodeService::TYPE_EMAIL,
                $validated['email'],
                $validated['vcode'],
                $scene
            )) {
                throw new BusinessException(message: trans('auth.email_code_invalid'));
            }
        } else if ($validated['type'] == LoginType::MOBILE_CODE->value) {
            $scene = $validated['scene'] ?? VerifyCodeService::SCENE_LOGIN;
            if (!VerifyCodeService::verify(
                VerifyCodeService::TYPE_SMS,
                $validated['mobile'],
                $validated['vcode'],
                $scene,
                countryCode: (int)($validated['code'] ?? 86)
            )) {
                throw new BusinessException(message: trans('auth.mobile_code_invalid'));
            }
        }

        $this->twoFAService->verify($user, $validated, VerifyCodeService::SCENE_LOGIN);

        $tokenData = $this->currentUser->setScene('api')->formatToken(
            $user,
            $request->ip(),
            $request->header('User-Agent') ?: 'unknown',
            $request->os(),
            $deviceId
        );
        $tokenData['device_id'] = $deviceId;
        return $this->success($tokenData);
    }

    #[PostMapping(path: '/api/user/logout')]
    #[Middleware(TokenMiddleware::class)]
    public function logout(): Result
    {
        $this->currentUser->setScene('api')->logout($this->currentUser->getToken());
        return $this->success();
    }

    #[PostMapping(path: '/api/user/refreshToken')]
    public function refreshToken(): Result
    {
        $token = $this->getRequest()->input('refresh_token');
        if (empty($token)) {
            throw new BusinessException(message: trans('jwt.token_required'));
        }
        $pasToken = $this->currentUser->setScene('api')->getJwt()->parserRefreshToken($token);
        $tokenData = $this->currentUser->setScene('api')->refreshToken($pasToken);
        return $this->success($tokenData);
    }

    #[GetMapping(path: '/api/user/info')]
    #[Middleware(TokenMiddleware::class)]
    public function info(): Result
    {
        $info = $this->currentUser->getInfo();
        $info->is_google2fa = $info->google2fa ? 1 : 0;
        $info->is_trans_password = $info->profile?->trans_password ? 1 : 0;
        $info->is_password = $info->getOriginal('password') ? 1 : 0;
        if (class_exists(\Plugin\Ds\Ex\Model\ExKyc::class)) {
            $kyc = \Plugin\Ds\Ex\Model\ExKyc::query()->where(['user_id' => $info->id])->first(['kyc_level', 'status']);
            $info->is_kyc = $kyc?->isKyc() ?? 0;
        }
        return $this->success($info);
    }

    #[PostMapping(path: '/api/user/password/change')]
    #[Middleware(TokenMiddleware::class)]
    public function changePassword(UserRequest $request): Result
    {
        $validated = $request->validated();
        $user = $this->currentUser->user();

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
        $this->twoFAService->verifyPasswordAndTwoFactor($user, $validated, $oldPassword, $scene);

        $user->password = $validated['password'];
        $user->save();

        $this->currentUser->setScene('api')->logout($this->currentUser->getToken());

        return $this->success(message: trans('user.password_change_success'));
    }

    #[PostMapping(path: '/api/user/account/disable')]
    #[Middleware(TokenMiddleware::class)]
    public function disableAccount(UserRequest $request): Result
    {
        $validated = $request->validated();
        $user = $this->currentUser->user();

        $this->twoFAService->verifyPasswordAndTwoFactor($user, $validated, $validated['password'] ?? '', VerifyCodeService::SCENE_CHANGE);

        $user->status = Status::DISABLE->value;
        $user->save();

        $this->currentUser->setScene('api')->logout($this->currentUser->getToken());
        $this->dispatchUserLoginEvent($user, $request, 8);
        return $this->success(message: trans('auth.account_disable_success'));
    }

    #[PostMapping(path: '/api/user/account/delete')]
    #[Middleware(TokenMiddleware::class)]
    public function deleteAccount(UserRequest $request): Result
    {
        $validated = $request->validated();
        $user = $this->currentUser->user();

        $this->twoFAService->verifyPasswordAndTwoFactor($user, $validated, $validated['password'] ?? '', VerifyCodeService::SCENE_CHANGE);

        $parts = array_filter([$user->username ?: '', $user->email ?: "", $user->mobile ?: '']);
        $newUsername = 'del' . implode('|', $parts);

        $user->email = null;
        $user->mobile = null;
        $user->username = $newUsername;
        $user->status = Status::DISABLE->value;
        $user->save();

        $this->currentUser->setScene('api')->logout($this->currentUser->getToken());
        $this->dispatchUserLoginEvent($user, $request, 9);
        return $this->success(message: trans('auth.account_delete_success'));
    }

    #[GetMapping(path: '/api/user/google2fa/qrcode')]
    #[Middleware(TokenMiddleware::class)]
    public function google2faQrcode(): Result
    {
        $user = $this->currentUser->user();

        if (!empty($user->google2fa)) {
            throw new BusinessException(message: trans('auth.google_code_bind'));
        }
        $secret = $this->twoFAService->generateSecret();
        $qrCodeUrl = $this->twoFAService->generateQrCodeUrl($secret, $user->email ?: ($user->username ?: $user->mobile));
        $qrcodeBase64 = $this->twoFAService->generateQrCodeBase64($qrCodeUrl);

        return $this->success([
            'google2fa' => $secret,
            'qrcode' => $qrcodeBase64,
        ]);
    }

    #[PostMapping(path: '/api/user/google2fa/bind')]
    #[Middleware(TokenMiddleware::class)]
    public function google2faBind(UserRequest $request): Result
    {
        $validated = $request->validated();
        $user = $this->currentUser->user();
        $secret = $validated['google2fa'];
        $code = $validated['google2fa_code'];

        if (!empty($user->google2fa)) {
            throw new BusinessException(message: trans('auth.google_code_bind'));
        }

        $this->twoFAService->verifyGoogle2fa($secret, $code);

        $user->google2fa = $secret;
        $user->save();
        $this->dispatchUserLoginEvent($user, $request, 10);
        return $this->success(message: trans('auth.bind_success'));
    }

    #[PostMapping(path: '/api/user/google2fa/unbind')]
    #[Middleware(TokenMiddleware::class)]
    public function google2faUnbind(UserRequest $request): Result
    {
        $validated = $request->validated();
        $user = $this->currentUser->user();
        $code = $validated['google2fa_code'];

        if (empty($user->google2fa)) {
            throw new BusinessException(message: trans('auth.google_code_unbind'));
        }

        $this->twoFAService->verifyGoogle2fa($user->google2fa, $code);
        $user->google2fa = '';
        $user->save();
        $this->dispatchUserLoginEvent($user, $request, 11);
        return $this->success(message: trans('auth.unbind_success'));
    }

    #[PostMapping(path: '/api/user/email/bind')]
    #[Middleware(TokenMiddleware::class)]
    public function emailBind(UserRequest $request): Result
    {
        $validated = $request->validated();
        $user = $this->currentUser->user();
        $email = $validated['email'];
        $vcode = $validated['vcode'];

        $existingUser = $this->currentUser->findUser(['email' => $email]);
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
            $this->twoFAService->verifyGoogle2fa($user->google2fa, $validated['google2fa_code']);
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

    #[PostMapping(path: '/api/user/email/unbind')]
    #[Middleware(TokenMiddleware::class)]
    public function emailUnbind(UserRequest $request): Result
    {
        $validated = $request->validated();
        $user = $this->currentUser->user();
        $vcode = $validated['vcode'];

        if (empty($user->email)) {
            throw new BusinessException(message: trans('auth.email_unbind'));
        }

        if (!empty($user->google2fa)) {
            if (empty($validated['google2fa_code'])) {
                throw new BusinessException(message: trans('auth.google_code_required'));
            }
            $this->twoFAService->verifyGoogle2fa($user->google2fa, $validated['google2fa_code']);
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

    #[PostMapping(path: '/api/user/mobile/bind')]
    #[Middleware(TokenMiddleware::class)]
    public function mobileBind(UserRequest $request): Result
    {
        $validated = $request->validated();
        $user = $this->currentUser->user();
        $mobile = $validated['mobile'];
        $vcode = $validated['vcode'];
        $countryCode = (int)($validated['code'] ?? 86);

        $existingUser = $this->currentUser->findUser(['mobile' => $mobile]);
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
            $this->twoFAService->verifyGoogle2fa($user->google2fa, $validated['google2fa_code']);
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

    #[PostMapping(path: '/api/user/mobile/unbind')]
    #[Middleware(TokenMiddleware::class)]
    public function mobileUnbind(UserRequest $request): Result
    {
        $validated = $request->validated();
        $user = $this->currentUser->user();
        $vcode = $validated['vcode'];

        if (empty($user->mobile)) {
            throw new BusinessException(message: trans('auth.mobile_unbind'));
        }

        if (!empty($user->google2fa)) {
            if (empty($validated['google2fa_code'])) {
                throw new BusinessException(message: trans('auth.google_code_required'));
            }
            $this->twoFAService->verifyGoogle2fa($user->google2fa, $validated['google2fa_code']);
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

    #[GetMapping(path: '/api/user/accountLogs')]
    #[Middleware(TokenMiddleware::class)]
    public function accountLogs(UserRequest $request): Result
    {
        $map['user_id'] = $this->currentUser->id();
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

    #[PostMapping(path: '/api/user/profile/update')]
    #[Middleware(TokenMiddleware::class)]
    public function profileUpdate(UserRequest $request): Result
    {
        $validated = $request->validated();
        if (!$validated) return $this->success();
        if (!empty($validated['username'])) {
            $userId = $this->currentUser->id();
            if (User::query()->where(['username' => $validated['username']])->where('id', '!=', $userId)->exists()) {
                return $this->error('user.username_exist');
            }
            User::query()->where(['id' => $userId])->update(['username' => $validated['username']]);
            return $this->info();
        }
        $profile = $this->currentUser->profile();
        if (!empty($validated['setting'])) {
            $validated['setting'] = array_merge($profile->setting ?: [], $validated['setting']);
        }
        $profile->fill($validated)->save();
        Tools::setUserCache($profile->user_id, array_merge(
            Arr::only($profile->toArray(), ['user_id', 'nickname', 'avatar', 'signed', 'lang']),
            $profile->setting ?: []
        ));
        return $this->success($profile);
    }

    #[PostMapping(path: '/api/user/resetPassword')]
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
        $user = $this->currentUser->findUser($findParams);
        if (!$user) throw new BusinessException(message: trans('auth.user_not_register'));

        $verifyAgain = $user->google2fa ? 'google2fa_code' : '';

        if ($validated['step'] == 1 && $verifyAgain && empty($validated['google2fa_code'])) {
            return $this->success([
                'verify_again' => $verifyAgain,
            ]);
        }
        if ($validated['step'] == 2 && $user->google2fa) {
            $this->twoFAService->verifyGoogle2fa($user->google2fa, $validated['google2fa_code']);
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
                $scene,
                countryCode: (int)($validated['code'] ?? $user->code ?? 86)
            )) {
                throw new BusinessException(message: trans('auth.mobile_code_invalid'));
            }
        }
        $user->password = $validated['password'];
        $user->save();
        $this->dispatchUserLoginEvent($user, $request, 3);
        return $this->success();
    }

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

    #[GetMapping(path: '/api/user/baseInfo')]
    public function baseInfo(): Result
    {
        return $this->success($this->currentUser::baseInfo((int)$this->getRequest()->input('user_id')));
    }

}