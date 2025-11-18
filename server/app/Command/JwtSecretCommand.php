<?php

declare(strict_types=1);

namespace App\Command;

use Hyperf\Command\Annotation\AsCommand;
use Hyperf\Command\Command;

#[AsCommand(
    signature: 'jwt:secret {--force : 强制更新已存在的密钥} {--length=32 : 密钥长度（字节数）} {--base64 : 生成 Base64 编码的密钥}',
    description: '初始化 JWT_SECRET 和 JWT_API_SECRET 密钥',
)]
class JwtSecretCommand extends Command
{
    private const MIN_LENGTH = 16;
    private const ENV_KEYS = ['JWT_SECRET', 'JWT_API_SECRET'];

    public function handle(): int
    {
        $this->info('开始初始化 JWT 密钥...');

        $length = max((int)$this->option('length'), self::MIN_LENGTH);
        $useBase64 = (bool)$this->option('base64');
        $force = (bool)$this->option('force');

        $envPath = BASE_PATH . '/.env';
        if (!file_exists($envPath)) {
            $this->error('.env 文件不存在，请先创建 .env 文件');
            return self::FAILURE;
        }

        $envContent = file_get_contents($envPath);
        if ($envContent === false) {
            $this->error('无法读取 .env 文件');
            return self::FAILURE;
        }

        // 生成密钥
        $secrets = [
            'JWT_SECRET' => $this->generateSecret($length, $useBase64),
            'JWT_API_SECRET' => $this->generateSecret($length, $useBase64),
        ];

        // 检查是否已存在
        $hasExisting = $this->hasExistingSecrets($envContent);
        if ($hasExisting && !$force) {
            $this->warn('检测到 .env 文件中已存在 JWT 密钥配置');
            $this->info('如需更新，请使用 --force 选项');
            $this->displaySecrets($secrets, false);
            return self::SUCCESS;
        }

        // 更新或添加密钥
        foreach ($secrets as $key => $value) {
            $exists = preg_match("/^{$key}=/m", $envContent);
            $envContent = $this->updateEnvKey($envContent, $key, $value);
            $this->info('✓ 已' . ($exists ? '更新' : '添加') . " {$key}");
        }

        // 写入文件
        if (file_put_contents($envPath, $envContent) === false) {
            $this->error('无法写入 .env 文件');
            return self::FAILURE;
        }

        $this->newLine();
        $this->info('JWT 密钥初始化完成！');
        $this->displaySecrets($secrets, true);

        return self::SUCCESS;
    }

    /**
     * 生成密钥
     */
    private function generateSecret(int $length, bool $useBase64): string
    {
        $bytes = random_bytes($length);
        return $useBase64 ? base64_encode($bytes) : bin2hex($bytes);
    }

    /**
     * 检查是否存在密钥配置
     */
    private function hasExistingSecrets(string $envContent): bool
    {
        foreach (self::ENV_KEYS as $key) {
            if (preg_match("/^{$key}=/m", $envContent)) {
                return true;
            }
        }
        return false;
    }

    /**
     * 更新或添加环境变量
     */
    private function updateEnvKey(string $envContent, string $key, string $value): string
    {
        $pattern = "/^{$key}=.*$/m";
        if (preg_match($pattern, $envContent)) {
            return preg_replace($pattern, "{$key}={$value}", $envContent);
        }
        return rtrim($envContent) . "\n{$key}={$value}\n";
    }

    /**
     * 显示密钥信息
     */
    private function displaySecrets(array $secrets, bool $saved): void
    {
        $this->newLine();
        if (!$saved) {
            $this->info('生成的密钥（仅供参考，未写入文件）:');
        }
        foreach ($secrets as $key => $value) {
            $this->line("{$key}={$value}");
        }
        $this->newLine();
        if ($saved) {
            $this->comment('提示: 请妥善保管这些密钥，不要泄露给他人。');
        }
    }
}

