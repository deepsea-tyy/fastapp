import express from 'express';
import cors from 'cors';
import bitcoinWallet from './wallets/bitcoin.js';
import ethereumWallet from './wallets/ethereum.js';
import tronWallet from './wallets/tron.js';
import solanaWallet from './wallets/solana.js';
import xrpWallet from './wallets/xrp.js';
import cardanoWallet from './wallets/cardano.js';
import polkadotWallet from './wallets/polkadot.js';

const app = express();
const PORT = process.env.PORT || 3000;

// 中间件
app.use(cors());
app.use(express.json());

// 错误处理中间件
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

// 健康检查
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// ==================== Bitcoin/Dogecoin/Litecoin ====================

// 生成 BTC/DOGE/LTC 钱包
app.post('/api/bitcoin/generate', asyncHandler(async (req, res) => {
  const { chain = 'BTC', mnemonic } = req.body;
  const wallet = bitcoinWallet.generateWallet(chain, mnemonic);
  res.json({ success: true, data: wallet });
}));

// 从私钥导入
app.post('/api/bitcoin/import/privatekey', asyncHandler(async (req, res) => {
  const { privateKey, chain = 'BTC' } = req.body;
  const wallet = bitcoinWallet.importFromPrivateKey(privateKey, chain);
  res.json({ success: true, data: wallet });
}));

// 从 WIF 导入
app.post('/api/bitcoin/import/wif', asyncHandler(async (req, res) => {
  const { wif, chain = 'BTC' } = req.body;
  const wallet = bitcoinWallet.importFromWIF(wif, chain);
  res.json({ success: true, data: wallet });
}));

// ==================== Ethereum/EVM ====================

// 生成 EVM 钱包
app.post('/api/ethereum/generate', asyncHandler(async (req, res) => {
  const { mnemonic, accountIndex = 0 } = req.body;
  const wallet = ethereumWallet.generateWallet(mnemonic, accountIndex);
  res.json({ success: true, data: wallet });
}));

// 从私钥导入
app.post('/api/ethereum/import/privatekey', asyncHandler(async (req, res) => {
  const { privateKey } = req.body;
  const wallet = ethereumWallet.importFromPrivateKey(privateKey);
  res.json({ success: true, data: wallet });
}));

// 生成多个账户
app.post('/api/ethereum/generate/multiple', asyncHandler(async (req, res) => {
  const { mnemonic, count = 1, startIndex = 0 } = req.body;
  const wallets = ethereumWallet.generateMultipleAccounts(mnemonic, count, startIndex);
  res.json({ success: true, data: wallets });
}));

// 验证地址
app.post('/api/ethereum/validate', asyncHandler(async (req, res) => {
  const { address } = req.body;
  const isValid = ethereumWallet.isValidAddress(address);
  res.json({ success: true, data: { isValid } });
}));

// ==================== TRON ====================

// 生成 TRON 钱包
app.post('/api/tron/generate', asyncHandler(async (req, res) => {
  const { mnemonic } = req.body;
  const wallet = tronWallet.generateWallet(mnemonic);
  res.json({ success: true, data: wallet });
}));

// 从私钥导入
app.post('/api/tron/import/privatekey', asyncHandler(async (req, res) => {
  const { privateKey } = req.body;
  const wallet = tronWallet.importFromPrivateKey(privateKey);
  res.json({ success: true, data: wallet });
}));

// 随机生成
app.post('/api/tron/create-random', asyncHandler(async (req, res) => {
  const wallet = tronWallet.createRandom();
  res.json({ success: true, data: wallet });
}));

// 验证地址
app.post('/api/tron/validate', asyncHandler(async (req, res) => {
  const { address } = req.body;
  const isValid = tronWallet.isValidAddress(address);
  res.json({ success: true, data: { isValid } });
}));

// ==================== Solana ====================

// 生成 Solana 钱包
app.post('/api/solana/generate', asyncHandler(async (req, res) => {
  const { mnemonic, accountIndex = 0 } = req.body;
  const wallet = solanaWallet.generateWallet(mnemonic, accountIndex);
  res.json({ success: true, data: wallet });
}));

// 从私钥导入
app.post('/api/solana/import/privatekey', asyncHandler(async (req, res) => {
  const { privateKey } = req.body;
  const wallet = solanaWallet.importFromPrivateKey(privateKey);
  res.json({ success: true, data: wallet });
}));

// 随机生成
app.post('/api/solana/create-random', asyncHandler(async (req, res) => {
  const wallet = solanaWallet.createRandom();
  res.json({ success: true, data: wallet });
}));

// 生成多个账户
app.post('/api/solana/generate/multiple', asyncHandler(async (req, res) => {
  const { mnemonic, count = 1, startIndex = 0 } = req.body;
  const wallets = solanaWallet.generateMultipleAccounts(mnemonic, count, startIndex);
  res.json({ success: true, data: wallets });
}));

// ==================== XRP ====================

// 生成 XRP 钱包
app.post('/api/xrp/generate', asyncHandler(async (req, res) => {
  const { mnemonic, algorithm = 'secp256k1' } = req.body;
  const wallet = xrpWallet.generateWallet(mnemonic, algorithm);
  res.json({ success: true, data: wallet });
}));

// 从种子导入
app.post('/api/xrp/import/seed', asyncHandler(async (req, res) => {
  const { seed, algorithm = 'secp256k1' } = req.body;
  const wallet = xrpWallet.importFromSeed(seed, algorithm);
  res.json({ success: true, data: wallet });
}));

// 随机生成
app.post('/api/xrp/create-random', asyncHandler(async (req, res) => {
  const { algorithm = 'secp256k1' } = req.body;
  const wallet = xrpWallet.createRandom(algorithm);
  res.json({ success: true, data: wallet });
}));

// ==================== Cardano ====================

// 生成 Cardano 钱包
app.post('/api/cardano/generate', asyncHandler(async (req, res) => {
  const { mnemonic, accountIndex = 0, addressIndex = 0 } = req.body;
  const wallet = cardanoWallet.generateWallet(mnemonic, accountIndex, addressIndex);
  res.json({ success: true, data: wallet });
}));

// 从私钥导入
app.post('/api/cardano/import/privatekey', asyncHandler(async (req, res) => {
  const { paymentPrivateKey, stakingPrivateKey } = req.body;
  const wallet = cardanoWallet.importFromPrivateKey(paymentPrivateKey, stakingPrivateKey);
  res.json({ success: true, data: wallet });
}));

// 生成多个地址
app.post('/api/cardano/generate/multiple', asyncHandler(async (req, res) => {
  const { mnemonic, count = 1, accountIndex = 0, startIndex = 0 } = req.body;
  const wallets = cardanoWallet.generateMultipleAddresses(mnemonic, count, accountIndex, startIndex);
  res.json({ success: true, data: wallets });
}));

// ==================== Polkadot ====================

// 生成 Polkadot 钱包
app.post('/api/polkadot/generate', asyncHandler(async (req, res) => {
  const { mnemonic, network = 'polkadot', keyType = 'sr25519' } = req.body;
  const wallet = polkadotWallet.generateWallet(mnemonic, network, keyType);
  res.json({ success: true, data: wallet });
}));

// 从种子导入
app.post('/api/polkadot/import/seed', asyncHandler(async (req, res) => {
  const { seed, network = 'polkadot', keyType = 'sr25519' } = req.body;
  const wallet = polkadotWallet.importFromSeed(seed, network, keyType);
  res.json({ success: true, data: wallet });
}));

// 从 URI 导入
app.post('/api/polkadot/import/uri', asyncHandler(async (req, res) => {
  const { uri, network = 'polkadot', keyType = 'sr25519' } = req.body;
  const wallet = polkadotWallet.importFromUri(uri, network, keyType);
  res.json({ success: true, data: wallet });
}));

// 转换地址格式
app.post('/api/polkadot/convert', asyncHandler(async (req, res) => {
  const { address, targetNetwork } = req.body;
  const convertedAddress = polkadotWallet.convertAddress(address, targetNetwork);
  res.json({ success: true, data: { address: convertedAddress } });
}));

// ==================== 通用接口 ====================

// 批量生成钱包
app.post('/api/batch/generate', asyncHandler(async (req, res) => {
  const { chains, mnemonic } = req.body;

  if (!Array.isArray(chains) || chains.length === 0) {
    return res.status(400).json({ success: false, error: 'chains must be a non-empty array' });
  }

  const wallets = {};

  for (const chain of chains) {
    try {
      switch (chain.toUpperCase()) {
        case 'BTC':
        case 'DOGE':
        case 'LTC':
          wallets[chain] = bitcoinWallet.generateWallet(chain.toUpperCase(), mnemonic);
          break;
        case 'ETH':
        case 'BNB':
        case 'EVM':
          wallets[chain] = ethereumWallet.generateWallet(mnemonic);
          break;
        case 'TRX':
        case 'TRON':
          wallets[chain] = tronWallet.generateWallet(mnemonic);
          break;
        case 'SOL':
        case 'SOLANA':
          wallets[chain] = solanaWallet.generateWallet(mnemonic);
          break;
        case 'XRP':
          wallets[chain] = xrpWallet.generateWallet(mnemonic);
          break;
        case 'ADA':
        case 'CARDANO':
          wallets[chain] = cardanoWallet.generateWallet(mnemonic);
          break;
        case 'DOT':
        case 'POLKADOT':
          wallets[chain] = polkadotWallet.generateWallet(mnemonic, 'polkadot');
          break;
        case 'KSM':
        case 'KUSAMA':
          wallets[chain] = polkadotWallet.generateWallet(mnemonic, 'kusama');
          break;
        default:
          wallets[chain] = { error: `Unsupported chain: ${chain}` };
      }
    } catch (error) {
      wallets[chain] = { error: error.message };
    }
  }

  res.json({ success: true, data: wallets });
}));

// 错误处理
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    success: false,
    error: err.message || 'Internal server error',
  });
});

// 404 处理
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: 'Endpoint not found',
  });
});

// 启动服务器
app.listen(PORT, () => {
  console.log(`🚀 Blockchain Wallet Service running on port ${PORT}`);
  console.log(`📍 Health check: http://localhost:${PORT}/health`);
  console.log(`📚 Supported chains: BTC, DOGE, LTC, ETH/EVM, TRON, Solana, XRP, Cardano, Polkadot`);
});

export default app;
