<?php
/**
 * FastApp.
 * 1/3/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

declare(strict_types=1);

namespace Plugin\Ds\Ex\Process\CryptoTransfer;

use Hyperf\Process\AbstractProcess;
use Hyperf\WebSocketClient\Client;
use Hyperf\WebSocketClient\ClientFactory;
use Hyperf\WebSocketClient\Frame;
use Plugin\Ds\Ex\Job\WalletAddressTransactionJob;

abstract class AbstractCryptoListenerProcess extends AbstractProcess
{
    protected const BATCH_SIZE = 50;
    protected const NATIVE_TOKEN_DECIMALS = 18;
    protected const USDT_DECIMALS = 6;
    protected const TRANSFER_EVENT_TOPIC = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef';

    protected ?Client $client = null;
    protected bool $shouldStop = false;

    abstract protected function getChainName(): string;
    abstract protected function getWebSocketUrl(): string;
    abstract protected function getUsdtContractAddress(): string;

    public function stop(): bool
    {
        $this->shouldStop = true;
        if ($this->client !== null) {
            return $this->client->close();
        }
        return true;
    }

    public function isEnable($server): bool
    {
        return false;
        // return env('APP_ENV') === 'prod';
    }

    public function handle(): void
    {
        while (!$this->shouldStop) {
            try {
                $this->initClient();
                $this->formatData();
            } catch (\Throwable $e) {
                \Hyperf\Support\make(\Hyperf\Contract\StdoutLoggerInterface::class)->error(
                    sprintf('[%s] Process error: %s', $this->getChainName(), $e->getMessage())
                );
                // 等待5秒后重连
                sleep(5);
            }
        }
    }

    protected function initClient(): void
    {
        $clientFactory = \Hyperf\Context\ApplicationContext::getContainer()->get(ClientFactory::class);
        $this->client = $clientFactory->create('wss://' . $this->getWebSocketUrl(), false);
        
        // 订阅新区块
        $this->client->push(json_encode([
            'jsonrpc' => '2.0',
            'id' => time(),
            'method' => 'eth_subscribe',
            'params' => ['newHeads'],
        ]));
        
        // 订阅USDT转账事件
        $this->client->push(json_encode([
            'jsonrpc' => '2.0',
            'id' => 1,
            'method' => 'eth_subscribe',
            'params' => [
                'logs',
                [
                    'address' => $this->getUsdtContractAddress(),
                    'topics' => [
                        self::TRANSFER_EVENT_TOPIC,
                        null,
                        null
                    ],
                ],
            ],
        ]));
    }

    protected function formatData(): void
    {
        $tranNative = [];
        $tranUsdt = [];
        
        while (!$this->shouldStop) {
            try {
                /** @var Frame $frame */
                $frame = $this->client->recv();
            } catch (\Throwable $e) {
                throw $e; // 重新抛出异常，让handle方法处理重连
            }
            
            if ($frame === null) {
                continue;
            }
            
            $response = json_decode($frame->data, true);
            if (!is_array($response)) {
                continue;
            }
            
            // 处理新区块通知
            if (isset($response['method']) 
                && $response['method'] === 'eth_subscription' 
                && isset($response['params']['result']['hash'])) {
                $this->client->push(json_encode([
                    'jsonrpc' => '2.0',
                    'id' => time(),
                    'method' => 'eth_getBlockByHash',
                    'params' => [$response['params']['result']['hash'], true],
                ]));
                continue;
            }
            
            // 处理区块交易数据
            if (isset($response['result']['transactions'])) {
                foreach ($response['result']['transactions'] as $tx) {
                    if (empty($tx['from']) || empty($tx['to'])) {
                        continue;
                    }
                    
                    // 原生币转账（value > 0 且 input 为空）
                    if (hexdec($tx['value']) > 0 
                        && ($tx['input'] === '0x' || $tx['input'] === '0x0')) {
                        $tranNative[] = [
                            'txid' => $tx['hash'],
                            'from' => $tx['from'],
                            'to' => $tx['to'],
                            'value' => hexdec($tx['value']) / (10 ** self::NATIVE_TOKEN_DECIMALS),
                        ];
                    }
                }
            }
            
            // 处理USDT转账事件
            if (isset($response['params']['result']['topics'])) {
                $tranUsdt[] = [
                    'txid' => $response['params']['result']['transactionHash'],
                    'from' => '0x' . substr($response['params']['result']['topics'][1], 26),
                    'to' => '0x' . substr($response['params']['result']['topics'][2], 26),
                    'value' => hexdec($response['params']['result']['data']) / (10 ** self::USDT_DECIMALS),
                ];
            }
            
            // 批量处理交易
            if (count($tranNative) >= self::BATCH_SIZE) {
                $this->handleEvent($tranNative, 'to');
                $this->handleEvent($tranNative, 'from');
                $tranNative = [];
            }
            
            if (count($tranUsdt) >= self::BATCH_SIZE) {
                $this->handleEvent($tranUsdt, 'to', 'USDT');
                $this->handleEvent($tranUsdt, 'from', 'USDT');
                $tranUsdt = [];
            }
        }
    }

    protected function handleEvent(array $receivedTransactions, string $field, ?string $symbolToken = null): void
    {
        WalletAddressTransactionJob::log($receivedTransactions, $this->getChainName(), $field, $symbolToken);
    }
}

