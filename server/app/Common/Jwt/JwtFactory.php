<?php
/**
 * FastApp.
 * 10/19/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Common\Jwt;

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
            'config' => $this->config->get('jwt.' . $name),
        ]);
    }
}