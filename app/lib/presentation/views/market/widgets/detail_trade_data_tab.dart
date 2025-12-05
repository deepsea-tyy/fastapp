import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// 交易数据标签页 - 资金流向分析
class DetailTradeDataTab extends StatefulWidget {
  const DetailTradeDataTab({super.key});

  @override
  State<DetailTradeDataTab> createState() => _DetailTradeDataTabState();
}

class _DetailTradeDataTabState extends State<DetailTradeDataTab> {
  int _selectedTimeframe = 5; // 默认选中"1天"

  final List<String> _timeframes = ['15分', '30分', '1小时', '2小时', '4小时', '1天'];

  // 模拟数据
  final List<ChartSegment> _chartSegments = [
    ChartSegment(percentage: 38.97, color: Colors.red.shade700, label: '38.97%'),
    ChartSegment(percentage: 7.51, color: Colors.red.shade400, label: '7.51%'),
    ChartSegment(percentage: 3.45, color: Colors.red.shade300, label: '3.45%'),
    ChartSegment(percentage: 39.95, color: Colors.green.shade700, label: '39.95%'),
    ChartSegment(percentage: 7.08, color: Colors.green.shade400, label: '7.08%'),
    ChartSegment(percentage: 3.04, color: Colors.green.shade300, label: '3.04%'),
  ];

  final List<TradeDataRow> _tradeData = [
    TradeDataRow(
      orderType: '大单',
      buyAmount: 24538.1659,
      sellAmount: 23934.2361,
      netInflow: 603.9298,
      buyColor: Colors.green.shade900,
      sellColor: Colors.red.shade900,
    ),
    TradeDataRow(
      orderType: '中单',
      buyAmount: 4347.3740,
      sellAmount: 4613.0192,
      netInflow: -265.6451,
      buyColor: Colors.green.shade600,
      sellColor: Colors.red.shade600,
    ),
    TradeDataRow(
      orderType: '小单',
      buyAmount: 1864.0575,
      sellAmount: 2119.2776,
      netInflow: -255.2201,
      buyColor: Colors.green.shade300,
      sellColor: Colors.red.shade300,
    ),
    TradeDataRow(
      orderType: '加总',
      buyAmount: 30749.5974,
      sellAmount: 30666.5329,
      netInflow: 83.0645,
      buyColor: Colors.green,
      sellColor: Colors.red,
      isTotal: true,
    ),
  ];

  // 5 x 24 小时大单净流入数据
  final List<NetInflowData> _netInflowData = [
    NetInflowData(value: -1162.7372, isRecent24h: false),
    NetInflowData(value: -983.2468, isRecent24h: false),
    NetInflowData(value: -4020.2070, isRecent24h: false),
    NetInflowData(value: -1991.9315, isRecent24h: false),
    NetInflowData(value: 478.5343, isRecent24h: true),
  ];
  
  final double _totalNetInflow = -7679.5881;

  // 24小时资金净流入数据（模拟数据，包含时间和净流入值）
  final List<HourlyNetInflowData> _hourlyNetInflowData = [
    HourlyNetInflowData(time: '14:15', value: 155),
    HourlyNetInflowData(time: '16:00', value: -200),
    HourlyNetInflowData(time: '18:00', value: -438),
    HourlyNetInflowData(time: '20:00', value: -800),
    HourlyNetInflowData(time: '22:00', value: -1031),
    HourlyNetInflowData(time: '00:00', value: -1200),
    HourlyNetInflowData(time: '02:00', value: -1400),
    HourlyNetInflowData(time: '04:00', value: -1500),
    HourlyNetInflowData(time: '06:00', value: -1624),
    HourlyNetInflowData(time: '08:00', value: -1303),
    HourlyNetInflowData(time: '10:00', value: -1100),
    HourlyNetInflowData(time: '12:00', value: -900),
    HourlyNetInflowData(time: '14:00', value: -700),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部标题栏
          _buildHeader(),
          
          // 时间选择器
          _buildTimeframeSelector(),
          
          const SizedBox(height: 24),
          
          // 甜甜圈图表
          _buildDonutChart(),
          
          const SizedBox(height: 32),
          
          // 数据表格
          _buildDataTable(),
          
          const SizedBox(height: 32),
          
          // 5 x 24 小时大单净流入图表
          _buildNetInflowChart(),
          
          const SizedBox(height: 32),
          
          // 24小时资金净流入折线图
          _buildHourlyNetInflowChart(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text(
            '资金流向分析',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline,
              size: 12,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black87),
            onPressed: () {
              // TODO: 分享功能
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _timeframes.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedTimeframe == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTimeframe = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.grey.shade800 : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  _timeframes[index],
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDonutChart() {
    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 80,
              sections: _chartSegments.map((segment) {
                return PieChartSectionData(
                  value: segment.percentage,
                  color: segment.color,
                  title: segment.percentage > 5 ? segment.label : '',
                  radius: 100,
                  titleStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '总流入',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '83.0645',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // 表头
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '单量',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '买入 (BTC)',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '卖出 (BTC)',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '净流入',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 数据行
          ..._tradeData.map((row) => _buildTableRow(row)),
        ],
      ),
    );
  }

  Widget _buildTableRow(TradeDataRow row) {
    final isPositive = row.netInflow >= 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              row.orderType,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: row.isTotal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: row.buyColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _formatNumber(row.buyAmount),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: row.isTotal ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: row.sellColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _formatNumber(row.sellAmount),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: row.isTotal ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatNumber(row.netInflow),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                color: isPositive ? Colors.green : Colors.red,
                fontWeight: row.isTotal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    if (value.abs() >= 1000) {
      return value.toStringAsFixed(4);
    } else {
      return value.toStringAsFixed(4);
    }
  }

  Widget _buildNetInflowChart() {
    return _buildChartContainer(
      title: '5 x 24 小时大单净流入(BTC)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          // 总结信息
          Row(
            children: [
              const Text(
                '5日主力净流入: ',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              Text(
                _formatNumber(_totalNetInflow),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 柱状图
          _buildBarChart(),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final maxValue = _netInflowData.map((e) => e.value.abs()).reduce(math.max);
    final minValue = _netInflowData.map((e) => e.value).reduce(math.min);
    final range = maxValue - minValue;
    final zeroY = range > 0 ? (-minValue / range) : 0.5;
    
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          // 柱状图
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue,
                  minY: minValue,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: const FlTitlesData(
                    show: false,
                  ),
                  gridData: FlGridData(
                    show: false,
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      top: BorderSide.none,
                      bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                      left: BorderSide.none,
                      right: BorderSide.none,
                    ),
                  ),
                  barGroups: _netInflowData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    final isPositive = data.value >= 0;
                    
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data.value,
                          fromY: 0,
                          color: isPositive ? Colors.green.shade600 : Colors.red.shade600,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(2),
                            bottom: Radius.circular(2),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          
          // 数值标签和"近24小时"标签
          Positioned.fill(
            child: Row(
              children: List.generate(_netInflowData.length, (index) {
                final data = _netInflowData[index];
                final isPositive = data.value >= 0;
                final valueHeight = (data.value.abs() / maxValue) * 160;
                final zeroPosition = 160 * (1 - zeroY);
                
                return Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 正值标签在上
                      if (isPositive)
                        SizedBox(
                          height: zeroPosition,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                _formatNumber(data.value),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      
                      // 负值占位
                      if (!isPositive) SizedBox(height: zeroPosition),
                      
                      // "近24小时"标签
                      if (data.isRecent24h)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '近24小时',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black87,
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 20),
                      
                      // 正值占位
                      if (isPositive) SizedBox(height: 160 - zeroPosition - valueHeight),
                      
                      // 负值标签在下
                      if (!isPositive)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _formatNumber(data.value),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyNetInflowChart() {
    final maxValue = _hourlyNetInflowData.map((e) => e.value).reduce(math.max);
    final minValue = _hourlyNetInflowData.map((e) => e.value).reduce(math.min);
    
    return _buildChartContainer(
      title: '24小时资金净流入(BTC)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // 折线图
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxValue - minValue) / 4,
                  getDrawingHorizontalLine: (value) {
                    if (value == 0 || (value > -1100 && value < -1000)) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    }
                    return FlLine(
                      color: Colors.grey.shade100,
                      strokeWidth: 0.5,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < _hourlyNetInflowData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _hourlyNetInflowData[index].time,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: (maxValue - minValue) / 4,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                minX: 0,
                maxX: (_hourlyNetInflowData.length - 1).toDouble(),
                minY: minValue - 200,
                maxY: maxValue + 200,
                lineBarsData: [
                  LineChartBarData(
                    spots: _hourlyNetInflowData.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.value.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: Colors.amber.shade600,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: false,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.amber.shade700,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.amber.shade200.withOpacity(0.4),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => Colors.black87,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        final index = touchedSpot.x.toInt();
                        if (index >= 0 && index < _hourlyNetInflowData.length) {
                          final data = _hourlyNetInflowData[index];
                          return LineTooltipItem(
                            '12-03 ${data.time}\n${data.value}',
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          );
                        }
                        return null;
                      }).toList();
                    },
                  ),
                  getTouchedSpotIndicator: (LineChartBarData barData, List<int> indicators) {
                    return indicators.map((int index) {
                      return TouchedSpotIndicatorData(
                        FlLine(
                          color: Colors.grey.shade400,
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        ),
                        FlDotData(
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 5,
                              color: Colors.amber.shade700,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                      );
                    }).toList();
                  },
                  handleBuiltInTouches: true,
                  getTouchLineStart: (data, index) => 0,
                  getTouchLineEnd: (data, index) => 250,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建图表容器（提取公共样式）
  Widget _buildChartContainer({
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.share, color: Colors.grey.shade600, size: 20),
                onPressed: () {
                  // TODO: 分享功能
                },
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}

/// 净流入数据
class NetInflowData {
  final double value;
  final bool isRecent24h;

  NetInflowData({
    required this.value,
    this.isRecent24h = false,
  });
}

/// 24小时资金净流入数据
class HourlyNetInflowData {
  final String time;
  final int value;

  HourlyNetInflowData({
    required this.time,
    required this.value,
  });
}

/// 图表段数据
class ChartSegment {
  final double percentage;
  final Color color;
  final String label;

  ChartSegment({
    required this.percentage,
    required this.color,
    required this.label,
  });
}

/// 交易数据行
class TradeDataRow {
  final String orderType;
  final double buyAmount;
  final double sellAmount;
  final double netInflow;
  final Color buyColor;
  final Color sellColor;
  final bool isTotal;

  TradeDataRow({
    required this.orderType,
    required this.buyAmount,
    required this.sellAmount,
    required this.netInflow,
    required this.buyColor,
    required this.sellColor,
    this.isTotal = false,
  });
}

