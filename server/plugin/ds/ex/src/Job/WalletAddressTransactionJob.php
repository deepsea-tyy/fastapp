<?php
/**
 * FastApp.
 * 1/3/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

declare(strict_types=1);

namespace Plugin\Ds\Ex\Job;

use App\Common\Tools;
use Hyperf\AsyncQueue\JobInterface;
use Throwable;

class WalletAddressTransactionJob implements JobInterface
{
    public function __construct(
        public array $transactions,
        public string $chain,
        public string $field,
        public ?string $symbolToken = null
    ) {
    }

    public function handle(): void
    {
        if (empty($this->transactions)) {
            return;
        }
        
        $message = sprintf(
            '[%s] %d transactions: field=%s, token=%s',
            $this->chain,
            count($this->transactions),
            $this->field,
            $this->symbolToken ?? 'native'
        );
        
        // 记录交易详情
        Tools::logAsync(
            json_encode($this->transactions, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES),
            'info',
            'crypto',
            'transfer'
        );
        
        // 记录摘要信息
        Tools::logAsync($message, 'info', 'crypto', 'transfer');
    }

    /**
     * 静态方法用于记录交易日志
     */
    public static function log(array $receivedTransactions, string $chain, string $field, ?string $symbolToken = null): void
    {
        if (empty($receivedTransactions)) {
            return;
        }

        $job = new self($receivedTransactions, $chain, $field, $symbolToken);
        Tools::redisDispatcher($job);
    }

    public function fail(Throwable $e): void
    {
        // TODO: Implement fail() method.
    }

    public function setMaxAttempts(int $maxAttempts): static
    {
        // TODO: Implement setMaxAttempts() method.
    }

    public function getMaxAttempts(): int
    {
        // TODO: Implement getMaxAttempts() method.
    }
}

