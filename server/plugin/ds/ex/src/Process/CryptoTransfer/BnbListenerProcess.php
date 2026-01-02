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

#[Process(name: 'BnbListenerProcess')]
class BnbListenerProcess extends AbstractCryptoListenerProcess
{
    protected function getChainName(): string
    {
        return 'BNB';
    }

    protected function getWebSocketUrl(): string
    {
        return Config::BNB_URL;
    }

    protected function getUsdtContractAddress(): string
    {
        return Config::BEP20_CONTRACT_ADDRESS_USDT;
    }
}