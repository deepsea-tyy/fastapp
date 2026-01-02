-- 插入现货（spot）类型的测试数据
-- 为 market_ticker 表插入常见的现货交易对测试数据

-- 获取当前时间戳（毫秒）
SET @current_timestamp = UNIX_TIMESTAMP(NOW(3)) * 1000;

-- 插入测试数据
INSERT INTO `market_ticker` (
    `symbol`,
    `market_type`,
    `last_price`,
    `open_price`,
    `high_price`,
    `low_price`,
    `volume`,
    `amount`,
    `quote_volume`,
    `change_percent`,
    `change_amount`,
    `bid_price`,
    `bid_quantity`,
    `ask_price`,
    `ask_quantity`,
    `count`,
    `timestamp`
) VALUES
-- BTC/USDT
('BTCUSDT', 'spot', 
 96500.50,  -- last_price: 最新价格
 96000.00,  -- open_price: 24小时开盘价
 97000.00,  -- high_price: 24小时最高价
 95500.00,  -- low_price: 24小时最低价
 1250.50000000,  -- volume: 24小时成交量（BTC）
 120500000.00,  -- amount: 24小时成交额（USDT）
 120500000.00,  -- quote_volume: 24小时成交额（报价货币）
 0.5200,  -- change_percent: 24小时涨跌幅（0.52%）
 500.50,  -- change_amount: 24小时涨跌额
 96499.00,  -- bid_price: 最佳买一价
 0.12500000,  -- bid_quantity: 最佳买一量
 96501.00,  -- ask_price: 最佳卖一价
 0.15000000,  -- ask_quantity: 最佳卖一量
 15230,  -- count: 24小时成交笔数
 @current_timestamp  -- timestamp: 更新时间戳
),

-- ETH/USDT
('ETHUSDT', 'spot',
 3450.75,
 3400.00,
 3500.00,
 3380.00,
 8500.25000000,
 29300000.00,
 29300000.00,
 1.4900,
 50.75,
 3450.50,
 2.50000000,
 3451.00,
 2.80000000,
 28450,
 @current_timestamp
),

-- BNB/USDT
('BNBUSDT', 'spot',
 625.80,
 620.00,
 630.00,
 618.00,
 15000.00000000,
 9375000.00,
 9375000.00,
 0.9350,
 5.80,
 625.70,
 5.00000000,
 625.90,
 5.20000000,
 12500,
 @current_timestamp
),

-- SOL/USDT
('SOLUSDT', 'spot',
 185.50,
 180.00,
 190.00,
 178.00,
 50000.00000000,
 9250000.00,
 9250000.00,
 3.0556,
 5.50,
 185.45,
 10.00000000,
 185.55,
 10.50000000,
 18500,
 @current_timestamp
),

-- ADA/USDT
('ADAUSDT', 'spot',
 0.4850,
 0.4800,
 0.4900,
 0.4750,
 5000000.00000000,
 2425000.00,
 2425000.00,
 1.0417,
 0.0050,
 0.4848,
 5000.00000000,
 0.4852,
 5200.00000000,
 12500,
 @current_timestamp
),

-- DOGE/USDT
('DOGEUSDT', 'spot',
 0.1250,
 0.1200,
 0.1300,
 0.1180,
 100000000.00000000,
 12500000.00,
 12500000.00,
 4.1667,
 0.0050,
 0.1248,
 50000.00000000,
 0.1252,
 55000.00000000,
 25000,
 @current_timestamp
),

-- XRP/USDT
('XRPUSDT', 'spot',
 0.6250,
 0.6200,
 0.6300,
 0.6150,
 20000000.00000000,
 12500000.00,
 12500000.00,
 0.8065,
 0.0050,
 0.6248,
 10000.00000000,
 0.6252,
 11000.00000000,
 18500,
 @current_timestamp
),

-- MATIC/USDT
('MATICUSDT', 'spot',
 0.9850,
 0.9800,
 1.0000,
 0.9750,
 15000000.00000000,
 14775000.00,
 14775000.00,
 0.5102,
 0.0050,
 0.9848,
 8000.00000000,
 0.9852,
 8500.00000000,
 12000,
 @current_timestamp
),

-- DOT/USDT
('DOTUSDT', 'spot',
 7.2500,
 7.2000,
 7.3000,
 7.1500,
 500000.00000000,
 3625000.00,
 3625000.00,
 0.6944,
 0.0500,
 7.2480,
 500.00000000,
 7.2520,
 550.00000000,
 8500,
 @current_timestamp
),

-- AVAX/USDT
('AVAXUSDT', 'spot',
 42.50,
 42.00,
 43.00,
 41.50,
 250000.00000000,
 10625000.00,
 10625000.00,
 1.1905,
 0.50,
 42.48,
 100.00000000,
 42.52,
 110.00000000,
 9500,
 @current_timestamp
),

-- LINK/USDT
('LINKUSDT', 'spot',
 18.75,
 18.50,
 19.00,
 18.30,
 800000.00000000,
 15000000.00,
 15000000.00,
 1.3514,
 0.25,
 18.74,
 200.00000000,
 18.76,
 220.00000000,
 11200,
 @current_timestamp
),

-- UNI/USDT
('UNIUSDT', 'spot',
 12.50,
 12.30,
 12.70,
 12.20,
 600000.00000000,
 7500000.00,
 7500000.00,
 1.6260,
 0.20,
 12.49,
 300.00000000,
 12.51,
 320.00000000,
 8800,
 @current_timestamp
),

-- LTC/USDT
('LTCUSDT', 'spot',
 95.50,
 95.00,
 96.00,
 94.50,
 50000.00000000,
 4775000.00,
 4775000.00,
 0.5263,
 0.50,
 95.48,
 50.00000000,
 95.52,
 55.00000000,
 7200,
 @current_timestamp
),

-- ATOM/USDT
('ATOMUSDT', 'spot',
 10.25,
 10.20,
 10.30,
 10.15,
 300000.00000000,
 3075000.00,
 3075000.00,
 0.4902,
 0.05,
 10.248,
 100.00000000,
 10.252,
 110.00000000,
 6500,
 @current_timestamp
),

-- ETC/USDT
('ETCUSDT', 'spot',
 28.50,
 28.30,
 28.80,
 28.20,
 200000.00000000,
 5700000.00,
 5700000.00,
 0.7067,
 0.20,
 28.49,
 80.00000000,
 28.51,
 85.00000000,
 5800,
 @current_timestamp
),

-- FIL/USDT
('FILUSDT', 'spot',
 5.80,
 5.75,
 5.85,
 5.70,
 800000.00000000,
 4640000.00,
 4640000.00,
 0.8696,
 0.05,
 5.798,
 200.00000000,
 5.802,
 220.00000000,
 5200,
 @current_timestamp
);

-- 查询插入的数据
SELECT 
    symbol,
    market_type,
    last_price,
    change_percent,
    volume,
    timestamp
FROM `market_ticker`
WHERE `market_type` = 'spot'
ORDER BY `symbol`;


INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(1, 'BTC', '[{"lang": "en", "text": "Bitcoin"}]', '/uploads/20240727/675795195094175744.png', 'BNB', NULL, 18, 0, 1, 0, 1, 1, 1.000000000000000000, 1.000000000000000000, 0.100000000000000000, 'fixed', 111111111.00, 1, 11212121212.00, 211222111.00000000, NULL, 12121212121.00000000, '2025-12-23', 'aa', 'bb', '[{"lang": "zh_CN", "text": "<p>发动机解放东路发绝对拉风就到了；发动机解放东路发绝对拉风就到了；发动机解放东路发绝对拉风就到了；111</p>\\n<p>发动机解放东路发绝对拉风就到了；发动机解放东路发绝对拉风就到了；发动机解放东路发绝对拉风就到了；</p>\\n<p>发动机解放东路发绝对拉风就到了；发动机解放东路发绝对拉风就到了；发动机解放东路发绝对拉风就到了；</p>\\n<p>发动机解放东路发绝对拉风就到了；发动机解放东路发绝对拉风就到了；发动机解放东路发绝对拉风就到了；</p>\\n<p>发动机解放东路发绝对拉风就到了；发动机解放东路发绝对拉风就到了；发动机解放东路发绝对拉风就到了；</p>"}]', '{"github": "http://localhost:2888/#/ds/ex/admin/currency", "medium": "", "reddit": "http://localhost:2888/#/ds/ex/admin/currency", "discord": "http://localhost:2888/#/ds/ex/admin/currency", "twitter": "http://localhost:2888/#/ds/ex/admin/currency", "website": "http://localhost:2888/#/ds/ex/admin/currency", "youtube": "http://localhost:2888/#/ds/ex/admin/currency", "explorer": "http://localhost:2888/#/ds/ex/admin/currency", "facebook": "http://localhost:2888/#/ds/ex/admin/currency", "telegram": "http://localhost:2888/#/ds/ex/admin/currency", "whitepaper": "http://localhost:2888/#/ds/ex/admin/currency"}', '["Privacy", "Stablecoin", "Web3"]', 2, 1, 1, 1, 0, 100, NULL, '2025-12-22 14:36:48');
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(2, 'ETH', '[{"lang": "en", "text": "Ethereum"}]', '/uploads/20240727/675798170810257408.png', 'BNB', NULL, 18, 0, 1, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '[{"lang": "zh_CN", "text": ""}]', NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, '2025-12-22 12:34:14');
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(3, 'USDT', '[{"lang": "en", "text": "USDT"}]', '/uploads/20240727/675799000116436992.png', 'BNB', NULL, 18, 1, 1, 1, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '[{"lang": "zh_CN", "text": ""}]', NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, '2025-12-21 10:46:07');
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(4, 'SOL', '[{"lang": "en", "text": "Solana"}]', '/uploads/20240727/675799889237577728.png', 'BNB', NULL, 18, 0, 1, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '[{"lang": "zh_CN", "text": ""}]', NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, '2025-12-22 12:34:40');
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(5, 'BNB', '[{"lang": "en", "text": "BNB"}, {"lang": "zh_CN", "text": "币安币"}]', '/uploads/20240727/675800412841906176.png', 'BNB', NULL, 18, 0, 1, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '[{"lang": "zh_CN", "text": ""}]', NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, '2025-12-22 12:34:24');
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(6, 'USDC', '[{"lang": "en", "text": "USDC"}, {"lang": "zh_CN", "text": "美元币"}]', '/uploads/20240727/675800729251819520.png', 'BNB', NULL, 18, 1, 1, 1, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '[{"lang": "zh_CN", "text": ""}]', NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, '2025-12-21 10:45:57');
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(7, 'XRP', '[{"lang": "en", "text": "XRP"}, {"lang": "zh_CN", "text": "瑞波币"}]', '/uploads/20240727/675800931119480832.png', 'BNB', NULL, 18, 0, 0, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, NULL);
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(8, 'DOGE', '[{"lang": "en", "text": "Dogecoin"}, {"lang": "zh_CN", "text": "狗狗币"}]', '/uploads/20240727/675801128205627392.png', 'BNB', NULL, 18, 0, 1, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '[{"lang": "zh_CN", "text": ""}]', NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, '2025-12-22 12:34:48');
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(9, 'TON', '[{"lang": "en", "text": "Toncoin"}]', '/uploads/20240727/675801339946684416.png', 'BNB', NULL, 18, 0, 1, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '[{"lang": "zh_CN", "text": ""}]', NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, '2025-12-22 12:34:56');
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(10, 'ADA', '[{"lang": "en", "text": "Cardano"}, {"lang": "zh_CN", "text": "艾达币"}]', '/uploads/20240727/675801906886545408.png', 'BNB', NULL, 18, 0, 0, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, NULL);
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(11, 'TRX', '[{"lang": "en", "text": "TRON"}, {"lang": "zh_CN", "text": "波场币"}]', '/uploads/20240727/675802163569577984.png', 'BNB', NULL, 18, 0, 1, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '[{"lang": "zh_CN", "text": ""}]', NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, '2025-12-22 12:35:11');
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(12, 'AVAX', '[{"lang": "en", "text": "Avalanche"}, {"lang": "zh_CN", "text": "雪崩币"}]', '/uploads/20240727/675803106977587200.png', 'BNB', NULL, 18, 0, 0, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, NULL);
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(13, 'SHIB', '[{"lang": "en", "text": "Shiba Inu"}, {"lang": "zh_CN", "text": "柴犬币"}]', '/uploads/20240727/675803586227154944.png', 'BNB', NULL, 18, 0, 0, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, NULL);
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(14, 'DOT', '[{"lang": "en", "text": "Polkadot"}, {"lang": "zh_CN", "text": "波卡币"}]', '/uploads/20240727/675803917627494400.gif', 'BNB', NULL, 18, 0, 0, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, NULL);
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(15, 'LINK', '[{"lang": "en", "text": "Chainlink"}]', '/uploads/20240727/675804771617148928.png', 'BNB', NULL, 18, 0, 0, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, NULL);
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(16, 'BCH', '[{"lang": "en", "text": "Bitcoin Cash"}, {"lang": "zh_CN", "text": "比特币现金"}]', '/uploads/20240727/675805319913353216.png', 'BNB', NULL, 18, 0, 0, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, NULL);
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(17, 'NEAR', '[{"lang": "en", "text": "NEAR Protocol"}]', '/uploads/20240727/675805583265308672.png', 'BNB', NULL, 18, 0, 0, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, NULL);
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(18, 'LEO', '[{"lang": "en", "text": "UNUS SED LEO"}]', '/uploads/20240727/675805696373121024.png', 'BNB', NULL, 18, 0, 0, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, NULL);
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(19, 'LTC', '[{"lang": "en", "text": "Litecoin"}, {"lang": "zh_CN", "text": "莱特币"}]', '/uploads/20240727/675805853797912576.png', 'BNB', NULL, 18, 0, 0, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, NULL);
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(20, 'DAI', '[{"lang": "en", "text": "Dai"}]', '/uploads/20240727/675806396050124800.png', 'BNB', NULL, 18, 0, 0, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, NULL);
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(21, 'FIL', '[{"lang": "en", "text": "Filecoin"}]', '/uploads/20240727/723625187555315712.png', 'BNB', NULL, 18, 0, 0, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, NULL);
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(22, 'USD', '[{"lang": "en", "text": "U.S.Dollar"}, {"lang": "zh_CN", "text": "美元"}]', '/uploads/20240727/735449832461701120.png', NULL, NULL, 18, 2, 0, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, NULL);
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(23, 'CNY', '[{"lang": "en", "text": "Renminbi Yuan"}, {"lang": "zh_CN", "text": "人民币"}]', '/uploads/20240727/735449953207328768.png', NULL, NULL, 18, 2, 0, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, NULL);
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(24, 'SUR', '[{"lang": "en", "text": "Russian Ruble"}, {"lang": "zh_CN", "text": "卢布"}]', '/uploads/20240727/735450326156455936.png', NULL, NULL, 18, 2, 0, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, NULL);
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(25, 'INR', '[{"lang": "en", "text": "Indian Rupee"}, {"lang": "zh_CN", "text": "卢比"}]', '/uploads/20240727/735450513952219136.png', NULL, NULL, 18, 2, 0, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, NULL);
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(26, 'CAD', '[{"lang": "en", "text": "Canadian Dollar"}, {"lang": "zh_CN", "text": "加元"}]', '/uploads/20240727/735450675500036096.png', NULL, NULL, 18, 2, 0, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, NULL);
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(27, 'AUD', '[{"lang": "en", "text": "Australian Dollar"}, {"lang": "zh_CN", "text": "澳大利亚元"}]', '/uploads/20240727/735450726393716736.png', NULL, NULL, 18, 2, 0, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, NULL);
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(28, 'FRF', '[{"lang": "en", "text": "French Franc"}, {"lang": "zh_CN", "text": "法郎"}]', '/uploads/20240727/735455857524875264.png', NULL, NULL, 18, 2, 0, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, NULL);
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(29, 'GBP', '[{"lang": "en", "text": "Pound, Sterling"}, {"lang": "zh_CN", "text": "英镑"}]', '/uploads/20240727/735450949312581632.png', NULL, NULL, 18, 2, 0, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, NULL);
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(30, 'JPY', '[{"lang": "en", "text": " Japanese Yen"}, {"lang": "zh_CN", "text": "日圆"}]', '/uploads/20240727/735451007122673664.png', NULL, NULL, 18, 2, 0, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, NULL);
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(31, 'ITL', '[{"lang": "en", "text": " Italian Lira"}, {"lang": "zh_CN", "text": "里拉"}]', '/uploads/20240727/735451058066702336.png', NULL, NULL, 18, 2, 0, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, NULL);
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(32, 'MXP', '[{"lang": "en", "text": "Mexican Peso"}, {"lang": "zh_CN", "text": "墨西哥比索"}]', '/uploads/20240727/735451683831693312.png', NULL, NULL, 18, 2, 0, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, NULL);
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(33, 'IDR', '[{"lang": "en", "text": "Indonesian Rupiah"}, {"lang": "zh_CN", "text": "盾"}]', '/uploads/20240727/735453118308814848.png', NULL, NULL, 18, 2, 0, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, NULL);
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(34, 'TRL', '[{"lang": "en", "text": "Turkish Pound"}, {"lang": "zh_CN", "text": "土耳其镑"}]', '/uploads/20240727/735454264427556864.png', NULL, NULL, 18, 2, 0, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, NULL);
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(35, 'SEK', '[{"lang": "en", "text": "Swedish Krona"}, {"lang": "zh_CN", "text": "瑞典克朗"}]', '/uploads/20240727/735455010283855872.png', NULL, NULL, 18, 2, 0, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, NULL);
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(36, 'THP', '[{"lang": "en", "text": "Thai Baht"}, {"lang": "zh_CN", "text": "泰铢"}]', '/uploads/20240727/735455173656195072.png', NULL, NULL, 18, 2, 0, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, NULL);
INSERT INTO currency (id, symbol, name, logo, `chain`, contract_address, decimals, `type`, is_base_currency, is_quote_currency, deposit_enabled, withdraw_enabled, min_deposit_amount, min_withdraw_amount, withdraw_fee, withdraw_fee_type, market_cap, market_cap_rank, fully_diluted_market_cap, circulating_supply, total_supply, max_supply, launch_date, consensus_algorithm, `algorithm`, description, links, tags, popularity_rank, trading_volume_rank, status, is_hot, is_recommended, sort, created_at, updated_at) VALUES(37, 'BRL', '[{"lang": "en", "text": "BRL"}, {"lang": "zh_CN", "text": "巴西雷亚尔"}]', '/uploads/20240727/735451423990353920.png', 'BNB', NULL, 18, 0, 0, 0, 1, 1, NULL, NULL, NULL, 'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '[{"lang": "zh_CN", "text": ""}]', NULL, NULL, NULL, NULL, 1, 0, 0, 100, NULL, '2025-12-22 10:23:40');












