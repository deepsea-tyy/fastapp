import { Keypair, PublicKey } from '@solana/web3.js';
import * as bip39 from 'bip39';
import { derivePath } from 'ed25519-hd-key';

/**
 * 生成 Solana 钱包
 * @param {string} mnemonic - 可选的助记词，不提供则自动生成
 * @param {number} accountIndex - 账户索引，默认 0
 * @returns {Object} 包含私钥、公钥、地址等信息
 */
export function generateWallet(mnemonic = null, accountIndex = 0) {
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

  // 使用 Solana 的 BIP44 路径: m/44'/501'/accountIndex'/0'
  const path = `m/44'/501'/${accountIndex}'/0'`;
  const derivedSeed = derivePath(path, seed.toString('hex')).key;

  // 从派生种子创建密钥对
  const keypair = Keypair.fromSeed(derivedSeed);

  return {
    chain: 'SOLANA',
    mnemonic,
    privateKey: Buffer.from(keypair.secretKey).toString('hex'),
    publicKey: keypair.publicKey.toBase58(),
    address: keypair.publicKey.toBase58(), // Solana 的地址就是公钥
    path,
    accountIndex,
    secretKey: Array.from(keypair.secretKey), // 完整的 64 字节密钥对
  };
}

/**
 * 从私钥导入钱包
 * @param {string} privateKeyHex - 私钥（十六进制，64字节）
 * @returns {Object} 钱包信息
 */
export function importFromPrivateKey(privateKeyHex) {
  // 移除可能的 0x 前缀
  privateKeyHex = privateKeyHex.replace('0x', '');

  const secretKey = Buffer.from(privateKeyHex, 'hex');

  if (secretKey.length !== 64) {
    throw new Error('Invalid private key length. Solana requires 64 bytes.');
  }

  const keypair = Keypair.fromSecretKey(secretKey);

  return {
    chain: 'SOLANA',
    privateKey: privateKeyHex,
    publicKey: keypair.publicKey.toBase58(),
    address: keypair.publicKey.toBase58(),
    secretKey: Array.from(keypair.secretKey),
  };
}

/**
 * 从种子短语导入钱包
 * @param {string} mnemonic - 助记词
 * @param {number} accountIndex - 账户索引
 * @returns {Object} 钱包信息
 */
export function importFromMnemonic(mnemonic, accountIndex = 0) {
  return generateWallet(mnemonic, accountIndex);
}

/**
 * 随机生成 Solana 钱包（不使用助记词）
 * @returns {Object} 钱包信息
 */
export function createRandom() {
  const keypair = Keypair.generate();

  return {
    chain: 'SOLANA',
    privateKey: Buffer.from(keypair.secretKey).toString('hex'),
    publicKey: keypair.publicKey.toBase58(),
    address: keypair.publicKey.toBase58(),
    secretKey: Array.from(keypair.secretKey),
  };
}

/**
 * 验证 Solana 地址是否有效
 * @param {string} address - Solana 地址
 * @returns {boolean}
 */
export function isValidAddress(address) {
  try {
    new PublicKey(address);
    return true;
  } catch {
    return false;
  }
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

export default {
  generateWallet,
  importFromPrivateKey,
  importFromMnemonic,
  createRandom,
  isValidAddress,
  generateMultipleAccounts,
};
