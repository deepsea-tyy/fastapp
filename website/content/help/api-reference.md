---
title: API 参考
description: 完整的 API 接口文档
---

# API 参考

本文档提供了交易所 API 的完整参考。

## 基础信息

- **Base URL**: `https://api.exchange.com/v1`
- **认证方式**: HMAC-SHA256 签名
- **数据格式**: JSON
- **字符编码**: UTF-8

## 通用响应格式

所有 API 响应都遵循以下格式：

```json
{
  "code": 200,
  "message": "success",
  "data": {},
  "timestamp": 1704067200000
}
```

### 响应码说明

| 状态码 | 说明 |
|--------|------|
| 200 | 请求成功 |
| 400 | 请求参数错误 |
| 401 | 认证失败 |
| 403 | 权限不足 |
| 404 | 资源不存在 |
| 500 | 服务器错误 |

## 公共接口

### 获取服务器时间

获取服务器当前时间戳。

**请求：**

```http
GET /time
```

**响应：**

```json
{
  "code": 200,
  "data": {
    "timestamp": 1704067200000,
    "serverTime": "2024-01-01T00:00:00Z"
  }
}
```

### 获取交易对信息

获取所有可用的交易对信息。

**请求：**

```http
GET /symbols
```

**响应：**

```json
{
  "code": 200,
  "data": [
    {
      "symbol": "BTC/USDT",
      "baseCurrency": "BTC",
      "quoteCurrency": "USDT",
      "pricePrecision": 2,
      "amountPrecision": 8,
      "minAmount": 0.001,
      "status": "trading"
    }
  ]
}
```

## 账户接口

### 获取账户余额

获取账户所有币种的余额信息。

**请求：**

```http
GET /account/balance
```

**请求头：**

```
X-API-Key: your-api-key
X-Signature: your-signature
X-Timestamp: 1704067200000
```

**响应：**

```json
{
  "code": 200,
  "data": {
    "balances": [
      {
        "currency": "BTC",
        "available": "1.50000000",
        "frozen": "0.50000000",
        "total": "2.00000000"
      }
    ]
  }
}
```

## 交易接口

### 下单

创建新的订单。

**请求：**

```http
POST /order
```

**请求体：**

```json
{
  "symbol": "BTC/USDT",
  "side": "buy",
  "type": "limit",
  "price": "50000.00",
  "amount": "0.001"
}
```

**响应：**

```json
{
  "code": 200,
  "data": {
    "orderId": "123456789",
    "symbol": "BTC/USDT",
    "side": "buy",
    "type": "limit",
    "price": "50000.00",
    "amount": "0.001",
    "status": "pending"
  }
}
```

### 查询订单

查询订单详情。

**请求：**

```http
GET /order/{orderId}
```

**响应：**

```json
{
  "code": 200,
  "data": {
    "orderId": "123456789",
    "symbol": "BTC/USDT",
    "side": "buy",
    "type": "limit",
    "price": "50000.00",
    "amount": "0.001",
    "filledAmount": "0.001",
    "status": "filled",
    "createTime": 1704067200000,
    "updateTime": 1704067201000
  }
}
```

## WebSocket 接口

### 连接地址

```
wss://ws.exchange.com/v1
```

### 订阅行情

```json
{
  "action": "subscribe",
  "channel": "ticker",
  "symbol": "BTC/USDT"
}
```

### 接收消息

```json
{
  "channel": "ticker",
  "symbol": "BTC/USDT",
  "data": {
    "price": "50000.00",
    "volume": "100.50",
    "change": "2.5",
    "changePercent": "5.0"
  }
}
```

## 错误处理

### 错误响应格式

```json
{
  "code": 400,
  "message": "Invalid parameter",
  "data": null,
  "timestamp": 1704067200000
}
```

### 常见错误

| 错误码 | 错误信息 | 解决方案 |
|--------|----------|----------|
| 40001 | 参数缺失 | 检查请求参数是否完整 |
| 40002 | 参数格式错误 | 检查参数类型和格式 |
| 40003 | 签名错误 | 检查签名生成算法 |
| 40004 | 时间戳过期 | 检查服务器时间同步 |
| 50001 | 余额不足 | 检查账户余额 |

## 限流说明

API 请求频率限制：

- 公共接口：每秒 10 次
- 私有接口：每秒 5 次
- WebSocket：每个连接每秒 100 次

超过限制将返回 429 状态码。

