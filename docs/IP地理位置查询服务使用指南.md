# IP地理位置查询服务使用指南

## 概述

`IpLocationService` 提供IP地址地理位置查询功能，支持多语言，集成多个免费API服务，自动降级切换。

**服务类**：`App\Common\Service\IpLocationService`（已自动注册到容器）

## 支持的API服务

| API服务 | 免费额度 | 多语言 | 特点 |
|---------|---------|--------|------|
| **ipapi.co**（推荐） | 1000次/天 | ✅ | 数据准确，响应快，支持IPv4/IPv6 |
| ip-api.com | 45次/分钟 | ❌ | 数据详细（含ISP、时区） |
| ip-api.io | 100次/天 | ❌ | 备用服务 |

**自动降级**：API失败时自动切换到下一个服务

## 快速开始

### 基本使用

```php
use App\Common\Service\IpLocationService;
use Hyperf\Context\ApplicationContext;

$service = ApplicationContext::getContainer()->get(IpLocationService::class);

// 查询IP地理位置
$location = $service->query('8.8.8.8', 'zh-CN');
// 返回：['ip' => '8.8.8.8', 'country' => '美国', 'country_code' => 'US', 
//       'region' => '加利福尼亚', 'city' => '山景城', 'isp' => 'Google LLC',
//       'latitude' => 37.4056, 'longitude' => -122.0775]
```

### 在控制器中使用

```php
use App\Common\Service\IpLocationService;

class YourController
{
    public function __construct(
        private readonly IpLocationService $ipLocationService
    ) {}

    #[Get('/ip-location')]
    public function getIpLocation(string $ip): array
    {
        return $this->ipLocationService->query($ip, 'zh-CN') ?? ['error' => '查询失败'];
    }
}
```

### 在事件监听器中使用（异步推荐）

```php
use App\Common\Service\IpLocationService;
use App\Common\Event\UserLoginEvent;
use App\Common\Tools;
use Swoole\Coroutine;

#[Listener]
class IpLocationListener implements ListenerInterface
{
    public function __construct(
        private readonly IpLocationService $ipLocationService
    ) {}

    public function process(object $event): void
    {
        if ($event instanceof UserLoginEvent) {
            // 异步查询，不阻塞主流程
            Coroutine::create(function () use ($event) {
                $ip = $event->getIp();
                $lang = Tools::lang($event->getUser()->id ?? 0, true);
                $location = $this->ipLocationService->query($ip, $lang);
                
                // 格式化地理位置字符串
                $locationString = $this->formatLocation($location);
                // 保存到日志...
            });
        }
    }
    
    private function formatLocation(?array $location): string
    {
        if (!$location) return '未知';
        
        $parts = array_filter([
            $location['country'] ?? '',
            ($location['region'] ?? '') !== ($location['country'] ?? '') ? $location['region'] : '',
            ($location['city'] ?? '') !== ($location['region'] ?? '') ? $location['city'] : '',
        ]);
        
        return !empty($parts) ? implode(' ', $parts) : '未知';
    }
}
```

**注意**：实际项目中已在 `UserSubscriber` 中实现，示例代码仅供参考。

## 数据格式

### 统一返回格式

所有API返回统一的数据结构：

```php
[
    'ip' => '8.8.8.8',              // IP地址（必填）
    'country' => '美国',             // 国家名称（字符串，可能为空）
    'country_code' => 'US',         // 国家代码（字符串，可能为空）
    'region' => '加利福尼亚',        // 省/州（字符串，可能为空）
    'city' => '山景城',             // 城市（字符串，可能为空）
    'isp' => 'Google LLC',          // ISP服务商（字符串，可能为空）
    'latitude' => 37.4056,           // 纬度（float或null）
    'longitude' => -122.0775,       // 经度（float或null）
]
```

### 内网IP处理

内网IP自动识别，直接返回统一格式（所有字段为空），不调用API：

```php
$location = $service->query('127.0.0.1');
// 返回：['ip' => '127.0.0.1', 'country' => '', 'country_code' => '', ...]
```

## 功能特性

### 1. 自动缓存

查询结果自动缓存24小时，减少API调用：

```php
$location1 = $service->query('8.8.8.8');  // 调用API
$location2 = $service->query('8.8.8.8');  // 从缓存读取
```

### 2. 多语言支持

```php
$service->query('8.8.8.8', 'zh-CN');  // 中文：['country' => '美国']
$service->query('8.8.8.8', 'en');     // 英文：['country' => 'United States']
$service->query('8.8.8.8', 'zh-TW');  // 繁体：['country' => '美國']
```

### 3. 数据标准化

- 字符串字段：自动清理空格，空值统一为空字符串
- 坐标字段：自动转换为 `float` 类型或 `null`，验证范围（-180 到 180）
- IP地址验证：确保格式正确

## 错误处理

### 查询失败

查询失败时返回 `null`：

```php
$location = $service->query('invalid-ip');
if ($location === null) {
    // 处理查询失败
    $locationString = '未知';
} else {
    // 安全访问字段（字段可能为空字符串）
    $parts = array_filter([
        $location['country'],
        $location['region'],
        $location['city']
    ]);
    $locationString = !empty($parts) ? implode(' ', $parts) : '未知';
}
```

### 错误处理机制

- IP地址验证：无效IP直接返回 `null`
- HTTP状态码检查：非200状态码自动跳过
- JSON解析验证：无效JSON自动跳过
- API错误响应检测：自动检测并跳过错误响应
- 异常捕获：区分网络异常和API异常

所有错误通过 `Tools::logAsync()` 异步记录到日志系统（`ip-location` channel）。

## 最佳实践

### 1. 异步查询（推荐）

```php
use Swoole\Coroutine;

Coroutine::create(function () use ($ip, $lang) {
    $location = $this->ipLocationService->query($ip, $lang);
    // 处理结果...
});
```

### 2. 批量查询

使用队列异步处理：

```php
use App\Common\Tools;
Tools::redisDispatcher(new IpLocationJob($ipList));
```

## 配置说明

### 缓存配置

使用 Hyperf 缓存系统（`config/autoload/cache.php`），默认使用 Redis。

### 超时配置

API请求超时时间：5秒（可在服务类中修改）

## 常见问题

**Q: 查询速度慢？**  
A: 检查网络连接，查看日志确认API状态，考虑使用本地数据库（GeoIP2）

**Q: 免费额度不够？**  
A: 已启用24小时缓存机制，可考虑升级付费API或使用本地数据库

**Q: 需要更准确的数据？**  
A: 考虑使用付费服务（MaxMind GeoIP2、IP2Location）或本地数据库

## 总结

`IpLocationService` 提供：
- ✅ 多个免费API服务自动切换
- ✅ 多语言支持
- ✅ 24小时自动缓存
- ✅ 内网IP自动识别
- ✅ 统一的数据格式
- ✅ 数据标准化和验证
- ✅ 完善的错误处理

更多文档请查看 [文档导航](./README.md)
