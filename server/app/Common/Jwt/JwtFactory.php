<?php
/**
 * FastApp.
 * 10/19/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Common\Jwt;

use Hyperf\Collection\Arr;
use Hyperf\Contract\ConfigInterface;
use function Hyperf\Support\make;

final class JwtFactory
{
    public function __construct(
        private readonly ConfigInterface $config,
    )
    {
    }

    public function get(string $name = 'default'): JwtInterface
    {
        return make(Jwt::class, [
            'config' => $this->getConfig($name),
        ]);
    }

    // 获取场景配置
    public function getConfig(string $scene): array
    {
        if ($scene === 'default') {
            return $this->config->get($this->getConfigKey());
        }
        return Arr::merge(
            $this->config->get($this->getConfigKey()),
            $this->config->get($this->getConfigKey($scene), [])
        );
    }

    private function getConfigKey(string $name = 'default'): string
    {
        return 'jwt.' . $name;
    }
}