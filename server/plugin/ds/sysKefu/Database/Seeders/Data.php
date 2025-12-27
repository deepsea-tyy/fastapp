<?php
/**
 * FastApp.
 * 12/26/25
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

        // 插入配置组
        $group = [
            ['code' => 'feed_config', 'name' => '[{"lang": "zh_CN", "text": "信息流配置"}, {"lang": "en", "text": "Information flow configuration"}]', 'icon' => 'ri:message-2-fill'],
            ['code' => 'kefu_config', 'name' => '[{"lang": "zh_CN", "text": "客服配置"}, {"lang": "en", "text": "customer service"}]', 'icon' => 'ri:customer-service-2-line']
        ];
        foreach ($group as $item) {
            $groupExists = Db::table('system_config_group')->where('code', $item['code'])->exists();
            if (!$groupExists) {
                Db::table('system_config_group')->insert($item);
            }
        }

        // 插入配置项
        $configs = [
            //信息流
            ['feed_config', 'feed_account_new', null, '[{"lang": "zh_CN", "text": "新闻发布账户ID"}, {"lang": "en", "text": "News Release Account ID"}]', 'input', '[]', 99],
            ['feed_config', 'feed_account_notice', null, '[{"lang": "zh_CN", "text": "公告发布账户"}, {"lang": "en", "text": "Announcement Release Account"}]', 'input', '[]', 89],
            ['feed_config', 'feed_account_post', null, '[{"lang": "zh_CN", "text": "帖子发布账户 ID"}, {"lang": "zh_CN", "text": "Post posting account ID"}]', 'input', '[]', 79],
            //客服
            ['kefu_config', 'auto_reply_enabled', '"1"', '[{"lang": "zh_CN", "text": "是否启用自动回复"}, {"lang": "en", "text": "Do you want to enable automatic replies"}]', 'input', '[]', 99],
            ['kefu_config', 'work_time_start', '"09:00"', '[{"lang": "zh_CN", "text": "工作时间开始"}, {"lang": "en", "text": "Starting working hours "}]', 'input', '[]', 98],
            ['kefu_config', 'work_time_end', '"22:00"', '[{"lang": "zh_CN", "text": "工作时间结束"}, {"lang": "en", "text": "End of working hours"}]', 'input', '[]', 97],
            ['kefu_config', 'auto_reply_delay', '"1"', '[{"lang": "zh_CN", "text": "自动回复延迟秒数（模拟真人）"}, {"lang": "en", "text": "Automatic reply delay in seconds (simulating a real person)"}]', 'input', '[]', 96],
            ['kefu_config', 'auto_reply_throttle', '"30"', '[{"lang": "zh_CN", "text": "同一会话同一规则触发间隔（秒）"}, {"lang": "en", "text": "Same session, same rule trigger interval (seconds)"}]', 'input', '[]', 96],
            ['kefu_config', 'welcome_message', '"zh_CN"', '[{"lang": "zh_CN", "text": "欢迎语"}, {"lang": "en", "text": "Welcome message"}]', 'keyValuePair', '[{"label": "您好！我是智能客服小助手，很高兴为您服务。请问有什么可以帮助您的？", "value": "zh_CN"}, {"label": "Hello! I am your AI customer service assistant. How may I help you today?", "value": "en"}]', 95],
            ['kefu_config', 'offline_message', '"zh_CN"', '[{"lang": "zh_CN", "text": "离线提示语"}, {"lang": "en", "text": "Offline prompt lang"}]', 'keyValuePair', '[{"label": "抱歉，当前为非工作时间（09:00-22:00），请留言或稍后再试。", "value": "zh_CN"}, {"label": "Sorry, we are currently offline (working hours: 09:00-22:00). Please leave a message or try again later.", "value": "en"}]', 94],
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
                    'remark' => null,
                ]);
            }


            // 初始化示例规则（中文）
            $rules_zh = [
                [
                    'title' => '如何充值？',
                    'trigger_type' => 2,
                    'keywords' => json_encode(['充值', '如何充值', '怎么充值', '充钱'], JSON_UNESCAPED_UNICODE),
                    'reply_type' => 1,
                    'reply_content' => json_encode(['text' => "充值步骤：\n1. 点击首页\"充值\"按钮\n2. 选择充值币种和网络\n3. 复制充值地址或扫描二维码\n4. 从您的钱包转账到该地址\n\n一般情况下，充值会在10-30分钟内到账。"], JSON_UNESCAPED_UNICODE),
                    'lang' => 'zh_CN',
                    'priority' => 10,
                    'status' => 1,
                ],
                [
                    'title' => '如何提现？',
                    'trigger_type' => 2,
                    'keywords' => json_encode(['提现', '提币', '如何提现', '怎么提现'], JSON_UNESCAPED_UNICODE),
                    'reply_type' => 1,
                    'reply_content' => json_encode(['text' => "提现步骤：\n1. 进入资产页面\n2. 选择要提现的币种\n3. 点击\"提现\"\n4. 输入提现地址和数量\n5. 完成安全验证\n\n提现一般会在1-2小时内到账，具体时间取决于区块链网络状况。"], JSON_UNESCAPED_UNICODE),
                    'lang' => 'zh_CN',
                    'priority' => 10,
                    'status' => 1,
                ],
                [
                    'title' => '如何进行交易？',
                    'trigger_type' => 2,
                    'keywords' => json_encode(['交易', '如何交易', '怎么交易', '买卖'], JSON_UNESCAPED_UNICODE),
                    'reply_type' => 1,
                    'reply_content' => json_encode(['text' => "交易指南：\n1. 进入交易页面\n2. 选择交易对（如BTC/USDT）\n3. 选择交易类型（限价/市价）\n4. 输入价格和数量\n5. 确认并提交订单\n\n如需更多帮助，请告诉我具体遇到的问题。"], JSON_UNESCAPED_UNICODE),
                    'lang' => 'zh_CN',
                    'priority' => 8,
                    'status' => 1,
                ],
                [
                    'title' => '人工客服',
                    'trigger_type' => 1,
                    'keywords' => json_encode(['人工', '人工客服', '转人工', '联系客服'], JSON_UNESCAPED_UNICODE),
                    'reply_type' => 1,
                    'reply_content' => json_encode(['text' => '正在为您转接人工客服，请稍候...'], JSON_UNESCAPED_UNICODE),
                    'lang' => 'zh_CN',
                    'priority' => 100,
                    'status' => 1,
                ],
            ];

            // 初始化示例规则（英文）
            $rules_en = [
                [
                    'title' => 'Deposit Questions',
                    'trigger_type' => 2,
                    'keywords' => json_encode(['deposit', 'how to deposit', 'recharge']),
                    'reply_type' => 1,
                    'reply_content' => json_encode(['text' => "Deposit Steps:\n1. Click the \"Deposit\" button on the homepage\n2. Select the cryptocurrency and network\n3. Copy the deposit address or scan the QR code\n4. Transfer from your wallet to this address\n\nDeposits usually arrive within 10-30 minutes."]),
                    'lang' => 'en',
                    'priority' => 10,
                    'status' => 1,
                ],
                [
                    'title' => 'Withdrawal Questions',
                    'trigger_type' => 2,
                    'keywords' => json_encode(['withdraw', 'withdrawal', 'how to withdraw']),
                    'reply_type' => 1,
                    'reply_content' => json_encode(['text' => "Withdrawal Steps:\n1. Go to Assets page\n2. Select the cryptocurrency to withdraw\n3. Click \"Withdraw\"\n4. Enter withdrawal address and amount\n5. Complete security verification\n\nWithdrawals usually arrive within 1-2 hours, depending on blockchain network conditions."]),
                    'lang' => 'en',
                    'priority' => 10,
                    'status' => 1,
                ],
                [
                    'title' => 'Trading Questions',
                    'trigger_type' => 2,
                    'keywords' => json_encode(['trade', 'how to trade', 'trading', 'buy', 'sell']),
                    'reply_type' => 1,
                    'reply_content' => json_encode(['text' => "Trading Guide:\n1. Go to Trading page\n2. Select trading pair (e.g., BTC/USDT)\n3. Choose order type (Limit/Market)\n4. Enter price and quantity\n5. Confirm and submit order\n\nIf you need more help, please tell me your specific issue."]),
                    'lang' => 'en',
                    'priority' => 8,
                    'status' => 1,
                ],
                [
                    'title' => 'Human Support',
                    'trigger_type' => 1,
                    'keywords' => json_encode(['human', 'support', 'agent', 'representative']),
                    'reply_type' => 1,
                    'reply_content' => json_encode(['text' => 'Connecting you to a human agent, please wait...']),
                    'lang' => 'en',
                    'priority' => 100,
                    'status' => 1,
                ],
            ];

            // 插入规则数据
            foreach (array_merge($rules_zh, $rules_en) as $rule) {
                Db::table('kefu_auto_reply')->insert(array_merge($rule, [
                    'created_at' => date('Y-m-d H:i:s'),
                    'updated_at' => date('Y-m-d H:i:s'),
                ]));
            }
        }

        echo '存储配置数据填充完成' . \PHP_EOL;
    }
}

