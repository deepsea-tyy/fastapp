<?php

declare(strict_types=1);


namespace App\Http;

use App\Common\Event\UserAdminLoginEvent;
use App\Common\Event\UserAccountEvent;
use App\Common\Event\UserRegisterEvent;
use App\Common\Jwt\JwtFactory;
use App\Common\Jwt\JwtInterface;
use App\Common\ResultCode;
use App\Common\Tools;
use App\Exception\BusinessException;
use App\Exception\JwtInBlackException;
use App\Model\Enums\User\Status;
use App\Model\User;
use App\Model\UserProfile;
use Hyperf\Context\RequestContext;
use Hyperf\DbConnection\Db;
use Lcobucci\JWT\Token\RegisteredClaims;
use Lcobucci\JWT\UnencryptedToken;

class CurrentUser
{
    /**
     * @var string jwt场景
     */
    private string $scene = 'default';

    public function __construct(
        protected readonly JwtFactory $jwtFactory,
    )
    {
    }

    /**
     * 格式化 Token
     *
     * @param User $user 用户对象
     * @param string $ip IP地址
     * @param string $browser 浏览器/User-Agent
     * @param string $os 操作系统
     * @param string $deviceId 设备唯一标识（iOS/Android/Web通用，可选）
     * @return array Token数据
     */
    public function formatToken(User $user, string $ip = '', string $browser = '', string $os = '', string $deviceId = ''): array
    {
        $jwt = $this->getJwt();
        if ($user->status == Status::DISABLE) {
            throw new BusinessException(ResultCode::DISABLED);
        }
        if ($ip) {
            if ($this->scene == 'api') {
                Tools::setUserCache($user->id, [
                    'email' => $user->email,
                    'code' => $user->code,
                    'mobile' => $user->mobile,
                    'google2fa' => $user->google2fa ?: '',
                    'lang' => $user->profile?->lang ?? 'zh_CN',
                    'trans_password' => $user->profile?->trans_password ?: '',
                ]);
                Tools::eventDispatcher(new UserAccountEvent($user, $ip, $os, $browser, $deviceId, $user->wasRecentlyCreated ? 2 : 1));
            } else {
                Tools::eventDispatcher(new UserAdminLoginEvent($user, $ip, $os, $browser));
            }
        }
        return [
            'access_token' => $jwt->builderAccessToken((string)$user->id)->toString(),
            'refresh_token' => $jwt->builderRefreshToken((string)$user->id)->toString(),
            'expire_at' => (int)$jwt->getConfig('ttl', 0),
        ];
    }

    public function checkJwt(UnencryptedToken $token): void
    {
        $this->getJwt()->hasBlackList($token) && throw new JwtInBlackException();
    }

    public function logout(UnencryptedToken $token): void
    {
        $this->getJwt()->addBlackList($token);
    }

    public function getJwt(): JwtInterface
    {
        return $this->jwtFactory->get($this->scene);
    }

    public function setScene(string $scene): static
    {
        $this->scene = $scene;
        return $this;
    }

    public function refreshToken(UnencryptedToken $token): array
    {
        return value(static function (JwtInterface $jwt) use ($token) {
            $jwt->addBlackList($token);
            return [
                'access_token' => $jwt->builderAccessToken($token->claims()->get(RegisteredClaims::ID))->toString(),
                'refresh_token' => $jwt->builderRefreshToken($token->claims()->get(RegisteredClaims::ID))->toString(),
                'expire_at' => (int)$jwt->getConfig('ttl', 0),
            ];
        }, $this->getJwt());
    }

    public function findUser(array $map): ?User
    {
        return User::query()->where($map)->first();
    }

    public function create(array $data): mixed
    {
        return Db::transaction(function () use ($data) {
            $md = User::create($data);
            if ($md->wasRecentlyCreated) {
                if (empty($md->username)) {
                    $md->username = '@user' . $md->no;
                    $md->save();
                }
                UserProfile::query()->create(['user_id' => $md->id]);
            }
            Tools::eventDispatcher(new UserRegisterEvent($md, $data['invite_code'] ?? ''));
            return $md;
        });
    }

    public function getInfo(?int $id = null): ?User
    {
        return User::query()->with(['profile'])
            ->select(['id', 'username', 'mobile', 'email', 'code', 'google2fa', 'password'])
            ->find($id ?: $this->id());
    }

    public function user(): ?User
    {
        return User::query()->find($this->id());
    }

    public function profile(): ?UserProfile
    {
        return UserProfile::query()->where(['user_id' => $this->id()])->first();
    }

    public function getToken(): ?\Lcobucci\JWT\UnencryptedToken
    {
        return RequestContext::get()->getAttribute('token');
    }

    public function id(): int
    {
        $token = $this->getToken();
        if (!$token) {
            $tokenStr = Tools::getHeader('token');
            if (!$tokenStr) {
                return 0;
            }
            $token = $this->jwtFactory->get($this->scene)->parserAccessToken($tokenStr);
        }
        return (int)$token->claims()->get(RegisteredClaims::ID);
    }
}
