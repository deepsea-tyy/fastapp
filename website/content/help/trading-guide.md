---
title: 交易指南
description: 交易操作指南和最佳实践
---

# 交易指南

本指南将帮助您了解如何进行交易操作，以及一些最佳实践。

## 交易类型

### 限价单 (Limit Order)

限价单是指定价格的订单，只有当市场价格达到或优于指定价格时才会成交。

**适用场景：**
- 希望以特定价格买入或卖出
- 不急于成交，可以等待更好的价格

**示例：**

```javascript
{
  "symbol": "BTC/USDT",
  "side": "buy",
  "type": "limit",
  "price": "50000.00",
  "amount": "0.001"
}
```

### 市价单 (Market Order)

市价单是以当前市场价格立即成交的订单。

**适用场景：**
- 需要快速成交
- 对价格要求不高

**示例：**

```javascript
{
  "symbol": "BTC/USDT",
  "side": "buy",
  "type": "market",
  "amount": "0.001"
}
```

### 止损单 (Stop Loss Order)

止损单是当价格达到指定止损价格时触发的订单。

**适用场景：**
- 控制风险，限制损失
- 自动化交易策略

## 交易策略

### 网格交易

网格交易是一种在价格区间内设置多个买卖订单的策略。

**优点：**
- 可以在震荡市场中获利
- 自动化执行，无需时刻关注

**缺点：**
- 单边行情可能亏损
- 需要足够的资金支持

### 定投策略

定期定额投资策略，无论价格如何都按计划买入。

**优点：**
- 降低平均成本
- 适合长期投资

**缺点：**
- 需要长期坚持
- 短期可能亏损

## 风险管理

### 仓位管理

::: tip 建议
建议单次交易不超过总资金的 10%，分散投资降低风险。
:::

### 止损设置

设置合理的止损点，避免大额亏损。

**止损比例建议：**
- 保守型：2-3%
- 稳健型：3-5%
- 激进型：5-10%

### 杠杆使用

::: warning 风险提示
杠杆交易风险极高，可能导致本金全部损失。请谨慎使用，建议新手不要使用杠杆。
:::

## 订单管理

### 查询订单

定期查询订单状态，了解交易情况。

```javascript
// 查询所有未完成订单
GET /orders?status=pending

// 查询历史订单
GET /orders?status=filled&startTime=1704067200000&endTime=1704153600000
```

### 取消订单

如果市场情况变化，及时取消不需要的订单。

```javascript
DELETE /order/{orderId}
```

### 批量操作

对于多个订单，可以使用批量接口提高效率。

```javascript
POST /orders/batch
{
  "orders": [
    { "orderId": "123", "action": "cancel" },
    { "orderId": "456", "action": "cancel" }
  ]
}
```

## 最佳实践

### 1. 使用 WebSocket 获取实时行情

WebSocket 可以提供更及时的行情数据，适合高频交易。

```javascript
const ws = new WebSocket('wss://ws.exchange.com/v1');

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  // 处理行情数据
};
```

### 2. 实现订单重试机制

网络可能不稳定，实现重试机制可以提高成功率。

```javascript
async function placeOrderWithRetry(orderData, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await placeOrder(orderData);
    } catch (error) {
      if (i === maxRetries - 1) throw error;
      await sleep(1000 * (i + 1)); // 指数退避
    }
  }
}
```

### 3. 监控账户余额

定期检查账户余额，确保有足够的资金进行交易。

```javascript
async function checkBalance(currency) {
  const balance = await getBalance(currency);
  if (balance.available < minAmount) {
    console.warn(`余额不足: ${currency}`);
  }
}
```

### 4. 记录交易日志

记录所有交易操作，便于分析和审计。

```javascript
function logTrade(order) {
  console.log({
    timestamp: Date.now(),
    orderId: order.orderId,
    symbol: order.symbol,
    side: order.side,
    price: order.price,
    amount: order.amount
  });
}
```

## 常见问题

### Q: 订单为什么没有立即成交？

A: 限价单需要等待市场价格达到指定价格。如果使用市价单，通常会在几秒内成交。

### Q: 如何计算手续费？

A: 手续费 = 成交金额 × 手续费率。手续费率根据您的交易等级和交易量确定。

### Q: 最小交易金额是多少？

A: 不同交易对的最小交易金额不同，请查看交易对信息中的 `minAmount` 字段。

### Q: 如何避免滑点？

A: 使用限价单可以避免滑点，但可能无法立即成交。对于大额订单，建议分批下单。

## 相关资源

- [API 参考](/help/api-reference) - 查看完整的 API 文档
- [快速开始](/help/getting-started) - 了解如何开始使用

