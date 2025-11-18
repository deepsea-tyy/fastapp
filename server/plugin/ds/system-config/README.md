<div align="center">
  <h1>系统设置插件</h1>
</div>

<div align="center">

系统配置插件。

</div>

# 特性

好用、好看、轻量化

## 全面

系统设置插件，提供设置持久化保存的功能，方便前端和其他业务调用静态数据

# 安装卸载
```sh
php bin/hyperf.php plugin:install ds/system-config  --yes
```
```sh
php bin/hyperf.php plugin:uninstall ds/system-config --yes
```

# 使用方法
## 后端
后端提供了一个助手类，可以快捷调用系统配置数据

```php
// 获取分组信息，如果不传入参数，则获取所有分组信息
\Plugin\Ds\SystemConfig\Helper\Helper::getSystemConfigGroup('testType');
// 获取某个配置所有信息
\Plugin\Ds\SystemConfig\Helper\Helper::getSystemConfig('testType');
```