<?php

declare(strict_types=1);


namespace App\Http;

use App\Common\Event\UserAdminLoginEvent;
use App\Common\Event\UserLoginEvent;
use App\Common\Event\UserRegisterEvent;
use App\Common\IService;
use App\Common\Jwt\JwtFactory;
use App\Common\Jwt\JwtInterface;
use App\Common\ResultCode;
use App\Common\Tools;
use App\Exception\BusinessException;
use App\Exception\JwtInBlackException;
use App\Model\Enums\User\Status;
use App\Model\Enums\User\Type;
use App\Model\User;
use App\Model\UserProfile;
use App\Repository\Permission\UserRepository;
use Lcobucci\JWT\Token\RegisteredClaims;
use Lcobucci\JWT\UnencryptedToken;

class PassportService extends IService
{
    /**
     * @var string jwt场景
     */
    private string $scene = 'default';

    public function __construct(
        protected readonly UserRepository $repository,
        protected readonly JwtFactory     $jwtFactory,
    )
    {
    }

    public function formatToken(User $user, string $ip = '', string $browser = '', string $os = ''): array
    {
        $jwt = $this->getJwt();
        if ($user->status == Status::DISABLE) {
            throw new BusinessException(ResultCode::DISABLED);
        }
        if ($ip) {
            if ($this->scene == 'api') {
                $info = array_merge($user->profile->toArray(), $user->makeHidden(['profile', 'updated_by', 'created_by'])->toArray());
                Tools::setUserCache($user->id, $info);
                Tools::eventDispatcher(new UserLoginEvent($user, $ip, $os, $browser));
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

    public function findUsernamePassword(string $username, string $password, $type = Type::USER): User
    {
        // 支持通过用户名、手机号或邮箱查询
        $user = $this->repository->getQuery()
            ->where('user_type', $type)
            ->where(function ($query) use ($username) {
                $query->where('username', $username)
                    ->orWhere('mobile', $username)
                    ->orWhere('email', $username);
            })
            ->first();
        
        if (!$user || !$user->verifyPassword($password)) {
            throw new BusinessException(ResultCode::UNPROCESSABLE_ENTITY, trans('auth.password_error'));
        }
        return $user;
    }

    public function findUser(array $map): ?User
    {
        return $this->repository->getQuery()->where($map)->first();
    }

    public function create(array $data): mixed
    {
        $md = parent::create($data);
        if ($md->wasRecentlyCreated) {
            UserProfile::query()->create(['user_id' => $md->id]);
        }
        if (!empty($data['invite_code'])) $md->invite_code = $data['invite_code'];
        Tools::eventDispatcher(new UserRegisterEvent($md));
        return $md;
    }

    public function getInfo(int $id): mixed
    {
        return User::query()->with(['profile'])
            ->select(['id', 'username', 'mobile', 'email', 'code'])
            ->find($id);
    }
}
