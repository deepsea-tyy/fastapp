<?php
/**
 * FastApp.
 * 1/3/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

declare(strict_types=1);

namespace Plugin\Ds\Ex\Process\CryptoTransfer;

use GuzzleHttp\Client;
use Hyperf\Process\AbstractProcess;
use Hyperf\Process\Annotation\Process;
use Olifanton\Interop\Boc\Cell;
use Olifanton\Interop\Bytes;
use Plugin\Ds\Ex\Job\WalletAddressTransactionJob;

#[Process(name: 'TonListenerProcess')]
class TonListenerProcess extends AbstractProcess
{
    protected const TON_DECIMALS = 9;
    protected const USDT_DECIMALS = 9;
    protected const TON_BASE58_ALPHABET = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
    
    protected ?Client $client = null;
    protected int $lastSeqno = 0;
    protected bool $shouldStop = false;

    public function isEnable($server): bool
    {
        return false;
//        return env('APP_ENV') == 'prod';
    }

    public function handle(): void
    {
        //Ton Jetton
        $this->client = new Client();
        
        while (!$this->shouldStop) {
            try {
                $response = $this->client->get(Config::TON_URL . '/api/v3/masterchainInfo');
                $this->lastSeqno = json_decode($response->getBody()->getContents(), true)['last']['seqno'];
                $this->formatData();
            } catch (\Throwable $e) {
                \Hyperf\Support\make(\Hyperf\Contract\StdoutLoggerInterface::class)->error(
                    '[TON] Process error: ' . $e->getMessage()
                );
                sleep(5);
            }
        }
    }

    public function formatData(): void
    {
        while (!$this->shouldStop) {
            $blockShards = [];
            try {
                $response = $this->client->get(Config::TON_URL . '/api/v3/masterchainBlockShards', [
                    'query' => ['seqno' => $this->lastSeqno]
                ]);
                $blockShards = json_decode($response->getBody()->getContents(), true)['blocks'] ?? [];
                $this->lastSeqno++;
            } catch (\Throwable $e) {
                \Hyperf\Support\make(\Hyperf\Contract\StdoutLoggerInterface::class)->warning(
                    '[TON] Failed to get block shards: ' . $e->getMessage()
                );
                sleep(1);
                continue;
            }

            foreach ($blockShards as $blockShard) {
                if ($blockShard['workchain'] == 0) {
                    \Hyperf\Coroutine\go(function () use ($blockShard) {
                        $this->processBlockShard($blockShard);
                    });
                }
            }
            sleep(1);
        }
    }

    protected function processBlockShard(array $blockShard): void
    {
        try {
            $query = [
                'seqno' => $blockShard['seqno'],
                'shard' => $blockShard['shard'],
                'workchain' => 0,
                'sort' => 'desc'
            ];
            $response = $this->client->get(Config::TON_URL . '/api/v3/transactions', [
                'headers' => [
                    'X-Api-Key' => Config::TON_API_KEY
                ],
                'query' => $query,
            ]);
            
            $transactions = json_decode($response->getBody()->getContents(), true)['transactions'] ?? [];
            $tranTon = [];
            $tranUsdt = [];
            
            foreach ($transactions as $transaction) {
                if ($transaction['description']['aborted'] === true 
                    && $transaction['account_state_after']['account_status'] !== 'uninit') {
                    continue;
                }
                
                $in = $transaction['in_msg'] ?? null;
                $out = $transaction['out_msgs'] ?? [];
                
                // 处理收入交易
                if (!empty($in) && empty($out) && !empty($in['source'])) {
                    if ($in['source'] === Config::TON_CONTRACT_ADDRESS_USDT_HEX) {
                        // USDT收入
                        $usdtData = $this->parseUsdtBody($in['message_content']['body'] ?? '');
                        if (!empty($usdtData)) {
                            $tranUsdt[] = [
                                'txid' => $transaction['hash'],
                                'from' => Ton::addressFormat($in['source']),
                                'to' => $usdtData['address'],
                                'value' => $usdtData['amount'],
                            ];
                        }
                    } else {
                        // 本币收入
                        $tranTon[] = [
                            'txid' => $transaction['hash'],
                            'from' => Ton::addressFormat($in['source']),
                            'to' => Ton::addressFormat($in['destination'] ?? ''),
                            'value' => ($in['value'] ?? 0) / (10 ** self::TON_DECIMALS)
                        ];
                    }
                }
                
                // 处理支出交易
                if (empty($in) && !empty($out)) {
                    foreach ($out as $item) {
                        if (empty($item['source'])) {
                            continue;
                        }
                        
                        if ($item['destination'] === Config::TON_CONTRACT_ADDRESS_USDT_HEX) {
                            // USDT支出
                            $usdtData = $this->parseUsdtBody($item['message_content']['body'] ?? '');
                            if (!empty($usdtData)) {
                                $tranUsdt[] = [
                                    'txid' => $transaction['hash'],
                                    'from' => Ton::addressFormat($item['source']),
                                    'to' => $usdtData['address'],
                                    'value' => $usdtData['amount'],
                                ];
                            }
                        } else {
                            // 本币支出
                            $tranTon[] = [
                                'txid' => $transaction['hash'],
                                'from' => Ton::addressFormat($item['source']),
                                'to' => Ton::addressFormat($item['destination'] ?? ''),
                                'value' => ($item['value'] ?? 0) / (10 ** self::TON_DECIMALS)
                            ];
                        }
                    }
                }
            }
            
            if (!empty($tranTon)) {
                $this->handleEvent($tranTon, 'to');
                $this->handleEvent($tranTon, 'from');
            }
            
            if (!empty($tranUsdt)) {
                $this->handleEvent($tranUsdt, 'to', 'USDT');
                $this->handleEvent($tranUsdt, 'from', 'USDT');
            }
        } catch (\Throwable $e) {
            \Hyperf\Support\make(\Hyperf\Contract\StdoutLoggerInterface::class)->error(
                '[TON] Failed to process block shard: ' . $e->getMessage()
            );
        }
    }
    
    public function stop(): bool
    {
        $this->shouldStop = true;
        return true;
    }

    private function handleEvent(array $receivedTransactions, string $field, ?string $symbol_token = null): void
    {
        WalletAddressTransactionJob::log($receivedTransactions, 'TON', $field, $symbol_token);
    }


    private function parseUsdtBody(string $body): array
    {
        $op = bin2hex(substr(base64_decode($body), 0, 4));
        if ($op !== 'b5ee9c72') {
            return [];
        }
        $rootCell = Cell::oneFromBoc($body, true);
        $slice = $rootCell->beginParse();
        $opCode = $slice->loadUint(32)->toBase(16);

        if ($opCode !== 'f8a7ea5') {
            return [];
        }

        $queryId = $slice->loadUint(64)->toBase(16);
        $workchainId = $slice->loadUint(8)->toBase(10);
        $addressHash = Bytes::bytesToHexString($slice->loadBits(256));
        $address = ($workchainId === '255' ? "-1" : $workchainId) . ":" . $addressHash;  // 255 可能表示 -1

        try {
            $amount = $slice->loadCoins();
        } catch (\Exception $e) {
            $amount = $slice->loadUint(128)->toBase(16);
        }

        $amountDecimal = gmp_strval(gmp_init($amount->toBase(10), 16));
        $amountUSDT = bcdiv($amountDecimal, '1000000000', 9);

        return [
            'opCode' => $opCode,
            'queryId' => $queryId,
            'address' => $address,
            'amount' => $amountUSDT,
        ];
    }
}