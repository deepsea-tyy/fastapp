import 'dart:async';
import 'package:fastapp/domain/entity/market/ticker_data.dart';
import 'package:mobx/mobx.dart';

part 'ticker_cache_store.g.dart';

class TickerCacheStore = _TickerCacheStore with _$TickerCacheStore;

/// Ticker 价格缓存 Store
/// 用于减少总资产计算的实时跳动，定期更新缓存的 ticker 价格
abstract class _TickerCacheStore with Store {
  Timer? _refreshTimer;

  /// 缓存的 ticker 列表
  @observable
  List<TickerData> cachedTickerList = [];

  /// 缓存刷新间隔（毫秒），默认 5 秒
  final int refreshInterval;

  _TickerCacheStore({this.refreshInterval = 5000});

  /// 启动定期刷新
  @action
  void startRefresh(List<TickerData> Function() getTickerList) {
    // 立即更新一次
    cachedTickerList = List.from(getTickerList());

    // 定期更新缓存
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      Duration(milliseconds: refreshInterval),
      (_) {
        cachedTickerList = List.from(getTickerList());
      },
    );
  }

  /// 停止刷新
  void stopRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// 手动更新缓存
  @action
  void updateCache(List<TickerData> tickerList) {
    cachedTickerList = List.from(tickerList);
  }

  void dispose() {
    stopRefresh();
  }
}
