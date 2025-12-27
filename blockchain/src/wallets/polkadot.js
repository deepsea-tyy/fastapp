import { Keyring } from '@polkadot/keyring';
import { mnemonicGenerate, mnemonicValidate, mnemonicToMiniSecret, cryptoWaitReady } from '@polkadot/util-crypto';
import { u8aToHex } from '@polkadot/util';

// 等待加密库初始化
await cryptoWaitReady();

/**
 * 生成 Polkadot/Kusama 钱包
 * @param {string} mnemonic - 可选的助记词，不提供则自动生成
 * @param {string} network - 网络类型: 'polkadot', 'kusama', 'substrate'
 * @param {string} keyType - 密钥类型: 'sr25519' (默认) 或 'ed25519'
 * @returns {Object} 包含私钥、公钥、地址等信息
 */
export function generateWallet(mnemonic = null, network = 'polkadot', keyType = 'sr25519') {
  // 如果没有提供助记词，生成新的
  if (!mnemonic) {
    mnemonic = mnemonicGenerate();
  }

  // 验证助记词
  if (!mnemonicValidate(mnemonic)) {
    throw new Error('Invalid mnemonic');
  }

  // 确定地址前缀
  const ss58Format = getAddressPrefix(network);

  // 创建 keyring
  const keyring = new Keyring({ type: keyType, ss58Format });

  // 从助记词创建密钥对
  const pair = keyring.addFromMnemonic(mnemonic);

  // 获取种子
  const seed = mnemonicToMiniSecret(mnemonic);

  return {
    chain: network.toUpperCase(),
    mnemonic,
    seed: u8aToHex(seed),
    privateKey: u8aToHex(pair.secretKey), // 注意：这是种子+公钥的组合
    publicKey: u8aToHex(pair.publicKey),
    address: pair.address,
    keyType,
    ss58Format,
  };
}

/**
 * 从种子导入钱包
 * @param {string} seedHex - 种子（十六进制）
 * @param {string} network - 网络类型
 * @param {string} keyType - 密钥类型
 * @returns {Object} 钱包信息
 */
export function importFromSeed(seedHex, network = 'polkadot', keyType = 'sr25519') {
  const ss58Format = getAddressPrefix(network);
  const keyring = new Keyring({ type: keyType, ss58Format });

  // 从种子创建密钥对
  const pair = keyring.addFromSeed(Buffer.from(seedHex, 'hex'));

  return {
    chain: network.toUpperCase(),
    seed: seedHex,
    privateKey: u8aToHex(pair.secretKey),
    publicKey: u8aToHex(pair.publicKey),
    address: pair.address,
    keyType,
    ss58Format,
  };
}

/**
 * 从助记词导入钱包
 * @param {string} mnemonic - 助记词
 * @param {string} network - 网络类型
 * @param {string} keyType - 密钥类型
 * @returns {Object} 钱包信息
 */
export function importFromMnemonic(mnemonic, network = 'polkadot', keyType = 'sr25519') {
  return generateWallet(mnemonic, network, keyType);
}

/**
 * 从 URI 导入钱包
 * @param {string} uri - Substrate URI (如: //Alice, //Bob, mnemonic//path)
 * @param {string} network - 网络类型
 * @param {string} keyType - 密钥类型
 * @returns {Object} 钱包信息
 */
export function importFromUri(uri, network = 'polkadot', keyType = 'sr25519') {
  const ss58Format = getAddressPrefix(network);
  const keyring = new Keyring({ type: keyType, ss58Format });

  const pair = keyring.addFromUri(uri);

  return {
    chain: network.toUpperCase(),
    privateKey: u8aToHex(pair.secretKey),
    publicKey: u8aToHex(pair.publicKey),
    address: pair.address,
    keyType,
    ss58Format,
    uri,
  };
}

/**
 * 转换地址格式到不同的网络
 * @param {string} address - 原地址
 * @param {string} targetNetwork - 目标网络
 * @returns {string} 转换后的地址
 */
export function convertAddress(address, targetNetwork) {
  const ss58Format = getAddressPrefix(targetNetwork);
  const keyring = new Keyring();

  return keyring.encodeAddress(keyring.decodeAddress(address), ss58Format);
}

/**
 * 验证地址是否有效
 * @param {string} address - 地址
 * @returns {boolean}
 */
export function isValidAddress(address) {
  try {
    const keyring = new Keyring();
    keyring.decodeAddress(address);
    return true;
  } catch {
    return false;
  }
}

/**
 * 获取地址前缀（SS58 Format）
 * @param {string} network - 网络名称
 * @returns {number} SS58 格式编号
 */
function getAddressPrefix(network) {
  const prefixes = {
    polkadot: 0,
    kusama: 2,
    substrate: 42,
    westend: 42,
    rococo: 42,
  };

  return prefixes[network.toLowerCase()] || 42;
}

/**
 * 生成开发账户（Alice, Bob, Charlie, Dave, Eve, Ferdie）
 * @param {string} name - 账户名称
 * @param {string} network - 网络类型
 * @param {string} keyType - 密钥类型
 * @returns {Object} 钱包信息
 */
export function generateDevAccount(name = 'Alice', network = 'polkadot', keyType = 'sr25519') {
  const uri = `//${name}`;
  return importFromUri(uri, network, keyType);
}

export default {
  generateWallet,
  importFromSeed,
  importFromMnemonic,
  importFromUri,
  convertAddress,
  isValidAddress,
  generateDevAccount,
};
