import 'dart:async';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/market/kline_data.dart';
import 'package:fastapp/presentation/store/market/kline_store.dart';
import 'package:fastapp/presentation/store/market/depth_store.dart';
import 'package:fastapp/presentation/store/app/language_store.dart';
import 'package:fastapp/data/network/websocket/app_websocket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:k_chart_plus/k_chart_plus.dart';

/// k_chart_plus 使用说明
/// 
/// ## K线图使用步骤：
/// 
/// 1. **数据准备**：
///    - 数据必须按时间升序排列（从旧到新）
///    - 数据量要求：MACD至少26个，KDJ至少9个，建议至少50-100个数据点
///    - 数据格式：使用 KLineEntity.fromCustom() 创建，包含 open/high/low/close/vol/amount/time
/// 
/// 2. **关键步骤 - 计算指标**：
///    - **必须**在数据转换后调用 `DataUtil.calculate(kChartData)` 来计算指标
///    - 不调用此方法，MACD、KDJ等副图指标不会显示
/// 
/// 3. **配置图表样式**：
///    - ChartStyle: 设置内边距、子图间距等
///    - ChartColors: 设置背景色、指标颜色等
/// 
/// 4. **设置主图指标**：
///    - mainStateLi: Set<MainState>，支持 MA、BOLL
///    - 例如：mainStateLi: {MainState.MA}
/// 
/// 5. **设置副图指标**：
///    - secondaryStateLi: Set<SecondaryState>
///    - 支持的指标：MACD、RSI、KDJ、WR、CCI
///    - 例如：secondaryStateLi: {SecondaryState.MACD, SecondaryState.KDJ}
/// 
/// 6. **KChartWidget 参数说明**：
///    - datas: List<KLineEntity> - K线数据（必须已调用DataUtil.calculate）
///    - chartStyle: ChartStyle - 图表样式
///    - chartColors: ChartColors - 图表颜色
///    - isTrendLine: bool - 是否显示趋势线
///    - isLine: bool - 是否显示折线图（false为K线图）
///    - mBaseHeight: double - 主图高度
///    - mainStateLi: Set<MainState> - 主图指标集合
///    - secondaryStateLi: Set<SecondaryState> - 副图指标集合
///    - volHidden: bool - 是否隐藏成交量
///    - onLoadMore: 加载更多数据的回调
/// 
/// ## 深度图使用步骤：
/// 
/// 1. **数据准备**：
///    - 将 DepthData 转换为 DepthEntity
///    - DepthEntity(price, vol) - 使用位置参数，price为价格，vol为累计数量
/// 
/// 2. **DepthChart 参数**：
///    - bids: List<DepthEntity> - 买单数据
///    - asks: List<DepthEntity> - 卖单数据
///    - chartColors: ChartColors - 图表颜色
/// 
/// ## 注意事项：
/// 
/// - 数据必须按时间排序，否则指标计算会出错
/// - 必须调用 DataUtil.calculate() 才能显示副图指标
/// - 副图指标需要足够的数据量才能正确计算
/// - 主图高度计算需要考虑副图和成交量的高度
/// 
/// ## 常见问题：
/// 
/// Q: MACD/KDJ柱状图不显示？
/// A: 检查是否调用了 DataUtil.calculate(kChartData)，数据量是否足够
/// 
/// Q: 指标计算不准确？
/// A: 确保数据按时间升序排列，数据量足够
/// 
/// Q: 副图遮挡主图？
/// A: 调整 mBaseHeight 和副图高度比例

/// 图表显示模式
enum ChartMode {
  kline,  // K线图
  depth,  // 深度图
}

/// K线图组件（支持深度图）
class DetailKlineChart extends StatefulWidget {
  final String symbol;
  final String interval;
  final bool showVolume;
  final ChartMode mode;
  final List<String>? selectedIndicators; // 完整的指标列表（包括VOL），用于按顺序显示
  final bool isRealtime; // 是否为分时实时图

  const DetailKlineChart({
    super.key,
    required this.symbol,
    required this.interval,
    this.showVolume = true,
    this.mode = ChartMode.kline,
    this.selectedIndicators,
    this.isRealtime = false, // 分时模式
  });

  @override
  State<DetailKlineChart> createState() => _DetailKlineChartState();
}

class _DetailKlineChartState extends State<DetailKlineChart> {
  final KlineStore _klineStore = getIt<KlineStore>();
  final DepthStore _depthStore = getIt<DepthStore>();
  final AppWebSocket _marketWebSocket = getIt<AppWebSocket>();
  final LanguageStore _languageStore = getIt<LanguageStore>();
  
  StreamSubscription? _websocketSubscription;
  
  ChartTranslations _getChartTranslations() {
    final locale = _languageStore.locale;
    if (locale.startsWith('zh')) {
      return const ChartTranslations(
        date: '时间',
        open: '开',
        high: '高',
        low: '低',
        close: '收',
        changeAmount: '涨跌',
        change: '涨跌%',
        amount: '额',
        vol: '量',
        amplitude: '振幅',
      );
    } else {
      return const ChartTranslations(
        date: 'Date',
        open: 'Open',
        high: 'High',
        low: 'Low',
        close: 'Close',
        changeAmount: 'Change',
        change: 'Change%',
        amount: 'Amount',
        vol: 'Volume',
        amplitude: 'Amplitude',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _klineStore.setCurrentSymbol(widget.symbol);
    _klineStore.setCurrentInterval(widget.interval);
    _depthStore.setCurrentSymbol(widget.symbol);
    
    if (widget.mode == ChartMode.kline) {
      _klineStore.loadKlineData();
      // 如果是分时实时图，启动实时更新
      if (widget.isRealtime) {
        _setupRealtimeUpdates();
      }
    } else {
      _depthStore.loadDepthData();
    }
  }

  /// 设置实时数据更新
  void _setupRealtimeUpdates() {
    // 先取消旧的订阅，避免重复订阅
    _websocketSubscription?.cancel();
    _marketWebSocket.unsubscribe('kline', symbol: '${widget.symbol}:${widget.interval}');
    
    // 确保WebSocket已连接
    if (!_marketWebSocket.isConnected) {
      _marketWebSocket.connect();
    }
    
    // 订阅K线频道，使用当前配置的interval
    _marketWebSocket.subscribe('kline', symbol: '${widget.symbol}:${widget.interval}');
    
    // 监听WebSocket消息
    _websocketSubscription = _marketWebSocket.messageStream.listen((message) {
      // 检查消息类型和交易对是否匹配
      if (message.type == WebSocketMessageType.kline &&
          message.symbol == widget.symbol) {
        // 解析K线数据
        try {
          final klineData = KlineData.fromJson(message.data as Map<String, dynamic>);
          // 更新K线数据
          _klineStore.updateLatestKline(klineData);
        } catch (e) {
          // 忽略解析错误
        }
      }
    });
  }

  @override
  void didUpdateWidget(DetailKlineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    final symbolChanged = oldWidget.symbol != widget.symbol;
    final intervalChanged = oldWidget.interval != widget.interval;
    final modeChanged = oldWidget.mode != widget.mode;
    final realtimeChanged = oldWidget.isRealtime != widget.isRealtime;

    if (symbolChanged) {
      _klineStore.setCurrentSymbol(widget.symbol);
      _depthStore.setCurrentSymbol(widget.symbol);
    }

    if (intervalChanged) {
      _klineStore.setCurrentInterval(widget.interval);
    }

    // 处理实时更新订阅
    if (symbolChanged || realtimeChanged) {
      // 取消旧的订阅
      if (oldWidget.isRealtime && oldWidget.mode == ChartMode.kline) {
        _websocketSubscription?.cancel();
        _marketWebSocket.unsubscribe('kline', symbol: '${oldWidget.symbol}:${oldWidget.interval}');
      }
      
      // 启动新的订阅
      if (widget.isRealtime && widget.mode == ChartMode.kline) {
        _setupRealtimeUpdates();
      }
    }

    if (symbolChanged || modeChanged) {
      if (widget.mode == ChartMode.kline) {
        _klineStore.loadKlineData();
        if (widget.isRealtime) {
          _setupRealtimeUpdates();
        }
      } else {
        _depthStore.loadDepthData();
      }
    } else if (intervalChanged && widget.mode == ChartMode.kline) {
      _klineStore.loadKlineData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == ChartMode.depth) {
      return _buildDepthChart(context);
    } else {
      return _buildKlineChart(context);
    }
  }

  Widget _buildDepthChart(BuildContext context) {
    return Observer(
      builder: (_) {
        if (_depthStore.isLoading && _depthStore.depthData == null) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }

        if (_depthStore.errorMessage != null && _depthStore.depthData == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  _depthStore.errorMessage ?? '加载失败',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _depthStore.refreshDepthData(),
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        final depthData = _depthStore.depthData;
        if (depthData == null || (depthData.bids.isEmpty && depthData.asks.isEmpty)) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.show_chart,
                  color: Colors.grey.shade400,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  '暂无深度数据',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _depthStore.refreshDepthData(),
                  child: const Text('刷新'),
                ),
              ],
            ),
          );
        }

        // 转换深度数据为 k_chart_plus 需要的格式
        // DepthEntity 构造函数使用位置参数：DepthEntity(price, vol)
        // price: 价格
        // vol: 累计数量（cumulativeQuantity）
        final List<DepthEntity> bids = depthData.bids.map((d) => DepthEntity(
          d.price,
          d.cumulativeQuantity,
        )).toList();

        final List<DepthEntity> asks = depthData.asks.map((d) => DepthEntity(
          d.price,
          d.cumulativeQuantity,
        )).toList();

        // ========== 深度图颜色配置 ==========
        final chartColors = ChartColors()
          ..bgColor = Colors.white  // 背景色
          ..upColor = Colors.red    // 买单颜色（通常为红色/绿色）
          ..dnColor = Colors.green; // 卖单颜色

        return SizedBox(
          height: 400,
          width: double.infinity,
          // ========== DepthChart 使用说明 ==========
          // DepthChart 参数：
          // - bids: List<DepthEntity> - 买单数据（价格从高到低）
          // - asks: List<DepthEntity> - 卖单数据（价格从低到高）
          // - chartColors: ChartColors - 图表颜色配置
          child: DepthChart(
            bids,
            asks,
            chartColors,
          ),
        );
      },
    );
  }

  Widget _buildKlineChart(BuildContext context) {
    return Observer(
      builder: (_) {
        // 监听语言变化，确保翻译更新
        final _ = _languageStore.locale;
        if (_klineStore.isLoading && _klineStore.klineData.isEmpty) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }

        if (_klineStore.errorMessage != null && _klineStore.klineData.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  _klineStore.errorMessage ?? '加载失败',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _klineStore.refreshKlineData(),
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        // 获取K线数据
        List<KlineData> dataToUse = _klineStore.klineData;

        // 如果数据为空，返回空状态
        if (dataToUse.isEmpty) {
          return const Center(
            child: Text(
              '暂无K线数据',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        // ========== 步骤1: 数据排序 ==========
        // k_chart_plus要求数据必须按时间升序排列（从旧到新）
        // 这对指标计算非常重要，不排序会导致指标计算错误
        final sortedData = List<KlineData>.from(dataToUse)
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
        
        // ========== 步骤2: 数据格式转换 ==========
        // 将 KlineData 转换为 k_chart_plus 需要的 KLineEntity 格式
        // k_chart_plus会自动根据数据的high和low值动态调整Y轴范围，不会从0开始
        final kChartData = sortedData.map((kline) {
          // 确保数据有效且格式正确
          if (!kline.high.isFinite || !kline.low.isFinite || 
              !kline.open.isFinite || !kline.close.isFinite ||
              kline.high <= 0 || kline.low <= 0) {
            // 如果数据无效，使用默认值（这种情况不应该发生）
            return KLineEntity.fromCustom(
              open: 100.0,
              high: 105.0,
              low: 95.0,
              close: 102.0,
              vol: kline.volume,
              amount: kline.amount,
              time: kline.timestamp,
            );
          }
          
          return KLineEntity.fromCustom(
            open: kline.open,
            high: kline.high,
            low: kline.low,
            close: kline.close,
            vol: kline.volume,
            amount: kline.amount,
            time: kline.timestamp,
          );
        }).toList();

        // ========== 步骤3: 计算指标数据（关键步骤）==========
        // **必须**调用 DataUtil.calculate() 来计算指标数据
        // 不调用此方法，MACD、KDJ等副图指标不会显示柱状图
        // 此方法会计算所有指标的数值（MA、MACD、RSI、KDJ等）
        DataUtil.calculate(kChartData);

        // ========== 步骤4: 配置图表样式 ==========
        // topPadding 和 bottomPadding 使用默认值 20.0（确保横坐标文字完整显示）
        // childPadding 设置为 8.0（比默认值 12.0 更紧凑）
        final chartStyle = ChartStyle()
          ..childPadding = 8.0;     // 子图间距（默认值为 12.0，这里使用更紧凑的间距）
          
        // ========== 步骤5: 配置图表颜色 ==========
        final chartColors = ChartColors()
          ..bgColor = Colors.white      // 背景色
          ..ma5Color = Colors.amber     // MA5颜色
          ..ma10Color = Colors.pink     // MA10颜色
          ..ma30Color = Colors.purple   // MA30颜色
          ..upColor = Colors.red        // 上涨颜色（K线）
          ..dnColor = Colors.green;     // 下跌颜色（K线）

        // ========== 步骤6: 转换指标状态 ==========
        // 将字符串指标名称转换为 k_chart_plus 的 SecondaryState 枚举
        // secondaryStateLi 需要 List<SecondaryState> 类型（保持点击顺序）
        // 如果提供了 selectedIndicators，使用它来保持完整顺序（包括VOL的位置）
        // 否则使用 _klineStore.selectedSecondaryIndicators
        final List<String> orderedIndicators;
        
        if (widget.selectedIndicators != null) {
          // 使用完整的指标列表，保持点击顺序
          // 只提取副图指标（不包括VOL，因为VOL是单独处理的）
          orderedIndicators = widget.selectedIndicators!
              .where((indicator) => ['MACD', 'RSI', 'KDJ', 'WR', 'CCI'].contains(indicator))
              .toList();
        } else {
          // 使用 store 中的副图指标列表
          orderedIndicators = _klineStore.selectedSecondaryIndicators.toList();
        }
        
        final secondaryStates = orderedIndicators
            .map((indicator) => _getSecondaryState(indicator))
            .whereType<SecondaryState>()
            .toList(); // 使用 toList() 保持顺序
        
        // 计算VOL在selectedIndicators中的位置（相对于副图列表）
        // 用于在布局时按顺序插入VOL
        int? volInsertPosition;
        if (widget.selectedIndicators != null && widget.selectedIndicators!.contains('VOL')) {
          final volIndexInAll = widget.selectedIndicators!.indexOf('VOL');
          // 计算在VOL之前有多少个副图指标
          int beforeVolCount = 0;
          for (int i = 0; i < volIndexInAll; i++) {
            if (['MACD', 'RSI', 'KDJ', 'WR', 'CCI'].contains(widget.selectedIndicators![i])) {
              beforeVolCount++;
            }
          }
          volInsertPosition = beforeVolCount;
        }
        
        // VOL 是否显示：如果提供了 selectedIndicators，检查其中是否包含 VOL
        // 否则使用 widget.showVolume
        final hasVolume = widget.selectedIndicators != null
            ? widget.selectedIndicators!.contains('VOL')
            : widget.showVolume;
        
        // mBaseHeight 是主图的基础高度（不包含副图）
        // k_chart_plus 会根据 mBaseHeight 自动计算副图高度和总高度
        // 使用固定的主图高度，让 k_chart_plus 自己处理副图高度计算
        const mBaseHeight = 400.0;
        
        // ========== 步骤7: 配置多语言翻译 ==========
        final chartTranslations = _getChartTranslations();
        
        // ========== 步骤8: 创建KChartWidget ==========
        // KChartWidget 参数说明：
        // - datas: 已计算的K线数据（必须已调用DataUtil.calculate）
        // - chartStyle: 图表样式配置
        // - chartColors: 图表颜色配置
        // - isTrendLine: 是否显示趋势线（false）
        // - isLine: 是否显示折线图（false为K线图）
        // - mBaseHeight: 主图高度（k_chart_plus会自动在下方添加副图）
        // - verticalTextAlignment: Y轴文字对齐方式
        // - mainStateLi: 主图指标集合（Set<MainState>）
        // - secondaryStateLi: 副图指标集合（Set<SecondaryState>），支持MACD、KDJ等
        // - volHidden: 是否隐藏成交量
        // - chartTranslations: 多语言翻译配置
        // - onLoadMore: 加载更多数据的回调
        final kChartWidget = KChartWidget(
          kChartData,  // 已计算的K线数据
          chartStyle,
          chartColors,
          isTrendLine: false,  // 不显示趋势线
          isLine: widget.isRealtime,  // 分时模式显示折线图，否则显示K线图
          mBaseHeight: mBaseHeight,
          verticalTextAlignment: VerticalTextAlignment.right,
          mainStateLi: _klineStore.mainIndicator.isNotEmpty 
              ? {_getMainState(_klineStore.mainIndicator)} 
              : <MainState>{},  // 主图指标
          secondaryStateLi: secondaryStates,  // 副图指标（MACD、KDJ等）
          volHidden: !hasVolume,  // 是否隐藏成交量
          volInsertPosition: volInsertPosition,  // VOL在副图列表中的插入位置
          chartTranslations: chartTranslations,  // 多语言翻译
          onLoadMore: (bool isReload) async {
            // 加载更多历史数据
            if (!isReload && _klineStore.klineData.isNotEmpty) {
              final oldestTime = _klineStore.klineData.first.timestamp;
              await _klineStore.loadKlineData(
                endTime: oldestTime - 1,
                limit: 100,
              );
            }
          },
        );
        
        // 使用 LayoutBuilder 检查约束，如果没有外部约束，计算高度并用 SizedBox 包裹
        // 这样可以让 KChartWidget 获得明确的约束高度
        return LayoutBuilder(
          builder: (context, constraints) {
            // 如果约束高度无限或无效，计算高度并用 SizedBox 包裹
            if (!constraints.maxHeight.isFinite || constraints.maxHeight <= 0) {
              // 计算高度（与 BaseDimension 完全相同的逻辑）
              const labelHeight = 12.0;
              final secondaryCount = secondaryStates.length;
              final mainStateCount = _klineStore.mainIndicator.isNotEmpty ? 1 : 0;
              
              // BaseDimension 的计算逻辑
              double totalSecondaryHeight = 0;
              double volumeHeight = 0;
              if (secondaryCount > 0 || hasVolume) {
                const secondaryRatio = 0.25;
                totalSecondaryHeight = mBaseHeight * secondaryRatio * secondaryCount;
                volumeHeight = hasVolume ? mBaseHeight * secondaryRatio : 0.0;
              }
              final totalLabelHeight = labelHeight * mainStateCount;
              
              // mDisplayHeight = mBaseHeight + mVolumeHeight + totalSecondaryHeight + totalLabelHeight
              // 注意：BaseChartPainter 会从 size.height 中减去 padding，所以这里需要加上 padding
              final contentHeight = mBaseHeight + volumeHeight + totalSecondaryHeight + totalLabelHeight;
              final calculatedHeight = contentHeight + chartStyle.topPadding + chartStyle.bottomPadding;
              
              return SizedBox(
                height: calculatedHeight,
                width: double.infinity,
                child: kChartWidget,
              );
            }
            // 如果约束高度有效，直接使用（KChartWidget 会使用约束高度）
            return kChartWidget;
          },
        );
      },
    );
  }

  /// 将字符串指标名称转换为 k_chart_plus 的 MainState 枚举
  /// 
  /// 支持的主图指标：
  /// - MA: 移动平均线
  /// - BOLL: 布林带
  MainState _getMainState(String indicator) {
    switch (indicator) {
      case 'MA':
        return MainState.MA;
      case 'BOLL':
        return MainState.BOLL;
      default:
        return MainState.MA;  // 默认使用MA
    }
  }

  /// 将字符串指标名称转换为 k_chart_plus 的 SecondaryState 枚举
  /// 
  /// 支持的副图指标：
  /// - MACD: 指数平滑移动平均线（显示柱状图）
  /// - RSI: 相对强弱指标
  /// - KDJ: 随机指标（显示柱状图）
  /// - WR: 威廉指标
  /// - CCI: 商品通道指数
  /// 
  /// 注意：MACD和KDJ会显示柱状图，需要调用DataUtil.calculate()才能显示
  SecondaryState? _getSecondaryState(String indicator) {
    if (indicator.isEmpty) {
      return null; // 如果没有选中副图指标，返回null
    }
    
    switch (indicator) {
      case 'MACD':
        return SecondaryState.MACD;  // 显示MACD柱状图
      case 'RSI':
        return SecondaryState.RSI;
      case 'KDJ':
        return SecondaryState.KDJ;   // 显示KDJ柱状图
      case 'WR':
        return SecondaryState.WR;
      case 'CCI':
        return SecondaryState.CCI;
      default:
        return null;
    }
  }

  @override
  void dispose() {
    // 取消WebSocket订阅
    _websocketSubscription?.cancel();
    if (widget.isRealtime && widget.mode == ChartMode.kline) {
      _marketWebSocket.unsubscribe('kline', symbol: '${widget.symbol}:${widget.interval}');
    }
    // Store由依赖注入管理，不需要手动dispose
    super.dispose();
  }
}
