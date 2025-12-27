import { Wallet, isValidAddress, isValidSecret } from 'xrpl';
import * as bip39 from 'bip39';
import { derivePath } from 'ed25519-hd-key';

/**
 * 生成 XRP 钱包
 * @param {string} mnemonic - 可选的助记词，不提供则自动生成
 * @param {string} algorithm - 密钥算法: 'secp256k1' 或 'ed25519'，默认 'secp256k1'
 * @returns {Object} 包含私钥、公钥、地址等信息
 */
export function generateWallet(mnemonic = null, algorithm = 'secp256k1') {
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

  // 使用 XRP 的 BIP44 路径: m/44'/144'/0'/0/0
  const path = "m/44'/144'/0'/0/0";

  let wallet;

  if (algorithm === 'ed25519') {
    // Ed25519 算法
    const derivedSeed = derivePath(path, seed.toString('hex')).key;
    wallet = Wallet.fromSeed(derivedSeed.toString('hex'), { algorithm: 'ed25519' });
  } else {
    // Secp256k1 算法（默认）
    wallet = Wallet.fromSeed(seed.toString('hex'));
  }

  return {
    chain: 'XRP',
    mnemonic,
    seed: wallet.seed,
    privateKey: wallet.privateKey,
    publicKey: wallet.publicKey,
    address: wallet.address,
    classicAddress: wallet.classicAddress,
    algorithm,
    path,
  };
}

/**
 * 从种子创建钱包
 * @param {string} seed - XRP 种子（如：sEdV19...）
 * @param {string} algorithm - 密钥算法
 * @returns {Object} 钱包信息
 */
export function importFromSeed(seed, algorithm = 'secp256k1') {
  const wallet = Wallet.fromSeed(seed, { algorithm });

  return {
    chain: 'XRP',
    seed: wallet.seed,
    privateKey: wallet.privateKey,
    publicKey: wallet.publicKey,
    address: wallet.address,
    classicAddress: wallet.classicAddress,
    algorithm,
  };
}

/**
 * 从助记词导入钱包
 * @param {string} mnemonic - 助记词
 * @param {string} algorithm - 密钥算法
 * @returns {Object} 钱包信息
 */
export function importFromMnemonic(mnemonic, algorithm = 'secp256k1') {
  return generateWallet(mnemonic, algorithm);
}

/**
 * 随机生成 XRP 钱包（不使用助记词）
 * @param {string} algorithm - 密钥算法
 * @returns {Object} 钱包信息
 */
export function createRandom(algorithm = 'secp256k1') {
  const wallet = Wallet.generate(algorithm);

  return {
    chain: 'XRP',
    seed: wallet.seed,
    privateKey: wallet.privateKey,
    publicKey: wallet.publicKey,
    address: wallet.address,
    classicAddress: wallet.classicAddress,
    algorithm,
  };
}

/**
 * 验证 XRP 地址是否有效
 * @param {string} address - XRP 地址
 * @returns {boolean}
 */
export function validateAddress(address) {
  return isValidAddress(address);
}

/**
 * 验证 XRP 种子是否有效
 * @param {string} seed - XRP 种子
 * @returns {boolean}
 */
export function validateSeed(seed) {
  return isValidSecret(seed);
}

export default {
  generateWallet,
  importFromSeed,
  importFromMnemonic,
  createRandom,
  validateAddress,
  validateSeed,
};
