import * as CardanoWasm from '@emurgo/cardano-serialization-lib-nodejs';
import * as bip39 from 'bip39';

/**
 * 生成 Cardano 钱包
 * @param {string} mnemonic - 可选的助记词，不提供则自动生成（支持15或24个词）
 * @param {number} accountIndex - 账户索引，默认 0
 * @param {number} addressIndex - 地址索引，默认 0
 * @returns {Object} 包含私钥、公钥、地址等信息
 */
export function generateWallet(mnemonic = null, accountIndex = 0, addressIndex = 0) {
  // 如果没有提供助记词，生成新的 24 个词的助记词
  if (!mnemonic) {
    mnemonic = bip39.generateMnemonic(256); // 256 bits = 24 words
  }

  // 验证助记词
  if (!bip39.validateMnemonic(mnemonic)) {
    throw new Error('Invalid mnemonic');
  }

  // 从助记词生成根密钥
  const entropy = bip39.mnemonicToEntropy(mnemonic);
  const rootKey = CardanoWasm.Bip32PrivateKey.from_bip39_entropy(
    Buffer.from(entropy, 'hex'),
    Buffer.from('') // 密码，可选
  );

  // Cardano 使用 CIP-1852 路径: m/1852'/1815'/account'/role/address
  // role: 0 = external (receiving), 1 = internal (change), 2 = staking
  const accountKey = rootKey
    .derive(harden(1852)) // purpose
    .derive(harden(1815)) // coin_type (ADA)
    .derive(harden(accountIndex)); // account

  const paymentKey = accountKey
    .derive(0) // external chain (receiving addresses)
    .derive(addressIndex);

  const stakingKey = accountKey
    .derive(2) // staking key
    .derive(0);

  // 获取公钥
  const paymentPubKey = paymentKey.to_public();
  const stakingPubKey = stakingKey.to_public();

  // 创建基础地址（Base Address）
  const baseAddr = CardanoWasm.BaseAddress.new(
    CardanoWasm.NetworkInfo.mainnet().network_id(),
    CardanoWasm.StakeCredential.from_keyhash(paymentPubKey.to_raw_key().hash()),
    CardanoWasm.StakeCredential.from_keyhash(stakingPubKey.to_raw_key().hash())
  );

  // 创建企业地址（Enterprise Address，不参与质押）
  const enterpriseAddr = CardanoWasm.EnterpriseAddress.new(
    CardanoWasm.NetworkInfo.mainnet().network_id(),
    CardanoWasm.StakeCredential.from_keyhash(paymentPubKey.to_raw_key().hash())
  );

  return {
    chain: 'CARDANO',
    mnemonic,
    privateKey: {
      payment: Buffer.from(paymentKey.as_bytes()).toString('hex'),
      staking: Buffer.from(stakingKey.as_bytes()).toString('hex'),
    },
    publicKey: {
      payment: Buffer.from(paymentPubKey.as_bytes()).toString('hex'),
      staking: Buffer.from(stakingPubKey.as_bytes()).toString('hex'),
    },
    address: {
      base: baseAddr.to_address().to_bech32(), // addr1...（参与质押）
      enterprise: enterpriseAddr.to_address().to_bech32(), // addr1...（不参与质押）
    },
    path: `m/1852'/1815'/${accountIndex}'/0/${addressIndex}`,
    accountIndex,
    addressIndex,
  };
}

/**
 * 从私钥导入钱包
 * @param {string} paymentPrivateKeyHex - 支付私钥（十六进制）
 * @param {string} stakingPrivateKeyHex - 质押私钥（十六进制，可选）
 * @returns {Object} 钱包信息
 */
export function importFromPrivateKey(paymentPrivateKeyHex, stakingPrivateKeyHex = null) {
  const paymentKey = CardanoWasm.Bip32PrivateKey.from_bytes(
    Buffer.from(paymentPrivateKeyHex, 'hex')
  );
  const paymentPubKey = paymentKey.to_public();

  const addresses = {
    enterprise: CardanoWasm.EnterpriseAddress.new(
      CardanoWasm.NetworkInfo.mainnet().network_id(),
      CardanoWasm.StakeCredential.from_keyhash(paymentPubKey.to_raw_key().hash())
    ).to_address().to_bech32(),
  };

  const result = {
    chain: 'CARDANO',
    privateKey: {
      payment: paymentPrivateKeyHex,
    },
    publicKey: {
      payment: Buffer.from(paymentPubKey.as_bytes()).toString('hex'),
    },
    address: addresses,
  };

  // 如果提供了质押私钥，添加基础地址
  if (stakingPrivateKeyHex) {
    const stakingKey = CardanoWasm.Bip32PrivateKey.from_bytes(
      Buffer.from(stakingPrivateKeyHex, 'hex')
    );
    const stakingPubKey = stakingKey.to_public();

    const baseAddr = CardanoWasm.BaseAddress.new(
      CardanoWasm.NetworkInfo.mainnet().network_id(),
      CardanoWasm.StakeCredential.from_keyhash(paymentPubKey.to_raw_key().hash()),
      CardanoWasm.StakeCredential.from_keyhash(stakingPubKey.to_raw_key().hash())
    );

    result.privateKey.staking = stakingPrivateKeyHex;
    result.publicKey.staking = Buffer.from(stakingPubKey.as_bytes()).toString('hex');
    result.address.base = baseAddr.to_address().to_bech32();
  }

  return result;
}

/**
 * 从助记词导入钱包
 * @param {string} mnemonic - 助记词
 * @param {number} accountIndex - 账户索引
 * @param {number} addressIndex - 地址索引
 * @returns {Object} 钱包信息
 */
export function importFromMnemonic(mnemonic, accountIndex = 0, addressIndex = 0) {
  return generateWallet(mnemonic, accountIndex, addressIndex);
}

/**
 * 生成多个地址
 * @param {string} mnemonic - 助记词
 * @param {number} count - 生成地址数量
 * @param {number} accountIndex - 账户索引
 * @param {number} startIndex - 起始地址索引
 * @returns {Array} 钱包数组
 */
export function generateMultipleAddresses(mnemonic, count = 1, accountIndex = 0, startIndex = 0) {
  const wallets = [];

  for (let i = 0; i < count; i++) {
    const wallet = generateWallet(mnemonic, accountIndex, startIndex + i);
    wallets.push(wallet);
  }

  return wallets;
}

/**
 * 验证 Cardano 地址是否有效
 * @param {string} address - Cardano 地址（Bech32 格式）
 * @returns {boolean}
 */
export function isValidAddress(address) {
  try {
    CardanoWasm.Address.from_bech32(address);
    return true;
  } catch {
    return false;
  }
}

// 辅助函数：硬化派生
function harden(num) {
  return 0x80000000 + num;
}

export default {
  generateWallet,
  importFromPrivateKey,
  importFromMnemonic,
  generateMultipleAddresses,
  isValidAddress,
};
