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
use Plugin\Ds\Ex\Job\WalletAddressTransactionJob;

#[Process(name: 'TrxListenerProcess')]
class TrxListenerProcess extends AbstractProcess
{
    protected const TRX_DECIMALS = 6;
    protected const USDT_DECIMALS = 6;
    protected const TRC20_TRANSFER_METHOD_ID = 'a9059cbb';
    protected const BASE58_ALPHABET = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
    
    protected ?Client $client = null;
    protected bool $shouldStop = false;

    public function isEnable($server): bool
    {
        return false;
        // return env('APP_ENV') === 'prod';
    }

    public function handle(): void
    {
        // Tron (TRC-20)
        $this->client = new Client();
        
        while (!$this->shouldStop) {
            try {
                $this->formatData();
            } catch (\Throwable $e) {
                \Hyperf\Support\make(\Hyperf\Contract\StdoutLoggerInterface::class)->error(
                    '[TRX] Process error: ' . $e->getMessage()
                );
                sleep(5);
            }
        }
    }

    protected function formatData(): void
    {
        $response = $this->client->post(Config::TRX_URL . '/wallet/getnowblock', [
            'headers' => ['Content-Type' => 'application/json']
        ]);
        
        $blockData = json_decode($response->getBody()->getContents(), true);
        if (!isset($blockData['transactions'])) {
            sleep(2);
            return;
        }
        
        $tranTrx = [];
        $tranUsdt = [];
        
        foreach ($blockData['transactions'] as $transaction) {
            if (empty($transaction['raw_data']['contract'][0])) {
                continue;
            }
            
            $contract = $transaction['raw_data']['contract'][0];
            if (empty($contract['type'])) {
                continue;
            }
            
            // 处理TRX本币转账
            if ($contract['type'] === 'TransferContract') {
                $tranTrx[] = [
                    'txid' => $transaction['txID'],
                    'from' => $this->hexToBase58($contract['parameter']['value']['owner_address']),
                    'to' => $this->hexToBase58($contract['parameter']['value']['to_address']),
                    'value' => $contract['parameter']['value']['amount'] / (10 ** self::TRX_DECIMALS)
                ];
            }
            
            // 处理TRC20 USDT转账
            if ($contract['type'] === 'TriggerSmartContract') {
                $contractAddress = $this->hexToBase58($contract['parameter']['value']['contract_address'] ?? '');
                if ($contractAddress === Config::TRC20_CONTRACT_ADDRESS_USDT) {
                    $trc20Data = $this->decodeTRC20Data(
                        $contract['parameter']['value']['owner_address'] ?? '',
                        $contract['parameter']['value']['data'] ?? ''
                    );
                    if ($trc20Data !== null) {
                        $trc20Data['txid'] = $transaction['txID'];
                        $tranUsdt[] = $trc20Data;
                    }
                }
            }
        }
        
        if (!empty($tranTrx)) {
            $this->handleEvent($tranTrx, 'to');
            $this->handleEvent($tranTrx, 'from');
        }
        
        if (!empty($tranUsdt)) {
            $this->handleEvent($tranUsdt, 'to', 'USDT');
            $this->handleEvent($tranUsdt, 'from', 'USDT');
        }
        
        sleep(2);
    }
    
    public function stop(): bool
    {
        $this->shouldStop = true;
        return true;
    }

    private function handleEvent(array $receivedTransactions, string $field, ?string $symbol_token = null): void
    {
        WalletAddressTransactionJob::log($receivedTransactions, 'TRX', $field, $symbol_token);
    }

    protected function decodeTRC20Data(string $from, string $data): ?array
    {
        if (strlen($data) < 72) {
            return null;
        }
        
        $methodId = substr($data, 0, 8);
        if ($methodId !== self::TRC20_TRANSFER_METHOD_ID) {
            return null;
        }
        
        $toAddressHex = substr($data, 8, 64);
        $toAddress = '41' . substr($toAddressHex, 24);
        $toBase58 = $this->hexToBase58($toAddress);
        
        $valueHex = substr($data, 72, 64);
        $value = hexdec($valueHex);
        $fromBase58 = $this->hexToBase58($from);
        
        return [
            'from' => $fromBase58,
            'to' => $toBase58,
            'value' => $value / (10 ** self::USDT_DECIMALS)
        ];
    }

    protected function hexToBase58(string $hexAddress): string
    {
        $binAddress = hex2bin($hexAddress);
        $hash1 = hash('sha256', $binAddress, true);
        $hash2 = hash('sha256', $hash1, true);
        $checksum = substr($hash2, 0, 4);
        $addressWithChecksum = $binAddress . $checksum;
        return $this->base58Encode($addressWithChecksum);
    }

    protected function base58Encode(string $string): string
    {
        $base = strlen(self::BASE58_ALPHABET);
        $num = gmp_init(bin2hex($string), 16);
        $encode = '';
        
        while (gmp_cmp($num, 0) > 0) {
            [$num, $rem] = gmp_div_qr($num, $base);
            $encode = self::BASE58_ALPHABET[gmp_intval($rem)] . $encode;
        }
        
        foreach (str_split($string) as $byte) {
            if ($byte !== "\0") {
                break;
            }
            $encode = self::BASE58_ALPHABET[0] . $encode;
        }
        
        return $encode;
    }
}