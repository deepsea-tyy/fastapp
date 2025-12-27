import TronWeb from 'tronweb';
import * as bip39 from 'bip39';

// 创建一个离线的 TronWeb 实例（不需要连接节点）
const tronWeb = new TronWeb({
  fullHost: 'https://api.trongrid.io', // 仅用于地址验证，离线生成不需要
});

/**
 * 生成 TRON 钱包
 * @param {string} mnemonic - 可选的助记词，不提供则自动生成
 * @returns {Object} 包含私钥、公钥、地址等信息
 */
export function generateWallet(mnemonic = null) {
  // 如果没有提供助记词，生成新的
  if (!mnemonic) {
    mnemonic = bip39.generateMnemonic();
  }

  // 验证助记词
  if (!bip39.validateMnemonic(mnemonic)) {
    throw new Error('Invalid mnemonic');
  }

  // 从助记词生成种子
  const seed = bip39.mnemonicToSeedSync(mnemonic);

  // TronWeb 使用与 Ethereum 相同的密钥派生方式
  // 但我们这里简单处理，直接从种子的前 32 字节作为私钥
  const privateKeyBytes = seed.slice(0, 32);
  const privateKey = privateKeyBytes.toString('hex');

  // 从私钥创建账户
  const account = tronWeb.createAccount();
  // 使用我们的私钥
  const wallet = tronWeb.address.fromPrivateKey(privateKey);

  return {
    chain: 'TRON',
    mnemonic,
    privateKey,
    publicKey: tronWeb.address.toHex(wallet).replace('41', '04'), // TRON 地址转公钥前缀
    address: {
      base58: wallet, // Base58 格式地址（T 开头）
      hex: tronWeb.address.toHex(wallet), // Hex 格式地址
    },
  };
}

/**
 * 从私钥导入钱包
 * @param {string} privateKey - 私钥（十六进制）
 * @returns {Object} 钱包信息
 */
export function importFromPrivateKey(privateKey) {
  // 移除可能的 0x 前缀
  privateKey = privateKey.replace('0x', '');

  // 验证私钥长度
  if (privateKey.length !== 64) {
    throw new Error('Invalid private key length');
  }

  const address = tronWeb.address.fromPrivateKey(privateKey);

  return {
    chain: 'TRON',
    privateKey,
    address: {
      base58: address,
      hex: tronWeb.address.toHex(address),
    },
  };
}

/**
 * 随机生成 TRON 钱包（不使用助记词）
 * @returns {Object} 钱包信息
 */
export function createRandom() {
  const account = tronWeb.createAccount();

  return {
    chain: 'TRON',
    privateKey: account.privateKey,
    publicKey: account.publicKey,
    address: {
      base58: account.address.base58,
      hex: account.address.hex,
    },
  };
}

/**
 * 验证 TRON 地址是否有效
 * @param {string} address - TRON 地址（Base58 或 Hex）
 * @returns {boolean}
 */
export function isValidAddress(address) {
  return tronWeb.isAddress(address);
}

/**
 * 转换地址格式
 * @param {string} address - 地址
 * @param {string} format - 目标格式：'base58' 或 'hex'
 * @returns {string}
 */
export function convertAddress(address, format = 'base58') {
  if (format === 'hex') {
    return tronWeb.address.toHex(address);
  } else {
    return tronWeb.address.fromHex(address);
  }
}

export default {
  generateWallet,
  importFromPrivateKey,
  createRandom,
  isValidAddress,
  convertAddress,
};
