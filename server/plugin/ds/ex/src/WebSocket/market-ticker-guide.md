# Market Ticker WebSocket 推送功能

## 功能概述

为交易所增加了币种 ticker 实时推送功能，采用**动态订阅策略**：

- **热门币种**（前20个）：每秒推送到 `market:hot` 房间，全量更新
- **其他币种**：每3秒推送到对应的 `market:{symbol}` 房间，按需订阅
- **模拟数据**：使用 while 循环生成模拟价格数据，无需对接三方接口

---

## 文件清单

### 1. WebSocket 处理器
**路径**: `server/plugin/ds/ex/src/WebSocket/MarketWsHandler.php`

**功能**:
- 处理客户端的订阅/取消订阅请求
- 支持单个订阅、批量订阅
- 支持热门币种订阅

**支持的 Actions**:
```json
{
  "market.subscribe": "订阅单个交易对",
  "market.subscribe.batch": "批量订阅交易对",
  "market.unsubscribe": "取消订阅单个交易对",
  "market.unsubscribe.batch": "批量取消订阅",
  "market.subscribe.hot": "订阅热门币种（前20）",
  "market.unsubscribe.hot": "取消订阅热门币种"
}
```

---

### 2. 数据推送进程
**路径**: `server/plugin/ds/ex/src/Process/MarketTickerProcess.php`

**功能**:
- 自动启动的常驻进程（Hyperf Process）
- 每秒推送热门币种数据
- 每3秒推送其他订阅的币种数据
- 使用 while 循环模拟价格波动

**支持的币种**: 40个交易对
- 热门币种：BTC/USDT, ETH/USDT, BNB/USDT 等（前20个）
- 其他币种：FIL/USDT, NEAR/USDT, VET/USDT 等

**数据字段**:
```json
{
  "symbol": "BTC/USDT",
  "price": "50000.00",
  "change_24h": "2.50",
  "volume_24h": "1000000",
  "high_24h": "51000.00",
  "low_24h": "49000.00",
  "timestamp": 1703001234
}
```

---

### 3. 测试页面
**路径**: `server/app/Websocket/market_test.html`

**功能**:
- 可视化的 WebSocket 测试工具
- 实时显示价格更新
- 支持连接/断开、订阅/取消订阅操作
- 显示统计信息和日志

---

## 使用步骤

### 1. 启动服务器

确保 Hyperf WebSocket 服务器已启动：

```bash
cd server
php bin/hyperf.php start
```

进程会自动启动 `MarketTickerProcess`，日志输出示例：
```
[2025-12-22 15:00:00] MarketTickerProcess: Market Ticker Process started
[2025-12-22 15:00:01] MarketTickerProcess: Pushed hot tickers to 1 subscribers
```

---

### 2. 打开测试页面

在浏览器中打开：
```
file:///Users/wangxiansheng/Workspace/fastapp/server/app/Websocket/market_test.html
```

或者通过 HTTP 服务器访问（如果配置了静态文件服务）。

---

### 3. 配置连接参数

在页面上配置：
- **WebSocket URL**: `ws://127.0.0.1:9502`（根据实际端口调整）
- **Token**: 替换为有效的 JWT Token（从登录接口获取）

---

### 4. 测试流程

#### 步骤1: 连接 WebSocket
1. 点击 **"连接 WebSocket"** 按钮
2. 查看日志，应该显示：
   ```
   [时间] 连接中...
   [时间] WebSocket 连接成功
   [时间] Auth successfully
   ```

#### 步骤2: 订阅热门币种
1. 点击 **"订阅热门币种"** 按钮
2. 查看日志：
   ```
   [时间] 订阅热门币种...
   [时间] Subscribed to hot tickers successfully
   ```
3. 页面会每秒更新热门币种（前20个）的价格

#### 步骤3: 订阅单个币种（可选）
可以通过浏览器控制台手动订阅：
```javascript
// 订阅单个币种
sendMessage('market.subscribe', { symbol: 'FIL/USDT', fd: 12345 });

// 批量订阅
sendMessage('market.subscribe.batch', {
  symbols: ['FIL/USDT', 'NEAR/USDT', 'VET/USDT'],
  fd: 12345
});
```

---

## WebSocket 协议

### 客户端发送消息格式

```json
{
  "action": "market.subscribe.hot",
  "data": {
    "fd": 12345
  },
  "op_id": "op_123456"
}
```

### 服务端推送消息格式

#### 热门币种推送（每秒）
```json
{
  "success": true,
  "data": {
    "event": "market.hot.tickers",
    "tickers": [
      {
        "symbol": "BTC/USDT",
        "price": "50000.00",
        "change_24h": "2.50",
        "volume_24h": "1000000",
        "high_24h": "51000.00",
        "low_24h": "49000.00",
        "timestamp": 1703001234
      },
      // ... 其他19个币种
    ],
    "timestamp": 1703001234
  },
  "op_id": "",
  "timestamp": 1703001234
}
```

#### 单个币种推送（每3秒）
```json
{
  "success": true,
  "data": {
    "event": "market.ticker",
    "symbol": "FIL/USDT",
    "price": "5.50",
    "change_24h": "-1.20",
    "volume_24h": "5000000",
    "high_24h": "5.80",
    "low_24h": "5.40",
    "timestamp": 1703001234
  },
  "op_id": "",
  "timestamp": 1703001234
}
```

---

## 动态订阅策略说明

### 策略设计
根据 `docs/server/websocket/dynamic-subscription-strategy.md` 实现：

1. **热门币种房间** (`market:hot`)
   - 前20个高流动性币种
   - 每秒全量推送
   - 适合首页展示

2. **单个币种房间** (`market:{symbol}`)
   - 按需订阅
   - 每3秒推送
   - 适合详情页或列表可视区域

3. **批量订阅**
   - 支持一次订阅最多20个币种
   - 用于列表滚动时的动态订阅

### 优化建议

#### 前端优化
- **防抖**: 滚动事件 500ms 防抖
- **缓冲区**: 订阅可视区域上下各5个 item
- **批量操作**: 使用批量订阅接口减少消息数

#### 后端优化
- **房间检查**: 推送前检查房间成员数，避免无效推送
- **频率控制**: 热门币种1秒，普通币种3秒
- **订阅限制**: 单次订阅最多20个币种

---

## 性能监控

### 测试页面统计
测试页面会实时显示：
- **已订阅币种**: 当前订阅的币种数量
- **接收消息数**: 累计接收的消息数
- **更新频率**: 每秒接收的消息数

### 服务器日志
进程会输出推送日志：
```
[2025-12-22 15:00:01] MarketTickerProcess: Pushed hot tickers to 3 subscribers
[2025-12-22 15:00:04] MarketTickerProcess: Pushed 5 normal tickers
```

---

## 常见问题

### Q1: 连接失败怎么办？
**A**: 检查以下项：
1. Hyperf 服务是否启动：`php bin/hyperf.php start`
2. WebSocket 端口是否正确（默认9502）
3. JWT Token 是否有效

### Q2: 没有收到推送数据？
**A**:
1. 确认已成功订阅（查看日志）
2. 检查 `MarketTickerProcess` 进程是否运行
3. 查看服务器日志 `runtime/logs/hyperf.log`

### Q3: 如何增加新的币种？
**A**:
编辑 `MarketTickerProcess.php` 的 `$allSymbols` 数组：
```php
private array $allSymbols = [
    // 在这里添加新币种
    'NEW/USDT',
];
```

### Q4: 如何调整推送频率？
**A**:
修改 `MarketTickerProcess.php` 中的条件：
```php
// 热门币种：修改 sleep(1) 为其他值
sleep(1);  // 1秒

// 普通币种：修改判断条件
if ($currentTime - $this->lastNormalPushTime >= 3) {  // 3秒
```

---

## 扩展开发

### 对接真实交易所 API
将 `generateTickerData()` 方法替换为真实 API 调用：

```php
private function generateTickerData(string $symbol): array
{
    // 调用 Binance API
    $client = new BinanceClient();
    $ticker = $client->getTicker($symbol);

    return [
        'symbol' => $symbol,
        'price' => $ticker['lastPrice'],
        'change_24h' => $ticker['priceChangePercent'],
        'volume_24h' => $ticker['volume'],
        'high_24h' => $ticker['highPrice'],
        'low_24h' => $ticker['lowPrice'],
        'timestamp' => time(),
    ];
}
```

### 添加更多事件类型
在 `MarketWsHandler.php` 中添加新的 action：

```php
public function getActions(): array
{
    return [
        // ... 现有的 actions
        'market.subscribe.kline' => 'subscribeKline',  // K线订阅
        'market.subscribe.depth' => 'subscribeDepth',  // 深度订阅
    ];
}
```

---

## 技术栈

- **框架**: Hyperf 3.x
- **WebSocket**: Swoole WebSocket Server
- **事件系统**: PSR-14 Event Dispatcher
- **房间管理**: Redis Set
- **进程管理**: Hyperf Process

---

## 相关文档

- [动态订阅策略文档](../docs/server/websocket/dynamic-subscription-strategy.md)
- [WebSocket 架构说明](./WsController.php)
- [房间管理器](./WsRoomManager.php)
- [推送事件](./Event/WsPushEvent.php)
