# HTTP 客户端切换配置说明

## 概述

本项目支持在开发和生产环境中灵活切换 HTTP 客户端（DioClient / RestClient），以满足不同场景的需求。

## 设计目的

1. **开发阶段**：统一使用 DioClient，方便调试和查看日志
2. **生产环境**：可配置部分高频接口使用 RestClient，优化性能和包体积
3. **透明切换**：业务代码无需修改，只需配置即可切换

## 使用方式

### 开发阶段（默认）

开发时，所有接口默认使用 DioClient，无需任何配置：

```dart
// 所有接口自动使用 DioClient，会打印请求日志
final ticker = await marketApi.getTickerData(symbol: 'BTC/USDT');
```

### 生产环境配置

生产环境可以配置特定接口使用 RestClient：

```dart
import 'package:fastapp/data/network/config/http_client_config.dart';
import 'package:fastapp/data/network/constants/endpoints.dart';

// 配置高频接口使用 RestClient（优化性能）
HttpClientConfig.addRestClientEndpoint('/api/ds/ex/currency/tickers');
HttpClientConfig.addRestClientEndpoint('/api/ds/ex/currency/marketPair');

// 或者批量配置
HttpClientConfig.addRestClientEndpoints([
  '/api/ds/ex/currency/tickers',
  '/api/ds/ex/currency/marketPair',
  '/api/ds/ex/currency/ticker',
]);
```

### 查看当前配置

```dart
// 查看所有配置的 RestClient 端点
print(HttpClientConfig.restClientEndpoints);

// 检查是否配置了任何 RestClient 端点
if (HttpClientConfig.hasRestClientEndpoints) {
  print('已配置 RestClient 端点');
}
```

### 清空配置

```dart
// 清空所有配置，全部使用 DioClient
HttpClientConfig.clearRestClientEndpoints();
```

## 配置建议

### 适合使用 RestClient 的接口

- ✅ 高频接口（如行情数据、Ticker 数据）
- ✅ 公开接口（不需要认证）
- ✅ 对性能要求极高的接口
- ✅ 不需要日志的接口

### 必须使用 DioClient 的接口

- ❌ 需要认证的接口（用户相关、订单、钱包等）
- ❌ 需要 Token 自动刷新的接口
- ❌ 需要统一错误处理的接口
- ❌ 需要日志的接口（开发调试）

## 配置位置

### 方式一：在应用启动时配置

在 `main.dart` 或应用初始化时配置：

```dart
void main() {
  // 生产环境配置
  if (kReleaseMode) {
    HttpClientConfig.addRestClientEndpoints([
      '/api/ds/ex/currency/tickers',
      '/api/ds/ex/currency/marketPair',
    ]);
  }
  
  runApp(MyApp());
}
```

### 方式二：在配置文件中配置

在 `HttpClientConfig` 类中直接配置：

```dart
static final Set<String> _restClientEndpoints = {
  '/api/ds/ex/currency/tickers',
  '/api/ds/ex/currency/marketPair',
};
```

## 工作原理

1. `HttpClientWrapper` 根据 `HttpClientConfig.shouldUseRestClient()` 判断使用哪个客户端
2. 如果配置使用 RestClient，则调用 RestClient 并手动拼接 URL
3. 如果配置使用 DioClient，则调用 DioClient（自动处理 baseUrl、拦截器等）

## 注意事项

### RestClient 的限制

使用 RestClient 的接口会失去以下功能：
- ❌ 请求日志打印
- ❌ 自动添加 Token 和认证信息
- ❌ 自动刷新过期的 Token
- ❌ 统一错误处理
- ❌ 请求拦截器功能

### DioClient 的优势

使用 DioClient 的接口拥有以下功能：
- ✅ 自动打印请求日志
- ✅ 自动添加 Token 和认证信息
- ✅ 自动刷新过期的 Token
- ✅ 统一错误处理
- ✅ 支持请求拦截器

## 示例代码

### 完整示例

```dart
import 'package:fastapp/data/network/config/http_client_config.dart';
import 'package:fastapp/data/network/constants/endpoints.dart';
import 'package:flutter/foundation.dart';

void configureHttpClient() {
  // 开发环境：全部使用 DioClient（默认）
  if (kDebugMode) {
    HttpClientConfig.clearRestClientEndpoints();
    return;
  }
  
  // 生产环境：配置高频接口使用 RestClient
  HttpClientConfig.addRestClientEndpoints([
    '/api/ds/ex/currency/tickers',      // 所有 Ticker 数据
    '/api/ds/ex/currency/marketPair',    // 交易对列表
    '/api/ds/ex/currency/ticker',       // 单个 Ticker 数据
  ]);
}
```

## 总结

- **开发时**：默认使用 DioClient，方便调试
- **生产时**：可配置部分接口使用 RestClient，优化性能
- **切换透明**：业务代码无需修改，只需配置即可

