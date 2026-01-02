<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Process;

use App\Common\Tools;
use GuzzleHttp\Client;
use Hyperf\Process\AbstractProcess;
use Hyperf\Process\Annotation\Process;
use Hyperf\Redis\Redis;
use Plugin\Ds\SysConfig\Helper\CacheConfigHelper;
use Swoole\Coroutine;

/**
 * 汇率
 */
//#[Process(nums: 1, name: 'ExchangeRateProcess')]
class ExchangeRateProcess extends AbstractProcess
{
    public function handle(): void
    {
        Tools::logAsync('Exchange Rate Process started');
        $redis = Tools::getContainer()->get(Redis::class);
        $c = CacheConfigHelper::getConfigByKey('exchange_rate')['config_select_data'];
        $client = new Client(['verify' => false, 'proxy' => 'http://127.0.0.1:7890']);
        $url = 'https://api.coingecko.com/api/v3/simple/price?ids=tether&vs_currencies=usd,';
        while (true) {
            foreach ($c as $item) {
                $res = $client->get($url . $item, [
                    'headers' => [
                        'Accept-Encoding' => 'identity',
                    ]
                ]);
                $data = json_decode($res->getBody()->getContents(), true);
                $redis->hSet('exchange_rate', $item, $data['tether'][$item]);
                Coroutine::sleep(3);
            }
        }

    }
}
