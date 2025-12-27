import { ethers } from 'ethers';

/**
 * 生成 EVM 兼容链钱包 (ETH, BNB, Polygon, Arbitrum, Optimism, etc.)
 * @param {string} mnemonic - 可选的助记词，不提供则自动生成
 * @param {number} accountIndex - 账户索引，默认 0
 * @returns {Object} 包含私钥、公钥、地址等信息
 */
export function generateWallet(mnemonic = null, accountIndex = 0) {
  // 如果没有提供助记词，生成新的
  if (!mnemonic) {
    const wallet = ethers.Wallet.createRandom();
    mnemonic = wallet.mnemonic.phrase;
  }

  // 验证助记词
  if (!ethers.Mnemonic.isValidMnemonic(mnemonic)) {
    throw new Error('Invalid mnemonic');
  }

  // 使用 BIP44 路径: m/44'/60'/0'/0/accountIndex
  const path = `m/44'/60'/0'/0/${accountIndex}`;
  const wallet = ethers.HDNodeWallet.fromPhrase(mnemonic, undefined, path);

  return {
    chain: 'EVM',
    mnemonic,
    privateKey: wallet.privateKey,
    publicKey: wallet.publicKey,
    address: wallet.address,
    path,
    accountIndex,
  };
}

/**
 * 从私钥导入钱包
 * @param {string} privateKey - 私钥（带或不带 0x 前缀）
 * @returns {Object} 钱包信息
 */
export function importFromPrivateKey(privateKey) {
  // 确保私钥有 0x 前缀
  if (!privateKey.startsWith('0x')) {
    privateKey = '0x' + privateKey;
  }

  const wallet = new ethers.Wallet(privateKey);

  return {
    chain: 'EVM',
    privateKey: wallet.privateKey,
    publicKey: wallet.publicKey,
    address: wallet.address,
  };
}

/**
 * 从助记词导入钱包
 * @param {string} mnemonic - 助记词
 * @param {number} accountIndex - 账户索引
 * @returns {Object} 钱包信息
 */
export function importFromMnemonic(mnemonic, accountIndex = 0) {
  return generateWallet(mnemonic, accountIndex);
}

/**
 * 生成多个账户
 * @param {string} mnemonic - 助记词
 * @param {number} count - 生成账户数量
 * @param {number} startIndex - 起始索引
 * @returns {Array} 钱包数组
 */
export function generateMultipleAccounts(mnemonic, count = 1, startIndex = 0) {
  const wallets = [];

  for (let i = 0; i < count; i++) {
    const wallet = generateWallet(mnemonic, startIndex + i);
    wallets.push(wallet);
  }

  return wallets;
}

/**
 * 验证地址是否有效
 * @param {string} address - 以太坊地址
 * @returns {boolean}
 */
export function isValidAddress(address) {
  return ethers.isAddress(address);
}

/**
 * 将地址转换为校验和格式
 * @param {string} address - 地址
 * @returns {string} 校验和格式的地址
 */
export function toChecksumAddress(address) {
  return ethers.getAddress(address);
}

export default {
  generateWallet,
  importFromPrivateKey,
  importFromMnemonic,
  generateMultipleAccounts,
  isValidAddress,
  toChecksumAddress,
};
