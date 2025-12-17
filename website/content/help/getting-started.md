---
title: 快速开始
description: 快速了解如何开始使用交易所 API
---

# 快速开始

本指南将帮助您快速开始使用交易所 API。

## 前置要求

在使用 API 之前，您需要：

1. 注册账户并完成实名认证
2. 创建 API Key 和 Secret
3. 了解基本的 HTTP 请求和 JSON 格式

## 获取 API 凭证

### 步骤 1: 登录账户

访问交易所官网，使用您的账户登录。

### 步骤 2: 创建 API Key

1. 进入「API 管理」页面
2. 点击「创建 API Key」
3. 设置 API Key 名称和权限
4. 保存 API Key 和 Secret（Secret 只显示一次）

::: warning 安全提示
请妥善保管您的 API Key 和 Secret，不要泄露给他人。建议设置 IP 白名单限制访问。
:::

## 第一个 API 请求

### 获取服务器时间

```bash
curl -X GET "https://api.exchange.com/v1/time"
```

**响应示例：**

```json
{
  "code": 200,
  "data": {
    "timestamp": 1704067200000,
    "serverTime": "2024-01-01T00:00:00Z"
  }
}
```

### 获取账户信息

```bash
curl -X GET "https://api.exchange.com/v1/account" \
  -H "X-API-Key: your-api-key" \
  -H "X-Signature: your-signature" \
  -H "X-Timestamp: 1704067200000"
```

## 认证方式

交易所 API 使用 HMAC-SHA256 签名认证。

### 签名生成步骤

1. 将请求参数按字母顺序排序
2. 拼接成查询字符串
3. 使用 Secret 对字符串进行 HMAC-SHA256 加密
4. 将签名添加到请求头

### 示例代码

```javascript
const crypto = require('crypto');

function generateSignature(secret, params) {
  const sortedParams = Object.keys(params)
    .sort()
    .map(key => `${key}=${params[key]}`)
    .join('&');
  
  return crypto
    .createHmac('sha256', secret)
    .update(sortedParams)
    .digest('hex');
}
```

## 下一步

- 查看 [API 参考](/help/api-reference) 了解所有可用接口
- 阅读 [交易指南](/help/trading-guide) 学习交易操作

