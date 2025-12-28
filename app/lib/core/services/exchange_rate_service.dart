import 'dart:async';
import 'package:fastapp/data/network/apis/market/market_api.dart';
import 'package:fastapp/domain/entity/market/exchange_rate_response.dart';

/// 汇率服务
/// 负责从 API 获取汇率并缓存，提供统一的汇率访问接口
class ExchangeRateService {
  final MarketApi _marketApi;

  ExchangeRateResponse? _cachedRate;
  DateTime? _lastUpdateTime;
  bool _isFetching = false;
  Completer<ExchangeRateResponse?>? _fetchCompleter;

  static const Duration _cacheValidityDuration = Duration(minutes: 30);
  static const double _defaultUsdToCny = 7.0;
  static const double _defaultUsdToKrw = 1441.55;
  static const double _defaultUsdToEur = 0.848939;
  static const double _defaultUsdToJpy = 156.5;

  ExchangeRateService(this._marketApi);

  /// 获取 USD 到 CNY 的汇率
  Future<double> getUsdToCny() async {
    final rate = await getExchangeRate();
    return rate?.cny ?? _defaultUsdToCny;
  }

  /// 获取 USD 到 KRW 的汇率
  Future<double> getUsdToKrw() async {
    final rate = await getExchangeRate();
    return rate?.krw ?? _defaultUsdToKrw;
  }

  /// 获取 USD 到 EUR 的汇率
  Future<double> getUsdToEur() async {
    final rate = await getExchangeRate();
    return rate?.eur ?? _defaultUsdToEur;
  }

  /// 获取 USD 到 JPY 的汇率
  Future<double> getUsdToJpy() async {
    final rate = await getExchangeRate();
    return rate?.jpy ?? _defaultUsdToJpy;
  }

  /// 获取汇率响应
  ///
  /// 优先使用缓存，如果缓存过期或不存在则从 API 获取
  /// 如果 API 获取失败，返回 null
  Future<ExchangeRateResponse?> getExchangeRate() async {
    // 检查缓存是否有效
    if (_isCacheValid()) {
      return _cachedRate;
    }

    // 如果正在获取，等待当前获取完成
    if (_isFetching && _fetchCompleter != null) {
      return _fetchCompleter!.future;
    }

    return _fetchFromApi();
  }

  /// 检查缓存是否有效
  bool _isCacheValid() {
    if (_cachedRate == null || _lastUpdateTime == null) {
      return false;
    }
    return DateTime.now().difference(_lastUpdateTime!) < _cacheValidityDuration;
  }

  /// 从 API 获取汇率
  Future<ExchangeRateResponse?> _fetchFromApi() async {
    _isFetching = true;
    _fetchCompleter = Completer<ExchangeRateResponse?>();

    try {
      final rate = await _marketApi.getExchangeRate();
      if (rate != null) {
        _cachedRate = rate;
        _lastUpdateTime = DateTime.now();
      }
      _fetchCompleter!.complete(rate);
      return rate;
    } catch (_) {
      _fetchCompleter!.complete(null);
      return null;
    } finally {
      _isFetching = false;
      _fetchCompleter = null;
    }
  }

  /// 强制刷新汇率
  Future<ExchangeRateResponse?> refreshExchangeRate() async {
    clearCache();
    return getExchangeRate();
  }

  /// 清除缓存
  void clearCache() {
    _cachedRate = null;
    _lastUpdateTime = null;
  }

  /// 获取缓存的汇率（不触发 API 请求）
  ExchangeRateResponse? getCachedRate() {
    return _isCacheValid() ? _cachedRate : null;
  }
}

