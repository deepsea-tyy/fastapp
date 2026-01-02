<?php
/**
 * FastApp.
 * 1/3/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

declare(strict_types=1);

namespace Plugin\Ds\Ex\Process\CryptoTransfer;

use Hyperf\Process\Annotation\Process;

#[Process(name: 'EthListenerProcess')]
class EthListenerProcess extends AbstractCryptoListenerProcess
{
    protected function getChainName(): string
    {
        return 'ETH';
    }

    protected function getWebSocketUrl(): string
    {
        return Config::ETH_URL;
    }

    protected function getUsdtContractAddress(): string
    {
        return Config::ERC20_CONTRACT_ADDRESS_USDT;
    }
}