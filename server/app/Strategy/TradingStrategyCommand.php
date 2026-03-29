<?php

namespace App\Strategy;

use GuzzleHttp\Client;
use Hyperf\Command\Annotation\AsCommand;
use Hyperf\Command\Command;
use Binance\API;

#[AsCommand(signature: 'trading', description: '啃肉策略')]
class TradingStrategyCommand extends Command
{
    public function handle()
    {
        $config = [
            'MEME' => ['TRUMP', 'WLFI', 'MELANIA', 'DOGE', 'RFK'],
//            'BASE' => ['TAO', 'RIF', 'KYVE', 'AKT', 'STRK', 'MNT'],
//            'direction' => ['BTC', 'ETH'],
        ];

        $client = new Client([
            'timeout' => 10,
            'verify' => false,
            // 若在海外服务器，删除下一行
            'proxy' => 'http://127.0.0.1:7890',
            'headers' => ['Accept-Encoding' => 'identity']
        ]);
        $premiumList = json_decode(
            $client->get('https://fapi.binance.com/fapi/v1/premiumIndex')->getBody(),
            true
        );

        //选币
        $currentFundingMap = [];
        foreach ($premiumList as $item) {
            if (str_ends_with($item['symbol'], 'USDT') && in_array(str_replace('USDT', '', $item['symbol']), $config['MEME'])) {
                $currentFundingMap[$item['symbol']]['lastFundingRate'] = floatval($item['lastFundingRate']);
                $currentFundingMap[$item['symbol']]['markPrice'] = floatval($item['markPrice']);
            }
        }
        print_r($currentFundingMap);
        foreach ($config['MEME'] as $base) {
            $symbol = $base . 'USDT';
            if (!isset($currentFundingMap[$symbol])) continue;

            $current = $currentFundingMap[$symbol];
            if ($current['lastFundingRate'] >= -0.0001) {
                unset($currentFundingMap[$symbol]);
                continue;
            }

            if (!$this->hasCompletePendulumCycle($client, $symbol)) {
                unset($currentFundingMap[$symbol]);
            }
        }
        if (empty($currentFundingMap)) {
            $this->info("【无信号】无完整钟摆周期");
        } else {
            $this->info("【完整钟摆新一轮信号】");
            $api = new API(env('B_API_KEY'), env('B_API_SECRET'));

            foreach ($currentFundingMap as $symbol => $value) {
                $takeProfitPrice = $value['markPrice'] * 0.8;
                $quantity = (10 * 20) / $value['markPrice'];
                $api->futuresBuy($symbol, $value, $quantity, params: ['stopPrice' => $takeProfitPrice]);
            }
        }
    }

    private function hasCompletePendulumCycle(Client $client, string $symbol): bool
    {
        try {
            // 获取最多30个历史费率（覆盖10天，确保捕捉到正费率）
            $url = "https://fapi.binance.com/fapi/v1/fundingRate?symbol={$symbol}&limit=30";
            $raw = json_decode($client->get($url)->getBody(), true);

            if (count($raw) < 5) return false;

            $rates = array_reverse(array_map(fn($item) => floatval($item['fundingRate']), $raw));
            $last3 = array_slice($rates, 0, 3);

            if (count($last3) !== 3) return false;

            $current = $last3[0];
            $prev1 = $last3[1];
            $prev2 = $last3[2];

            // 条件A：当前 < -0.0001
            if ($current >= -0.0001) return false;

            // 条件B：最近3期连续回升
            if (!($current > $prev1 && $prev1 > $prev2)) return false;

            // 条件C：24h内曾 ≤ -0.0003
            $min24h = min($last3);
            if ($min24h > -0.0003) return false;

            // 条件D：从最低点反弹 ≥ 50%
            $rebound = ($current - $min24h) / abs($min24h);
            if ($rebound < 0.5) return false;

            // ✅ 关键新增：历史中必须存在 fundingRate > 0
            $hasPositive = false;
            foreach ($rates as $rate) {
                if ($rate > 0) {
                    $hasPositive = true;
                    break;
                }
            }

            return $hasPositive;
        } catch (\Throwable $e) {
            return false;
        }
    }
}