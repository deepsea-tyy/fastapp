# Blockchain Wallet Service API 文档

区块链钱包离线生成服务，支持多条主流公链的私钥和地址生成。

## 服务端口

默认端口：`3000`

可通过环境变量 `PORT` 自定义端口。

## 健康检查

### GET /health

检查服务是否正常运行。

**响应示例：**
```json
{
  "status": "ok",
  "timestamp": "2025-12-27T10:00:00.000Z"
}
```

---

## 1. Bitcoin / Dogecoin / Litecoin

### POST /api/bitcoin/generate

生成 BTC/DOGE/LTC 钱包。

**请求参数：**
```json
{
  "chain": "BTC",  // 可选: BTC, DOGE, LTC，默认 BTC
  "mnemonic": "word1 word2 ... word12"  // 可选，不提供则自动生成
}
```

**响应示例：**
```json
{
  "success": true,
  "data": {
    "chain": "BTC",
    "mnemonic": "abandon abandon ... art",
    "privateKey": "a1b2c3...",
    "publicKey": "02abc123...",
    "wif": "L1abc...",
    "address": "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa",
    "segwitAddress": "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh",
    "path": "m/44'/0'/0'/0/0"
  }
}
```

### POST /api/bitcoin/import/privatekey

从私钥导入钱包。

**请求参数：**
```json
{
  "privateKey": "a1b2c3d4...",
  "chain": "BTC"  // 可选: BTC, DOGE, LTC
}
```

### POST /api/bitcoin/import/wif

从 WIF 格式私钥导入钱包。

**请求参数：**
```json
{
  "wif": "L1abc...",
  "chain": "BTC"
}
```

---

## 2. Ethereum / EVM 兼容链 (ETH, BNB, Polygon, etc.)

### POST /api/ethereum/generate

生成 EVM 钱包（兼容所有 EVM 链）。

**请求参数：**
```json
{
  "mnemonic": "word1 word2 ... word12",  // 可选
  "accountIndex": 0  // 可选，账户索引，默认 0
}
```

**响应示例：**
```json
{
  "success": true,
  "data": {
    "chain": "EVM",
    "mnemonic": "abandon abandon ... art",
    "privateKey": "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80",
    "publicKey": "0x04a89c...",
    "address": "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
    "path": "m/44'/60'/0'/0/0",
    "accountIndex": 0
  }
}
```

### POST /api/ethereum/import/privatekey

从私钥导入钱包。

**请求参数：**
```json
{
  "privateKey": "0xac0974bec..."  // 支持带或不带 0x 前缀
}
```

### POST /api/ethereum/generate/multiple

从同一助记词生成多个账户。

**请求参数：**
```json
{
  "mnemonic": "word1 word2 ... word12",
  "count": 5,  // 生成账户数量
  "startIndex": 0  // 起始索引
}
```

### POST /api/ethereum/validate

验证以太坊地址是否有效。

**请求参数：**
```json
{
  "address": "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
}
```

**响应示例：**
```json
{
  "success": true,
  "data": {
    "isValid": true
  }
}
```

---

## 3. TRON (TRX)

### POST /api/tron/generate

生成 TRON 钱包。

**请求参数：**
```json
{
  "mnemonic": "word1 word2 ... word12"  // 可选
}
```

**响应示例：**
```json
{
  "success": true,
  "data": {
    "chain": "TRON",
    "mnemonic": "abandon abandon ... art",
    "privateKey": "a1b2c3...",
    "address": {
      "base58": "TXyz123...",  // Base58 格式（T 开头）
      "hex": "41abc123..."     // Hex 格式
    }
  }
}
```

### POST /api/tron/import/privatekey

从私钥导入钱包。

**请求参数：**
```json
{
  "privateKey": "a1b2c3d4..."
}
```

### POST /api/tron/create-random

随机生成 TRON 钱包（不使用助记词）。

**请求参数：** 无

### POST /api/tron/validate

验证 TRON 地址是否有效。

**请求参数：**
```json
{
  "address": "TXyz123..."  // 支持 Base58 或 Hex 格式
}
```

---

## 4. Solana (SOL)

### POST /api/solana/generate

生成 Solana 钱包。

**请求参数：**
```json
{
  "mnemonic": "word1 word2 ... word12",  // 可选
  "accountIndex": 0  // 可选
}
```

**响应示例：**
```json
{
  "success": true,
  "data": {
    "chain": "SOLANA",
    "mnemonic": "abandon abandon ... art",
    "privateKey": "a1b2c3...",
    "publicKey": "7YX8...",
    "address": "7YX8...",  // Solana 地址就是公钥
    "path": "m/44'/501'/0'/0'",
    "accountIndex": 0,
    "secretKey": [1, 2, 3, ...]  // 64 字节完整密钥
  }
}
```

### POST /api/solana/import/privatekey

从私钥导入钱包。

**请求参数：**
```json
{
  "privateKey": "a1b2c3d4..."  // 64 字节（128 个十六进制字符）
}
```

### POST /api/solana/create-random

随机生成 Solana 钱包。

### POST /api/solana/generate/multiple

从同一助记词生成多个账户。

**请求参数：**
```json
{
  "mnemonic": "word1 word2 ... word12",
  "count": 5,
  "startIndex": 0
}
```

---

## 5. XRP (Ripple)

### POST /api/xrp/generate

生成 XRP 钱包。

**请求参数：**
```json
{
  "mnemonic": "word1 word2 ... word12",  // 可选
  "algorithm": "secp256k1"  // 可选: secp256k1 或 ed25519
}
```

**响应示例：**
```json
{
  "success": true,
  "data": {
    "chain": "XRP",
    "mnemonic": "abandon abandon ... art",
    "seed": "sEdV19...",
    "privateKey": "00a1b2c3...",
    "publicKey": "02abc123...",
    "address": "rNaq...",
    "classicAddress": "rNaq...",
    "algorithm": "secp256k1",
    "path": "m/44'/144'/0'/0/0"
  }
}
```

### POST /api/xrp/import/seed

从种子导入钱包。

**请求参数：**
```json
{
  "seed": "sEdV19...",
  "algorithm": "secp256k1"
}
```

### POST /api/xrp/create-random

随机生成 XRP 钱包。

**请求参数：**
```json
{
  "algorithm": "secp256k1"  // 可选
}
```

---

## 6. Cardano (ADA)

### POST /api/cardano/generate

生成 Cardano 钱包。

**请求参数：**
```json
{
  "mnemonic": "word1 word2 ... word24",  // 可选，支持 15 或 24 个词
  "accountIndex": 0,  // 可选
  "addressIndex": 0   // 可选
}
```

**响应示例：**
```json
{
  "success": true,
  "data": {
    "chain": "CARDANO",
    "mnemonic": "abandon abandon ... art",
    "privateKey": {
      "payment": "a1b2c3...",
      "staking": "d4e5f6..."
    },
    "publicKey": {
      "payment": "abc123...",
      "staking": "def456..."
    },
    "address": {
      "base": "addr1qxy...",        // 参与质押的地址
      "enterprise": "addr1vxy..."   // 不参与质押的地址
    },
    "path": "m/1852'/1815'/0'/0/0",
    "accountIndex": 0,
    "addressIndex": 0
  }
}
```

### POST /api/cardano/import/privatekey

从私钥导入钱包。

**请求参数：**
```json
{
  "paymentPrivateKey": "a1b2c3...",
  "stakingPrivateKey": "d4e5f6..."  // 可选
}
```

### POST /api/cardano/generate/multiple

从同一助记词生成多个地址。

**请求参数：**
```json
{
  "mnemonic": "word1 word2 ... word24",
  "count": 5,
  "accountIndex": 0,
  "startIndex": 0
}
```

---

## 7. Polkadot / Kusama (DOT / KSM)

### POST /api/polkadot/generate

生成 Polkadot/Kusama 钱包。

**请求参数：**
```json
{
  "mnemonic": "word1 word2 ... word12",  // 可选
  "network": "polkadot",  // polkadot, kusama, substrate
  "keyType": "sr25519"    // sr25519 (默认) 或 ed25519
}
```

**响应示例：**
```json
{
  "success": true,
  "data": {
    "chain": "POLKADOT",
    "mnemonic": "abandon abandon ... art",
    "seed": "0xa1b2c3...",
    "privateKey": "0xd4e5f6...",
    "publicKey": "0xabc123...",
    "address": "15oF4...",
    "keyType": "sr25519",
    "ss58Format": 0
  }
}
```

### POST /api/polkadot/import/seed

从种子导入钱包。

**请求参数：**
```json
{
  "seed": "0xa1b2c3...",
  "network": "polkadot",
  "keyType": "sr25519"
}
```

### POST /api/polkadot/import/uri

从 Substrate URI 导入钱包。

**请求参数：**
```json
{
  "uri": "//Alice",  // 如: //Alice, //Bob, mnemonic//hard/soft
  "network": "polkadot",
  "keyType": "sr25519"
}
```

### POST /api/polkadot/convert

转换地址格式到不同网络。

**请求参数：**
```json
{
  "address": "15oF4...",
  "targetNetwork": "kusama"
}
```

---

## 8. 批量生成

### POST /api/batch/generate

一次性为多个链生成钱包（使用同一助记词）。

**请求参数：**
```json
{
  "chains": ["BTC", "ETH", "TRX", "SOL", "XRP", "ADA", "DOT"],
  "mnemonic": "word1 word2 ... word12"  // 可选
}
```

**响应示例：**
```json
{
  "success": true,
  "data": {
    "BTC": { ... },
    "ETH": { ... },
    "TRX": { ... },
    "SOL": { ... },
    "XRP": { ... },
    "ADA": { ... },
    "DOT": { ... }
  }
}
```

**支持的链：**
- `BTC`, `DOGE`, `LTC` - Bitcoin 系列
- `ETH`, `BNB`, `EVM` - EVM 兼容链
- `TRX`, `TRON` - TRON
- `SOL`, `SOLANA` - Solana
- `XRP` - Ripple
- `ADA`, `CARDANO` - Cardano
- `DOT`, `POLKADOT` - Polkadot
- `KSM`, `KUSAMA` - Kusama

---

## PHP 调用示例

### 生成以太坊钱包

```php
<?php

$url = 'http://localhost:3000/api/ethereum/generate';
$data = [
    'accountIndex' => 0
];

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json'
]);

$response = curl_exec($ch);
curl_close($ch);

$result = json_decode($response, true);

if ($result['success']) {
    $wallet = $result['data'];
    echo "Address: " . $wallet['address'] . "\n";
    echo "Private Key: " . $wallet['privateKey'] . "\n";
    echo "Mnemonic: " . $wallet['mnemonic'] . "\n";
}
```

### 从私钥导入 TRON 钱包

```php
<?php

$url = 'http://localhost:3000/api/tron/import/privatekey';
$data = [
    'privateKey' => 'your_private_key_here'
];

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json'
]);

$response = curl_exec($ch);
curl_close($ch);

$result = json_decode($response, true);

if ($result['success']) {
    $wallet = $result['data'];
    echo "Base58 Address: " . $wallet['address']['base58'] . "\n";
    echo "Hex Address: " . $wallet['address']['hex'] . "\n";
}
```

### 批量生成多链钱包

```php
<?php

$url = 'http://localhost:3000/api/batch/generate';
$data = [
    'chains' => ['BTC', 'ETH', 'TRX', 'SOL'],
    'mnemonic' => 'your 12 word mnemonic phrase here'
];

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json'
]);

$response = curl_exec($ch);
curl_close($ch);

$result = json_decode($response, true);

if ($result['success']) {
    foreach ($result['data'] as $chain => $wallet) {
        echo "$chain Address: " . $wallet['address'] . "\n";
    }
}
```

---

## 错误处理

所有错误都会返回以下格式：

```json
{
  "success": false,
  "error": "Error message here"
}
```

HTTP 状态码：
- `200` - 成功
- `400` - 请求参数错误
- `404` - 接口不存在
- `500` - 服务器内部错误

---

## 安全建议

1. **私钥安全**：生成的私钥必须安全存储，不要通过网络传输明文私钥
2. **助记词备份**：助记词应当离线备份，妥善保管
3. **网络隔离**：建议在内网环境运行此服务
4. **访问控制**：生产环境应添加身份验证和访问控制
5. **HTTPS**：生产环境必须使用 HTTPS
6. **日志安全**：不要在日志中记录私钥和助记词

---

## 部署说明

### 1. 安装依赖

```bash
cd /Users/wangxiansheng/Workspace/fastapp/blockchain
npm install
```

### 2. 启动服务

```bash
# 开发环境
npm run dev

# 生产环境
npm start
```

### 3. 使用 PM2 部署（推荐）

```bash
# 安装 PM2
npm install -g pm2

# 启动服务
pm2 start src/server.js --name blockchain-wallet

# 查看状态
pm2 status

# 查看日志
pm2 logs blockchain-wallet

# 停止服务
pm2 stop blockchain-wallet

# 重启服务
pm2 restart blockchain-wallet
```

### 4. Docker 部署

可以创建 Dockerfile 进行容器化部署。

---

## 技术栈

- **Node.js** - 运行环境
- **Express.js** - Web 框架
- **bitcoinjs-lib** - Bitcoin/Litecoin/Dogecoin
- **ethers.js** - Ethereum/EVM 链
- **tronweb** - TRON
- **@solana/web3.js** - Solana
- **xrpl** - XRP
- **@emurgo/cardano-serialization-lib** - Cardano
- **@polkadot/keyring** - Polkadot/Kusama
- **bip39** - 助记词生成和验证

---

## 支持的区块链

| 区块链 | 代码 | SDK |
|--------|------|-----|
| Bitcoin | BTC | bitcoinjs-lib |
| Dogecoin | DOGE | bitcoinjs-lib |
| Litecoin | LTC | bitcoinjs-lib |
| Ethereum | ETH | ethers.js |
| BNB Chain | BNB | ethers.js |
| Polygon | MATIC | ethers.js |
| Arbitrum | ARB | ethers.js |
| Optimism | OP | ethers.js |
| TRON | TRX | tronweb |
| Solana | SOL | @solana/web3.js |
| XRP | XRP | xrpl |
| Cardano | ADA | cardano-serialization-lib |
| Polkadot | DOT | @polkadot/keyring |
| Kusama | KSM | @polkadot/keyring |

所有 EVM 兼容链（Ethereum, BSC, Polygon, Arbitrum, Optimism, Avalanche, Fantom 等）都使用相同的钱包格式。
