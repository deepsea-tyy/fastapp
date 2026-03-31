-- 自 server/plugin/ds/sysKefu/database/seeders/Data.php
-- 仅 kefu_auto_reply（不含 feed_config；PHP 原先把自动回复插在 foreach 内会重复插入，此处每条规则只插一次）
-- system_config* 见同目录 2025_12_30_config.sql

SET NAMES utf8mb4;

INSERT INTO `{{prefix}}kefu_auto_reply` (`title`, `trigger_type`, `keywords`, `reply_type`, `reply_content`, `lang`, `priority`, `status`, `created_at`, `updated_at`)
SELECT '如何充值？', 2, CAST('["充值", "如何充值", "怎么充值", "充钱"]' AS JSON), 1, CAST('{"text": "充值步骤：\\n1. 点击首页\\"充值\\"按钮\\n2. 选择充值币种和网络\\n3. 复制充值地址或扫描二维码\\n4. 从您的钱包转账到该地址\\n\\n一般情况下，充值会在10-30分钟内到账。"}' AS JSON), 'zh_CN', 10, 1, NOW(), NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}kefu_auto_reply` t WHERE t.title = '如何充值？' AND t.lang = 'zh_CN' LIMIT 1);

INSERT INTO `{{prefix}}kefu_auto_reply` (`title`, `trigger_type`, `keywords`, `reply_type`, `reply_content`, `lang`, `priority`, `status`, `created_at`, `updated_at`)
SELECT '如何提现？', 2, CAST('["提现", "提币", "如何提现", "怎么提现"]' AS JSON), 1, CAST('{"text": "提现步骤：\\n1. 进入资产页面\\n2. 选择要提现的币种\\n3. 点击\\"提现\\"\\n4. 输入提现地址和数量\\n5. 完成安全验证\\n\\n提现一般会在1-2小时内到账，具体时间取决于区块链网络状况。"}' AS JSON), 'zh_CN', 10, 1, NOW(), NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}kefu_auto_reply` t WHERE t.title = '如何提现？' AND t.lang = 'zh_CN' LIMIT 1);

INSERT INTO `{{prefix}}kefu_auto_reply` (`title`, `trigger_type`, `keywords`, `reply_type`, `reply_content`, `lang`, `priority`, `status`, `created_at`, `updated_at`)
SELECT '如何进行交易？', 2, CAST('["交易", "如何交易", "怎么交易", "买卖"]' AS JSON), 1, CAST('{"text": "交易指南：\\n1. 进入交易页面\\n2. 选择交易对（如BTC/USDT）\\n3. 选择交易类型（限价/市价）\\n4. 输入价格和数量\\n5. 确认并提交订单\\n\\n如需更多帮助，请告诉我具体遇到的问题。"}' AS JSON), 'zh_CN', 8, 1, NOW(), NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}kefu_auto_reply` t WHERE t.title = '如何进行交易？' AND t.lang = 'zh_CN' LIMIT 1);

INSERT INTO `{{prefix}}kefu_auto_reply` (`title`, `trigger_type`, `keywords`, `reply_type`, `reply_content`, `lang`, `priority`, `status`, `created_at`, `updated_at`)
SELECT '人工客服', 1, CAST('["人工", "人工客服", "转人工", "联系客服"]' AS JSON), 1, CAST('{"text": "正在为您转接人工客服，请稍候..."}' AS JSON), 'zh_CN', 100, 1, NOW(), NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}kefu_auto_reply` t WHERE t.title = '人工客服' AND t.lang = 'zh_CN' LIMIT 1);

INSERT INTO `{{prefix}}kefu_auto_reply` (`title`, `trigger_type`, `keywords`, `reply_type`, `reply_content`, `lang`, `priority`, `status`, `created_at`, `updated_at`)
SELECT 'Deposit Questions', 2, CAST('["deposit", "how to deposit", "recharge"]' AS JSON), 1, CAST('{"text": "Deposit Steps:\\n1. Click the \\"Deposit\\" button on the homepage\\n2. Select the cryptocurrency and network\\n3. Copy the deposit address or scan the QR code\\n4. Transfer from your wallet to this address\\n\\nDeposits usually arrive within 10-30 minutes."}' AS JSON), 'en', 10, 1, NOW(), NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}kefu_auto_reply` t WHERE t.title = 'Deposit Questions' AND t.lang = 'en' LIMIT 1);

INSERT INTO `{{prefix}}kefu_auto_reply` (`title`, `trigger_type`, `keywords`, `reply_type`, `reply_content`, `lang`, `priority`, `status`, `created_at`, `updated_at`)
SELECT 'Withdrawal Questions', 2, CAST('["withdraw", "withdrawal", "how to withdraw"]' AS JSON), 1, CAST('{"text": "Withdrawal Steps:\\n1. Go to Assets page\\n2. Select the cryptocurrency to withdraw\\n3. Click \\"Withdraw\\"\\n4. Enter withdrawal address and amount\\n5. Complete security verification\\n\\nWithdrawals usually arrive within 1-2 hours, depending on blockchain network conditions."}' AS JSON), 'en', 10, 1, NOW(), NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}kefu_auto_reply` t WHERE t.title = 'Withdrawal Questions' AND t.lang = 'en' LIMIT 1);

INSERT INTO `{{prefix}}kefu_auto_reply` (`title`, `trigger_type`, `keywords`, `reply_type`, `reply_content`, `lang`, `priority`, `status`, `created_at`, `updated_at`)
SELECT 'Trading Questions', 2, CAST('["trade", "how to trade", "trading", "buy", "sell"]' AS JSON), 1, CAST('{"text": "Trading Guide:\\n1. Go to Trading page\\n2. Select trading pair (e.g., BTC/USDT)\\n3. Choose order type (Limit/Market)\\n4. Enter price and quantity\\n5. Confirm and submit order\\n\\nIf you need more help, please tell me your specific issue."}' AS JSON), 'en', 8, 1, NOW(), NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}kefu_auto_reply` t WHERE t.title = 'Trading Questions' AND t.lang = 'en' LIMIT 1);

INSERT INTO `{{prefix}}kefu_auto_reply` (`title`, `trigger_type`, `keywords`, `reply_type`, `reply_content`, `lang`, `priority`, `status`, `created_at`, `updated_at`)
SELECT 'Human Support', 1, CAST('["human", "support", "agent", "representative"]' AS JSON), 1, CAST('{"text": "Connecting you to a human agent, please wait..."}' AS JSON), 'en', 100, 1, NOW(), NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `{{prefix}}kefu_auto_reply` t WHERE t.title = 'Human Support' AND t.lang = 'en' LIMIT 1);
