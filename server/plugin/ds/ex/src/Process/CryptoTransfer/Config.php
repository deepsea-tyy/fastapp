<?php
/**
 * FastApp.
 * 1/6/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

declare(strict_types=1);

namespace Plugin\Ds\Ex\Process\CryptoTransfer;

class Config
{
    const TRC20_CONTRACT_ADDRESS_USDT = "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t";
    const ERC20_CONTRACT_ADDRESS_USDT = "0xdac17f958d2ee523a2206206994597c13d831ec7";
    const BEP20_CONTRACT_ADDRESS_USDT = "0x55d398326f99059ff775485246999027b3197955";
    const TON_CONTRACT_ADDRESS_USDT = "EQCxE6mUtQJKFnGfaROTKOt1lZbDiiX1kCixRv7Nw2Id_sDs";
    const TON_CONTRACT_ADDRESS_USDT_HEX = "0:B113A994B5024A16719F69139328EB759596C38A25F59028B146FECDC3621DFE";

    const ETH_URL = 'eth-mainnet.alchemyapi.io/v2/cm8pr97xeeXwcZJptuIRHit3yCmIpLkB';
    const BNB_URL = 'bnb-mainnet.g.alchemy.com/v2/cm8pr97xeeXwcZJptuIRHit3yCmIpLkB';
    const TRX_URL = 'https://api.trongrid.io';
    const TRX_API_KEY = 'b9457fd8-17fe-4e9c-9b94-1376deab8d8a';
    const TON_URL = 'https://toncenter.com';
    const TON_API_KEY = '20ef11b3e2ba7286ce4efe2e39897eb48fef13fadf927d7726b4ec3c4ae89715';

    public static function validateEthOrBNBAddress(string $address): bool|int
    {
        return preg_match('/^0x[a-fA-F0-9]{40}$/', $address);
    }
}