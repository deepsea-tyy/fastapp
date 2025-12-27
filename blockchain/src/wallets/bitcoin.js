import * as bitcoin from 'bitcoinjs-lib';
import ECPairFactory from 'ecpair';
import * as ecc from 'tiny-secp256k1';
import * as bip39 from 'bip39';
import BIP32Factory from 'bip32';

const ECPair = ECPairFactory(ecc);
const bip32 = BIP32Factory(ecc);

// 网络配置
const NETWORKS = {
  BTC: bitcoin.networks.bitcoin,
  DOGE: {
    messagePrefix: '\x19Dogecoin Signed Message:\n',
    bech32: 'doge',
    bip32: {
      public: 0x02facafd,
      private: 0x02fac398,
    },
    pubKeyHash: 0x1e,
    scriptHash: 0x16,
    wif: 0x9e,
  },
  LTC: {
    messagePrefix: '\x19Litecoin Signed Message:\n',
    bech32: 'ltc',
    bip32: {
      public: 0x019da462,
      private: 0x019d9cfe,
    },
    pubKeyHash: 0x30,
    scriptHash: 0x32,
    wif: 0xb0,
  },
};

/**
 * 生成 BTC/DOGE/LTC 钱包
 * @param {string} chain - 链类型: BTC, DOGE, LTC
 * @param {string} mnemonic - 可选的助记词，不提供则自动生成
 * @returns {Object} 包含私钥、公钥、地址等信息
 */
export function generateWallet(chain = 'BTC', mnemonic = null) {
  const network = NETWORKS[chain];

  if (!network) {
    throw new Error(`Unsupported chain: ${chain}`);
  }

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

  // 生成根密钥
  const root = bip32.fromSeed(seed, network);

  // 使用 BIP44 路径
  // m/44'/coin_type'/0'/0/0
  const coinType = chain === 'BTC' ? 0 : chain === 'DOGE' ? 3 : 2; // BTC: 0, LTC: 2, DOGE: 3
  const path = `m/44'/${coinType}'/0'/0/0`;

  const child = root.derivePath(path);
  const keyPair = ECPair.fromPrivateKey(child.privateKey, { network });

  // 生成地址（P2PKH - Legacy）
  const { address } = bitcoin.payments.p2pkh({
    pubkey: keyPair.publicKey,
    network,
  });

  // 生成 SegWit 地址（P2WPKH）- 仅 BTC 和 LTC 支持
  let segwitAddress = null;
  if (chain === 'BTC' || chain === 'LTC') {
    const segwit = bitcoin.payments.p2wpkh({
      pubkey: keyPair.publicKey,
      network,
    });
    segwitAddress = segwit.address;
  }

  return {
    chain,
    mnemonic,
    privateKey: keyPair.privateKey.toString('hex'),
    publicKey: keyPair.publicKey.toString('hex'),
    wif: keyPair.toWIF(),
    address, // Legacy address
    segwitAddress, // SegWit address (if supported)
    path,
  };
}

/**
 * 从私钥导入钱包
 * @param {string} privateKeyHex - 十六进制私钥
 * @param {string} chain - 链类型
 * @returns {Object} 钱包信息
 */
export function importFromPrivateKey(privateKeyHex, chain = 'BTC') {
  const network = NETWORKS[chain];

  if (!network) {
    throw new Error(`Unsupported chain: ${chain}`);
  }

  const keyPair = ECPair.fromPrivateKey(Buffer.from(privateKeyHex, 'hex'), { network });

  const { address } = bitcoin.payments.p2pkh({
    pubkey: keyPair.publicKey,
    network,
  });

  let segwitAddress = null;
  if (chain === 'BTC' || chain === 'LTC') {
    const segwit = bitcoin.payments.p2wpkh({
      pubkey: keyPair.publicKey,
      network,
    });
    segwitAddress = segwit.address;
  }

  return {
    chain,
    privateKey: privateKeyHex,
    publicKey: keyPair.publicKey.toString('hex'),
    wif: keyPair.toWIF(),
    address,
    segwitAddress,
  };
}

/**
 * 从 WIF 导入钱包
 * @param {string} wif - WIF 格式私钥
 * @param {string} chain - 链类型
 * @returns {Object} 钱包信息
 */
export function importFromWIF(wif, chain = 'BTC') {
  const network = NETWORKS[chain];

  if (!network) {
    throw new Error(`Unsupported chain: ${chain}`);
  }

  const keyPair = ECPair.fromWIF(wif, network);

  const { address } = bitcoin.payments.p2pkh({
    pubkey: keyPair.publicKey,
    network,
  });

  let segwitAddress = null;
  if (chain === 'BTC' || chain === 'LTC') {
    const segwit = bitcoin.payments.p2wpkh({
      pubkey: keyPair.publicKey,
      network,
    });
    segwitAddress = segwit.address;
  }

  return {
    chain,
    privateKey: keyPair.privateKey.toString('hex'),
    publicKey: keyPair.publicKey.toString('hex'),
    wif,
    address,
    segwitAddress,
  };
}

export default {
  generateWallet,
  importFromPrivateKey,
  importFromWIF,
};
