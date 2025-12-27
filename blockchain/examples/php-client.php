<?php

/**
 * Blockchain Wallet Service PHP Client
 *
 * 用于调用 Blockchain Wallet Service 的 PHP SDK
 */
class BlockchainWalletClient
{
    private string $baseUrl;
    private int $timeout;

    /**
     * 构造函数
     *
     * @param string $baseUrl API 服务地址，默认 http://localhost:3000
     * @param int $timeout 请求超时时间（秒），默认 30
     */
    public function __construct(string $baseUrl = 'http://localhost:3000', int $timeout = 30)
    {
        $this->baseUrl = rtrim($baseUrl, '/');
        $this->timeout = $timeout;
    }

    /**
     * 发送 HTTP POST 请求
     *
     * @param string $endpoint API 端点
     * @param array $data 请求数据
     * @return array 响应数据
     * @throws Exception
     */
    private function post(string $endpoint, array $data = []): array
    {
        $url = $this->baseUrl . $endpoint;

        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, $this->timeout);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: application/json',
            'Accept: application/json',
        ]);

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        curl_close($ch);

        if ($error) {
            throw new Exception("cURL Error: {$error}");
        }

        $result = json_decode($response, true);

        if (!$result) {
            throw new Exception("Invalid JSON response");
        }

        if (!$result['success']) {
            throw new Exception($result['error'] ?? 'Unknown error');
        }

        return $result['data'];
    }

    /**
     * 健康检查
     */
    public function health(): array
    {
        $ch = curl_init($this->baseUrl . '/health');
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 5);
        $response = curl_exec($ch);
        curl_close($ch);

        return json_decode($response, true);
    }

    // ==================== Bitcoin/Dogecoin/Litecoin ====================

    /**
     * 生成 BTC/DOGE/LTC 钱包
     *
     * @param string $chain 链类型: BTC, DOGE, LTC
     * @param string|null $mnemonic 助记词（可选）
     * @return array
     */
    public function generateBitcoin(string $chain = 'BTC', ?string $mnemonic = null): array
    {
        $data = ['chain' => $chain];
        if ($mnemonic) {
            $data['mnemonic'] = $mnemonic;
        }

        return $this->post('/api/bitcoin/generate', $data);
    }

    /**
     * 从私钥导入 Bitcoin 钱包
     */
    public function importBitcoinFromPrivateKey(string $privateKey, string $chain = 'BTC'): array
    {
        return $this->post('/api/bitcoin/import/privatekey', [
            'privateKey' => $privateKey,
            'chain' => $chain,
        ]);
    }

    /**
     * 从 WIF 导入 Bitcoin 钱包
     */
    public function importBitcoinFromWIF(string $wif, string $chain = 'BTC'): array
    {
        return $this->post('/api/bitcoin/import/wif', [
            'wif' => $wif,
            'chain' => $chain,
        ]);
    }

    // ==================== Ethereum/EVM ====================

    /**
     * 生成 Ethereum/EVM 钱包
     *
     * @param string|null $mnemonic 助记词（可选）
     * @param int $accountIndex 账户索引
     * @return array
     */
    public function generateEthereum(?string $mnemonic = null, int $accountIndex = 0): array
    {
        $data = ['accountIndex' => $accountIndex];
        if ($mnemonic) {
            $data['mnemonic'] = $mnemonic;
        }

        return $this->post('/api/ethereum/generate', $data);
    }

    /**
     * 从私钥导入 Ethereum 钱包
     */
    public function importEthereumFromPrivateKey(string $privateKey): array
    {
        return $this->post('/api/ethereum/import/privatekey', [
            'privateKey' => $privateKey,
        ]);
    }

    /**
     * 生成多个 Ethereum 账户
     */
    public function generateMultipleEthereum(string $mnemonic, int $count = 1, int $startIndex = 0): array
    {
        return $this->post('/api/ethereum/generate/multiple', [
            'mnemonic' => $mnemonic,
            'count' => $count,
            'startIndex' => $startIndex,
        ]);
    }

    /**
     * 验证 Ethereum 地址
     */
    public function validateEthereumAddress(string $address): bool
    {
        $result = $this->post('/api/ethereum/validate', ['address' => $address]);
        return $result['isValid'];
    }

    // ==================== TRON ====================

    /**
     * 生成 TRON 钱包
     */
    public function generateTron(?string $mnemonic = null): array
    {
        $data = [];
        if ($mnemonic) {
            $data['mnemonic'] = $mnemonic;
        }

        return $this->post('/api/tron/generate', $data);
    }

    /**
     * 从私钥导入 TRON 钱包
     */
    public function importTronFromPrivateKey(string $privateKey): array
    {
        return $this->post('/api/tron/import/privatekey', [
            'privateKey' => $privateKey,
        ]);
    }

    /**
     * 随机生成 TRON 钱包
     */
    public function createRandomTron(): array
    {
        return $this->post('/api/tron/create-random');
    }

    // ==================== Solana ====================

    /**
     * 生成 Solana 钱包
     */
    public function generateSolana(?string $mnemonic = null, int $accountIndex = 0): array
    {
        $data = ['accountIndex' => $accountIndex];
        if ($mnemonic) {
            $data['mnemonic'] = $mnemonic;
        }

        return $this->post('/api/solana/generate', $data);
    }

    /**
     * 从私钥导入 Solana 钱包
     */
    public function importSolanaFromPrivateKey(string $privateKey): array
    {
        return $this->post('/api/solana/import/privatekey', [
            'privateKey' => $privateKey,
        ]);
    }

    /**
     * 随机生成 Solana 钱包
     */
    public function createRandomSolana(): array
    {
        return $this->post('/api/solana/create-random');
    }

    // ==================== XRP ====================

    /**
     * 生成 XRP 钱包
     */
    public function generateXRP(?string $mnemonic = null, string $algorithm = 'secp256k1'): array
    {
        $data = ['algorithm' => $algorithm];
        if ($mnemonic) {
            $data['mnemonic'] = $mnemonic;
        }

        return $this->post('/api/xrp/generate', $data);
    }

    /**
     * 从种子导入 XRP 钱包
     */
    public function importXRPFromSeed(string $seed, string $algorithm = 'secp256k1'): array
    {
        return $this->post('/api/xrp/import/seed', [
            'seed' => $seed,
            'algorithm' => $algorithm,
        ]);
    }

    /**
     * 随机生成 XRP 钱包
     */
    public function createRandomXRP(string $algorithm = 'secp256k1'): array
    {
        return $this->post('/api/xrp/create-random', [
            'algorithm' => $algorithm,
        ]);
    }

    // ==================== Cardano ====================

    /**
     * 生成 Cardano 钱包
     */
    public function generateCardano(?string $mnemonic = null, int $accountIndex = 0, int $addressIndex = 0): array
    {
        $data = [
            'accountIndex' => $accountIndex,
            'addressIndex' => $addressIndex,
        ];
        if ($mnemonic) {
            $data['mnemonic'] = $mnemonic;
        }

        return $this->post('/api/cardano/generate', $data);
    }

    /**
     * 从私钥导入 Cardano 钱包
     */
    public function importCardanoFromPrivateKey(string $paymentPrivateKey, ?string $stakingPrivateKey = null): array
    {
        $data = ['paymentPrivateKey' => $paymentPrivateKey];
        if ($stakingPrivateKey) {
            $data['stakingPrivateKey'] = $stakingPrivateKey;
        }

        return $this->post('/api/cardano/import/privatekey', $data);
    }

    // ==================== Polkadot ====================

    /**
     * 生成 Polkadot/Kusama 钱包
     */
    public function generatePolkadot(?string $mnemonic = null, string $network = 'polkadot', string $keyType = 'sr25519'): array
    {
        $data = [
            'network' => $network,
            'keyType' => $keyType,
        ];
        if ($mnemonic) {
            $data['mnemonic'] = $mnemonic;
        }

        return $this->post('/api/polkadot/generate', $data);
    }

    /**
     * 从种子导入 Polkadot 钱包
     */
    public function importPolkadotFromSeed(string $seed, string $network = 'polkadot', string $keyType = 'sr25519'): array
    {
        return $this->post('/api/polkadot/import/seed', [
            'seed' => $seed,
            'network' => $network,
            'keyType' => $keyType,
        ]);
    }

    /**
     * 从 URI 导入 Polkadot 钱包
     */
    public function importPolkadotFromUri(string $uri, string $network = 'polkadot', string $keyType = 'sr25519'): array
    {
        return $this->post('/api/polkadot/import/uri', [
            'uri' => $uri,
            'network' => $network,
            'keyType' => $keyType,
        ]);
    }

    /**
     * 转换 Polkadot 地址格式
     */
    public function convertPolkadotAddress(string $address, string $targetNetwork): string
    {
        $result = $this->post('/api/polkadot/convert', [
            'address' => $address,
            'targetNetwork' => $targetNetwork,
        ]);

        return $result['address'];
    }

    // ==================== 批量生成 ====================

    /**
     * 批量生成多链钱包
     *
     * @param array $chains 链列表，如: ['BTC', 'ETH', 'TRX']
     * @param string|null $mnemonic 助记词（可选，所有链使用同一助记词）
     * @return array
     */
    public function batchGenerate(array $chains, ?string $mnemonic = null): array
    {
        $data = ['chains' => $chains];
        if ($mnemonic) {
            $data['mnemonic'] = $mnemonic;
        }

        return $this->post('/api/batch/generate', $data);
    }
}

// ==================== 使用示例 ====================

// 初始化客户端
$client = new BlockchainWalletClient('http://localhost:3000');

try {
    // 健康检查
    $health = $client->health();
    echo "Service Status: " . $health['status'] . "\n\n";

    // 生成 Ethereum 钱包
    echo "=== Generate Ethereum Wallet ===\n";
    $ethWallet = $client->generateEthereum();
    echo "Address: {$ethWallet['address']}\n";
    echo "Private Key: {$ethWallet['privateKey']}\n";
    echo "Mnemonic: {$ethWallet['mnemonic']}\n\n";

    // 生成 TRON 钱包
    echo "=== Generate TRON Wallet ===\n";
    $trxWallet = $client->generateTron();
    echo "Address (Base58): {$trxWallet['address']['base58']}\n";
    echo "Address (Hex): {$trxWallet['address']['hex']}\n";
    echo "Private Key: {$trxWallet['privateKey']}\n\n";

    // 批量生成多链钱包
    echo "=== Batch Generate Wallets ===\n";
    $wallets = $client->batchGenerate(['BTC', 'ETH', 'TRX', 'SOL']);
    foreach ($wallets as $chain => $wallet) {
        if (isset($wallet['error'])) {
            echo "$chain: Error - {$wallet['error']}\n";
        } else {
            $address = $wallet['address'] ?? ($wallet['address']['base58'] ?? 'N/A');
            echo "$chain: $address\n";
        }
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
