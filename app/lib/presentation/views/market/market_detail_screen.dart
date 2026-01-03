import 'package:fastapp/constants/exchange_rate.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/market/ticker_data.dart';
import 'package:fastapp/domain/entity/market/currency_detail.dart';
import 'package:fastapp/domain/entity/order/order_side.dart';
import 'package:fastapp/domain/usecase/market/get_currency_detail_usecase.dart';
import 'package:fastapp/presentation/store/home/home_store.dart';
import 'package:fastapp/presentation/store/market/depth_store.dart';
import 'package:fastapp/presentation/store/market/kline_store.dart';
import 'package:fastapp/presentation/store/market/market_store.dart';
import 'package:fastapp/presentation/store/spot/spot_trade_store.dart';
import 'package:fastapp/presentation/views/market/widgets/detail_app_bar.dart';
import 'package:fastapp/presentation/views/market/widgets/detail_bottom_actions.dart';
import 'package:fastapp/presentation/views/market/widgets/detail_info_tab.dart';
import 'package:fastapp/presentation/views/market/widgets/detail_order_book.dart';
import 'package:fastapp/presentation/views/market/widgets/detail_quote_tab.dart';
import 'package:fastapp/presentation/views/market/widgets/detail_tab_bar.dart';
import 'package:fastapp/presentation/views/market/widgets/detail_trade_data_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 交易详情页面
class MarketDetailScreen extends StatefulWidget {
  final TickerData ticker;
  final bool isFutures;

  const MarketDetailScreen({
    super.key,
    required this.ticker,
    this.isFutures = false,
  });

  @override
  State<MarketDetailScreen> createState() => _MarketDetailScreenState();
}

class _MarketDetailScreenState extends State<MarketDetailScreen> {
  final KlineStore _klineStore = getIt<KlineStore>();
  final DepthStore _depthStore = getIt<DepthStore>();
  final MarketStore _marketStore = getIt<MarketStore>();
  final GetCurrencyDetailUseCase _getCurrencyDetailUseCase = getIt<GetCurrencyDetailUseCase>();
  final SpotTradeStore _spotTradeStore = getIt<SpotTradeStore>();
  final HomeStore _homeStore = getIt<HomeStore>();
  
  int _selectedTab = 0;
  String _selectedInterval = '15分';
  bool _isFavorite = false;
  List<String> _selectedIndicators = ['MACD'];
  CurrencyDetail? _currencyDetail;
  bool _isLoadingCurrencyDetail = false;
  

  static const List<String> _tabs = ['报价', '信息', '交易数据'];
  static const List<String> _intervals = ['分时', '1分', '3分', '5分', '15分', '30分', '1小时', '2小时', '4小时', '6小时', '8小时', '12小时', '1日', '3日', '1周', '1月'];
  static const Map<String, String> _intervalMap = {
    '分时': '1s',
    '1分': '1m',
    '3分': '3m',
    '5分': '5m',
    '15分': '15m',
    '30分': '30m',
    '1小时': '1h',
    '2小时': '2h',
    '4小时': '4h',
    '6小时': '6h',
    '8小时': '8h',
    '12小时': '12h',
    '1日': '1d',
    '3日': '3d',
    '1周': '1w',
    '1月': '1M',
  };
  static const List<String> _mainIndicators = ['MA', 'BOLL'];
  static const List<String> _secondaryIndicators = ['MACD', 'RSI', 'KDJ', 'WR', 'CCI'];
  static const List<String> _indicators = [
    'MACD', 'KDJ', 'VOL', 'MA', 'BOLL', 'RSI', 'WR', 'CCI',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.ticker.symbol.isNotEmpty) {
      // 订阅当前交易对的 ticker 数据，这样可以获得实时价格更新
      final symbolNoSlash = widget.ticker.symbol.replaceAll('/', '');
      _marketStore.webSocket.subscribe('market', symbol: symbolNoSlash);

      // 先设置交易对和时间周期，这会自动触发订阅和数据加载
      // 即使 symbol 和 interval 相同，如果订阅状态丢失也会重新订阅
      _klineStore.setCurrentSymbol(widget.ticker.symbol);
      _klineStore.setCurrentInterval(_intervalMap[_selectedInterval] ?? '1m');
      // setCurrentSymbol 和 setCurrentInterval 内部都会调用 loadKlineData
      // 但为了确保首次进入时数据能正确加载，使用 WidgetsBinding 延迟执行
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_klineStore.klineData.isEmpty && !_klineStore.isLoading) {
          _klineStore.loadKlineData();
        }
      });

      // 订阅订单簿深度数据
      _depthStore.setCurrentSymbol(widget.ticker.symbol);
      _depthStore.loadDepthData(limit: 20);
    }
    // 初始化默认指标
    _updateKlineStoreIndicators();
    // 加载币种详情
    _loadCurrencyDetail();
  }

  /// 加载币种详情
  Future<void> _loadCurrencyDetail() async {
    if (widget.ticker.symbol.isEmpty) return;
    
    // 从交易对符号中提取基础币种（例如：BTC/USDT -> BTC）
    final symbol = widget.ticker.symbol.replaceAll('/', '');
    String baseCurrency = symbol;
    
    // 移除常见的计价货币后缀
    final quoteCurrencies = ['USDT', 'BTC', 'ETH', 'BNB', 'USDC', 'BUSD'];
    for (final quote in quoteCurrencies) {
      if (symbol.endsWith(quote)) {
        baseCurrency = symbol.substring(0, symbol.length - quote.length);
        break;
      }
    }
    
    if (baseCurrency.isEmpty) return;
    
    setState(() {
      _isLoadingCurrencyDetail = true;
    });
    
    try {
      final detail = await _getCurrencyDetailUseCase.call(
        params: GetCurrencyDetailParams(symbol: baseCurrency),
      );
      
      if (mounted) {
        setState(() {
          _currencyDetail = detail;
          _isLoadingCurrencyDetail = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCurrencyDetail = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ticker.symbol.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('数据加载中...')),
      );
    }

    return Observer(
      builder: (_) {
        // 从 MarketStore 获取最新的 ticker 数据（Observer 会自动监听 tickerList 的变化）
        final symbol = widget.ticker.symbol.replaceAll('/', '');
        final ticker = _marketStore.tickerList.firstWhere(
          (t) => t.symbol.replaceAll('/', '') == symbol,
          orElse: () => widget.ticker,
        );
        final isPositive = ticker.changePercent >= 0;
        final cnyPrice = ticker.lastPrice * ExchangeRate.getUsdToCnySync();

        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              DetailAppBar(
                symbolName: ticker.symbol.replaceAll('/', ''),
                isFavorite: _isFavorite,
                onBack: () => Navigator.of(context).pop(),
                onFavoriteToggle: () => setState(() => _isFavorite = !_isFavorite),
                onMore: () {},
                showPerpetual: widget.isFutures,
              ),
              DetailTabBar(
                tabs: _tabs,
                selectedTab: _selectedTab,
                onTabChanged: (index) => setState(() => _selectedTab = index),
              ),
              Expanded(
                child: _buildTabContent(ticker, isPositive, cnyPrice),
              ),
              DetailBottomActions(
                onMore: () {},
                onAlert: () {},
                onLeverage: () {},
                onGrid: () {},
                onBuy: () => _handleBuy(),
                onSell: () => _handleSell(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleIntervalChanged(String interval) {
    setState(() => _selectedInterval = interval);
    final intervalValue = _intervalMap[interval] ?? '1m';
    _klineStore.setCurrentInterval(intervalValue);
    _klineStore.loadKlineData();
  }

  void _handleIndicatorToggled(String indicator) {
    setState(() {
      if (_selectedIndicators.contains(indicator)) {
        _selectedIndicators.remove(indicator);
      } else {
        _selectedIndicators.add(indicator);
      }
    });
    _updateKlineStoreIndicators();
  }

  Widget _buildTabContent(TickerData ticker, bool isPositive, double cnyPrice) {
    switch (_selectedTab) {
      case 0:
        return DetailQuoteTab(
          ticker: ticker,
          isPositive: isPositive,
          cnyPrice: cnyPrice,
          intervals: _intervals,
          intervalMap: _intervalMap,
          selectedInterval: _selectedInterval,
          selectedIndicators: _selectedIndicators,
          indicators: _indicators,
          klineStore: _klineStore,
          isRealtime: _selectedInterval == '分时',
          onIntervalChanged: _handleIntervalChanged,
          onIndicatorToggled: _handleIndicatorToggled,
          onDepthTap: () {},
          onSettingsTap: () {},
        );
      case 1:
        return DetailInfoTab(
          ticker: ticker,
          currencyDetail: _currencyDetail,
        );
      case 2:
        return const DetailTradeDataTab();
      default:
        return const SizedBox.shrink();
    }
  }

  void _updateKlineStoreIndicators() {
    final selectedMainIndicators = _selectedIndicators
        .where((i) => _mainIndicators.contains(i))
        .toList();
    final secondaryIndicators = _selectedIndicators
        .where((i) => _secondaryIndicators.contains(i))
        .toList();
    
    _klineStore.setMainIndicator(selectedMainIndicators.isNotEmpty ? selectedMainIndicators.last : '');
    _klineStore.setSelectedSecondaryIndicators(secondaryIndicators);
    _klineStore.setSecondaryIndicator(secondaryIndicators.isNotEmpty ? secondaryIndicators.last : '');
  }

  /// 处理买入按钮点击
  void _handleBuy() {
    final symbol = widget.ticker.symbol;
    if (symbol.isNotEmpty) {
      _spotTradeStore.setSelectedSymbol(symbol);
      _spotTradeStore.setTradeSide(OrderSide.buy);
      // 切换到底部导航栏的现货交易页面（索引为2）
      _homeStore.setBottomNavIndex(2);
      // 返回到主页面
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  /// 处理卖出按钮点击
  void _handleSell() {
    final symbol = widget.ticker.symbol;
    if (symbol.isNotEmpty) {
      _spotTradeStore.setSelectedSymbol(symbol);
      _spotTradeStore.setTradeSide(OrderSide.sell);
      // 切换到底部导航栏的现货交易页面（索引为2）
      _homeStore.setBottomNavIndex(2);
      // 返回到主页面
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    // 取消ticker数据订阅
    if (widget.ticker.symbol.isNotEmpty) {
      final symbolNoSlash = widget.ticker.symbol.replaceAll('/', '');
      _marketStore.webSocket.unsubscribe('market', symbol: symbolNoSlash);
    }

    // 注意：DepthStore 和 KlineStore 是全局单例，不应该在这里 dispose
    // 它们由依赖注入管理，订阅状态会在页面重新打开时自动恢复
    super.dispose();
  }
}
