# 快速开始指南

## 1. 系统要求

- **Node.js**: >= 18.0.0
- **NPM**: >= 9.0.0
- **操作系统**: Linux, macOS, Windows

## 2. 安装步骤

### 方法一：使用安装脚本（推荐）

```bash
cd /Users/wangxiansheng/Workspace/fastapp/blockchain
./install.sh
```

### 方法二：手动安装

```bash
cd /Users/wangxiansheng/Workspace/fastapp/blockchain

# 安装依赖
npm install

# 复制环境变量配置
cp .env.example .env
```

## 3. 启动服务

### 开发模式（热重载）

```bash
npm run dev
```

### 生产模式

```bash
npm start
```

服务将在 `http://localhost:3000` 启动。

## 4. 验证服务

### 健康检查

```bash
curl http://localhost:3000/health
```

预期响应：
```json
{
  "status": "ok",
  "timestamp": "2025-12-27T10:00:00.000Z"
}
```

### 生成以太坊钱包

```bash
curl -X POST http://localhost:3000/api/ethereum/generate \
  -H "Content-Type: application/json" \
  -d '{}'
```

## 5. PHP 集成示例

```php
<?php

$url = 'http://localhost:3000/api/ethereum/generate';

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([]));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);

$response = curl_exec($ch);
curl_close($ch);

$result = json_decode($response, true);

if ($result['success']) {
    echo "Address: " . $result['data']['address'] . "\n";
    echo "Private Key: " . $result['data']['privateKey'] . "\n";
}
```

## 6. 使用 PHP SDK

```php
<?php

require_once __DIR__ . '/examples/php-client.php';

$client = new BlockchainWalletClient('http://localhost:3000');

// 生成以太坊钱包
$wallet = $client->generateEthereum();
echo "ETH Address: " . $wallet['address'] . "\n";

// 批量生成多链钱包
$wallets = $client->batchGenerate(['BTC', 'ETH', 'TRX', 'SOL']);
foreach ($wallets as $chain => $wallet) {
    echo "$chain: " . ($wallet['address'] ?? 'Error') . "\n";
}
```

## 7. 生产部署

### 使用 PM2（推荐）

```bash
# 安装 PM2
npm install -g pm2

# 启动服务
pm2 start src/server.js --name blockchain-wallet

# 开机自启
pm2 startup
pm2 save

# 查看状态
pm2 status

# 查看日志
pm2 logs blockchain-wallet
```

### 使用 Docker

创建 `Dockerfile`：

```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 3000

CMD ["node", "src/server.js"]
```

构建并运行：

```bash
docker build -t blockchain-wallet .
docker run -d -p 3000:3000 --name blockchain-wallet blockchain-wallet
```

### 使用 systemd

创建服务文件 `/etc/systemd/system/blockchain-wallet.service`：

```ini
[Unit]
Description=Blockchain Wallet Service
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/path/to/blockchain
ExecStart=/usr/bin/node src/server.js
Restart=always
Environment=NODE_ENV=production
Environment=PORT=3000

[Install]
WantedBy=multi-user.target
```

启动服务：

```bash
sudo systemctl daemon-reload
sudo systemctl enable blockchain-wallet
sudo systemctl start blockchain-wallet
sudo systemctl status blockchain-wallet
```

## 8. 配置 Nginx 反向代理

```nginx
upstream blockchain_wallet {
    server 127.0.0.1:3000;
}

server {
    listen 80;
    server_name wallet-api.example.com;

    location / {
        proxy_pass http://blockchain_wallet;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## 9. 安全建议

1. **网络隔离**: 建议在内网环境运行，不对外暴露
2. **HTTPS**: 生产环境必须使用 HTTPS
3. **访问控制**: 添加 API Key 或 JWT 认证
4. **日志安全**: 不记录敏感信息（私钥、助记词）
5. **备份**: 定期备份配置文件

## 10. 监控和日志

### 日志位置

- PM2 日志：`~/.pm2/logs/`
- 应用日志：控制台输出

### 监控指标

```bash
# 查看进程状态
pm2 status

# 查看资源使用
pm2 monit

# 查看详细信息
pm2 show blockchain-wallet
```

## 11. 故障排查

### 端口被占用

```bash
# 查看端口占用
lsof -i :3000

# 修改端口
# 在 .env 文件中设置: PORT=3001
```

### 依赖安装失败

```bash
# 清除缓存
npm cache clean --force

# 删除 node_modules
rm -rf node_modules package-lock.json

# 重新安装
npm install
```

### 服务无法启动

```bash
# 检查 Node.js 版本
node --version  # 应该 >= 18.0.0

# 查看详细错误
npm run dev
```

## 12. 支持的区块链

| 区块链 | 代码 | 状态 |
|--------|------|------|
| Bitcoin | BTC | ✅ |
| Dogecoin | DOGE | ✅ |
| Litecoin | LTC | ✅ |
| Ethereum | ETH | ✅ |
| BNB Chain | BNB | ✅ |
| TRON | TRX | ✅ |
| Solana | SOL | ✅ |
| XRP | XRP | ✅ |
| Cardano | ADA | ✅ |
| Polkadot | DOT | ✅ |
| Kusama | KSM | ✅ |

所有 EVM 兼容链（Polygon, Arbitrum, Optimism, Avalanche 等）都支持。

## 13. 常见问题

**Q: 可以在 Windows 上运行吗？**
A: 可以，但推荐使用 Linux 或 macOS。

**Q: 支持生成多个地址吗？**
A: 支持，可以使用 `generate/multiple` 接口或通过不同的 accountIndex。

**Q: 私钥存储在哪里？**
A: 本服务不存储私钥，所有操作都是离线生成，调用方需自行存储。

**Q: 如何更新服务？**
A: 拉取最新代码后，运行 `npm install` 更新依赖，然后重启服务。

## 14. 更多信息

- 📚 完整 API 文档：[README.md](README.md)
- 💻 PHP SDK 示例：[examples/php-client.php](examples/php-client.php)
- 🧪 测试文件：[test/test.js](test/test.js)

---

**需要帮助？**

- GitHub Issues: [创建 Issue](https://github.com/your-repo/issues)
- 技术支持: support@example.com
