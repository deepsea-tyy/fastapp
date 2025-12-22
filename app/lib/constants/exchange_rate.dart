import 'package:fastapp/core/services/exchange_rate_service.dart';
import 'package:fastapp/di/service_locator.dart';

/// 汇率工具类
/// 
/// 提供统一的汇率访问接口，优先从 API 获取实时汇率
/// 如果 API 获取失败，使用默认值 7.08
class ExchangeRate {
  ExchangeRate._();

  /// 默认汇率（当 API 获取失败时使用）
  static const double _defaultUsdToCny = 7.08;

  /// 获取服务实例（带错误处理）
  static ExchangeRateService? _getService() {
    try {
      return getIt<ExchangeRateService>();
    } catch (_) {
      return null;
    }
  }

  /// 获取 USD 到 CNY 的汇率
  /// 
  /// 优先从 ExchangeRateService 获取实时汇率
  /// 如果服务未初始化或获取失败，返回默认值
  static Future<double> getUsdToCny() async {
    final service = _getService();
    if (service == null) return _defaultUsdToCny;
    
    try {
      return await service.getUsdToCny();
    } catch (_) {
      return _defaultUsdToCny;
    }
  }

  /// 同步获取 USD 到 CNY 的汇率（使用缓存）
  /// 
  /// 如果缓存不存在或已过期，返回默认值
  /// 注意：此方法不会触发 API 请求
  static double getUsdToCnySync() {
    final service = _getService();
    if (service == null) return _defaultUsdToCny;
    
    final cachedRate = service.getCachedRate();
    return cachedRate?.cny ?? _defaultUsdToCny;
  }

  /// 强制刷新汇率
  /// 
  /// 忽略缓存，直接从 API 获取最新汇率
  static Future<double> refreshUsdToCny() async {
    final service = _getService();
    if (service == null) return _defaultUsdToCny;
    
    try {
      final rate = await service.refreshExchangeRate();
      return rate?.cny ?? _defaultUsdToCny;
    } catch (_) {
      return _defaultUsdToCny;
    }
  }
}

