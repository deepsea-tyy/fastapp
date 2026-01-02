<?php
/**
 * FastApp.
 * 12/23/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */


declare(strict_types=1);

use Hyperf\Database\Seeders\Seeder;
use Hyperf\DbConnection\Db;

class Data extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        echo '开始填充存储配置数据' . \PHP_EOL;
        Db::unprepared("INSERT INTO ex_vip (`level`, name, description, icon, color, trading_volume_usdt, holder_wallet_asset_usd, holder_platform_token, withdraw_limit_24h_usdt, protection_days, sort, status, fee_rates, `privileges`, created_at, updated_at, deleted_at) VALUES(0, '[{\"lang\": \"zh_CN\", \"text\": \"\"}]', '[{\"lang\": \"zh_CN\", \"text\": \"\"}]', NULL, '#ede7e7', 0.00, 0.00, 0.00000000, 0.00, 0, 0, 1, '{\"spot\": {\"maker\": 0.001, \"taker\": 0.001}, \"margin\": {\"maker\": 0.001, \"taker\": 0.001}, \"option\": {\"maker\": 0.0002, \"taker\": 0.0002}, \"coin_futures\": {\"maker\": 0.0002, \"taker\": 0.0005}, \"usdt_futures\": {\"maker\": 0.0002, \"taker\": 0.0005}}', '{\"api_rate_limit\": 1000, \"airdrop_priority\": 1, \"customer_service\": \"normal\", \"exclusive_events\": 1, \"api_rate_limit_ws\": 10, \"trading_rebate_rate\": 0.2, \"withdraw_fee_discount\": 0.5, \"loan_interest_discount\": 0.1, \"dedicated_account_manager\": 0}', '2025-12-23 16:35:48', '2025-12-23 16:35:48', NULL);");
        // 插入配置组
        $group = [
            ['code' => 'feed_config', 'name' => '[{"lang": "zh_CN", "text": "信息流配置"}, {"lang": "en", "text": "Information flow configuration"}]', 'icon' => 'ri:message-2-fill'],
            ['code' => 'ex_config', 'name' => '[{"lang": "zh_CN", "text": "交易所配置"}, {"lang": "en", "text": "Exchange configuration"}]', 'icon' => 'mdi:bank-transfer']
        ];
        foreach ($group as $item) {
            $groupExists = Db::table('system_config_group')->where('code', $item['code'])->exists();
            if (!$groupExists) {
                Db::table('system_config_group')->insert($item);
            }
        }

        // 插入配置项
        $configs = [
            ['ex_config', 'exchange_rate', NULL, '[{"lang": "zh_CN", "text": "汇率币种"}, {"lang": "zh_CN", "text": "Exchange rate currency"}]', 'json', '["cny", "krw", "eur", "jpy"]', 0],
            ['ex_config', 'token_standard', NULL, '[{"lang": "zh_CN", "text": "加密货币网络"}, {"lang": "zh_CN", "text": "Cryptocurrency Network"}]', 'json', '{"ADA": "ADA", "BNB": "BEP20", "BTC": "BTC", "DOT": "DOT", "ETH": "ETH", "LTC": "LTC", "SOL": "SOL", "TRX": "TRX", "UNI": "ERC20", "XLM": "XLM", "XMR": "XMR", "XRP": "XRP", "ATOM": "ATOM", "AVAX": "AVAX C-Chain", "DOGE": "DOGE", "LINK": "ERC20", "SHIB": "ERC20", "USDC": "ERC20", "USDT": "TRC20", "MATIC": "Polygon"}', 0],
        ];

        foreach ($configs as $config) {
            $exists = Db::table('system_config')
                ->where('group_code', $config[0])
                ->where('key', $config[1])
                ->exists();

            if (!$exists) {
                Db::table('system_config')->insert([
                    'group_code' => $config[0],
                    'key' => $config[1],
                    'value' => $config[2],
                    'name' => $config[3],
                    'input_type' => $config[4],
                    'config_select_data' => $config[5],
                    'sort' => $config[6],
                ]);
            }
        }

        echo '存储配置数据填充完成' . \PHP_EOL;
    }
}