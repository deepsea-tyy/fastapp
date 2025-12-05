import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/market/ticker_data.dart';
import 'package:fastapp/presentation/store/market/kline_store.dart';
import 'package:fastapp/presentation/views/market/widgets/detail_app_bar.dart';
import 'package:fastapp/presentation/views/market/widgets/detail_bottom_actions.dart';
import 'package:fastapp/presentation/views/market/widgets/detail_info_tab.dart';
import 'package:fastapp/presentation/views/market/widgets/detail_order_book.dart';
import 'package:fastapp/presentation/views/market/widgets/detail_quote_tab.dart';
import 'package:fastapp/presentation/views/market/widgets/detail_tab_bar.dart';
import 'package:fastapp/presentation/views/market/widgets/detail_trade_data_tab.dart';
import 'package:flutter/material.dart';

/// 交易详情页面
class MarketDetailScreen extends StatefulWidget {
  final TickerData ticker;

  const MarketDetailScreen({
    super.key,
    required this.ticker,
  });

  @override
  State<MarketDetailScreen> createState() => _MarketDetailScreenState();
}

class _MarketDetailScreenState extends State<MarketDetailScreen> {
  final KlineStore _klineStore = getIt<KlineStore>();
  
  int _selectedTab = 0;
  String _selectedInterval = '1分';
  bool _isFavorite = false;
  List<String> _selectedIndicators = ['MACD'];

  static const List<String> _tabs = ['报价', '信息', '交易数据'];
  static const List<String> _intervals = ['分时', '1分', '3分', '5分', '15分', '1小时', '3日'];
  static const Map<String, String> _intervalMap = {
    '分时': '1s',
    '1分': '1m',
    '3分': '3m',
    '5分': '5m',
    '15分': '15m',
    '1小时': '1h',
    '3日': '3d',
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
      _klineStore.setCurrentSymbol(widget.ticker.symbol);
      _klineStore.setCurrentInterval(_intervalMap[_selectedInterval] ?? '1m');
      _klineStore.loadKlineData();
    }
    // 初始化默认指标
    _updateKlineStoreIndicators();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ticker.symbol.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('数据加载中...')),
      );
    }
    
    final ticker = widget.ticker;
    final isPositive = ticker.changePercent >= 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          DetailAppBar(
            symbolName: ticker.symbol.replaceAll('/', ''),
            isFavorite: _isFavorite,
            onBack: () => Navigator.of(context).pop(),
            onFavoriteToggle: () => setState(() => _isFavorite = !_isFavorite),
            onShare: () {},
            onMore: () {},
          ),
          DetailTabBar(
            tabs: _tabs,
            selectedTab: _selectedTab,
            onTabChanged: (index) => setState(() => _selectedTab = index),
          ),
          Expanded(
            child: _buildTabContent(ticker, isPositive, ticker.lastPrice * 7.08),
          ),
          DetailBottomActions(
            onMore: () {},
            onAlert: () {},
            onLeverage: () {},
            onGrid: () {},
            onBuy: () {},
            onSell: () {},
          ),
        ],
      ),
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
        return DetailInfoTab(ticker: ticker);
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
}
