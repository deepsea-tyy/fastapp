import 'package:flutter/material.dart';
import 'widgets/bot_investment_sheet.dart';

/// 网格机器人详情页面
class GridBotDetailScreen extends StatefulWidget {
  final Map<String, dynamic> botData;

  const GridBotDetailScreen({
    super.key,
    required this.botData,
  });

  @override
  State<GridBotDetailScreen> createState() => _GridBotDetailScreenState();
}

class _GridBotDetailScreenState extends State<GridBotDetailScreen> {
  String _selectedPeriod = '日线';
  bool _showMoreInfo = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '机器人详情',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 交易对信息
                  _buildPairInfo(),
                  const Divider(height: 1),
                  // 历史盈利
                  _buildHistoricalProfit(),
                  const Divider(height: 1, thickness: 8),
                  // 机器人预览
                  _buildBotPreview(),
                  const Divider(height: 1, thickness: 8),
                  // 基础信息
                  _buildBasicInfo(),
                  const Divider(height: 1, thickness: 8),
                  // 现货网格介绍
                  _buildGridIntroduction(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          // 底部复制按钮
          _buildCopyButton(),
        ],
      ),
    );
  }

  Widget _buildPairInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.botData['pair'] ?? 'BTC/JPY',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '现货网格',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '上移',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '高42',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '14208312',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '-1.86%',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFFFF6B6B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoricalProfit() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '历史盈利',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '收益率',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '1.18%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF00C087),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '收益额 (USD)',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '\$2,370.13',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF00C087),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 盈利图表
          SizedBox(
            height: 120,
            child: CustomPaint(
              painter: ProfitChartPainter(),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '机器人预览',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          // 时间段选择
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['1周', '6小时', '8小时', '12小时', '日线', '3日', '周线', '月线']
                  .map((period) => _buildPeriodButton(period))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          // K线图（使用占位图）
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                // 模拟K线图
                CustomPaint(
                  painter: CandlestickChartPainter(),
                  child: Container(),
                ),
                // Binance水印
                Center(
                  child: Opacity(
                    opacity: 0.1,
                    child: Text(
                      'BINANCE',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = period),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black87 : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          period,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '基础信息',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('运行时间', '5天 19时 31分'),
          const SizedBox(height: 12),
          _buildInfoRow('24小时/总配对次数', '33/167'),
          const SizedBox(height: 12),
          _buildInfoRow('价格区间 (JPY)', '14233329 - 14633329'),
          const SizedBox(height: 12),
          _buildInfoRow('网格数量', '12'),
          const SizedBox(height: 12),
          _buildInfoRow('模式', '等差网格'),
          const SizedBox(height: 12),
          _buildInfoRow('每格利润（已扣除费用）', '0.02% - 0.03%'),
          if (_showMoreInfo) ...[
            const SizedBox(height: 12),
            // 这里可以添加更多信息
          ],
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              setState(() {
                _showMoreInfo = !_showMoreInfo;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _showMoreInfo ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildGridIntroduction() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '现货网格介绍',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildIntroItem(
            Icons.play_circle_outline,
            '自动操作',
            '自动买卖订单，省时省力。',
          ),
          const SizedBox(height: 16),
          _buildIntroItem(
            Icons.trending_up,
            '从波动中获利',
            '抓住小幅波动机会获利。',
          ),
          const SizedBox(height: 16),
          _buildIntroItem(
            Icons.access_time,
            '策略稳定',
            '保持稳定的交易方式。',
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              // TODO: 显示教学视频
            },
            child: Text(
              '教学视频',
              style: TextStyle(
                fontSize: 14,
                color: Colors.amber.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '* 由于行情在美差，上述数据法进行回测的结果。',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 24,
          color: Colors.grey.shade700,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCopyButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            // 显示投资金额弹窗
            BotInvestmentSheet.show(
              context,
              botPair: widget.botData['pair'] ?? 'BTC/JPY',
              botType: widget.botData['type'] ?? '现货网格',
              botDetails: {
                'suggestedDuration': '3-7 天',
                'priceRange': '14233329 - 14633329',
                'gridCount': 12,
                'mode': '等差网格',
                'profitPerGrid': '0.02% - 0.03%',
                'sellAllOnStop': '已启用',
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.shade400,
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: const Text(
            '复制',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// 盈利图表绘制器
class ProfitChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // 绘制负值区域（红色）
    final redPath = Path();
    redPath.moveTo(0, size.height * 0.5);
    redPath.lineTo(size.width * 0.15, size.height * 0.5);
    redPath.lineTo(size.width * 0.2, size.height * 0.8);
    redPath.lineTo(size.width * 0.25, size.height * 0.75);
    redPath.lineTo(size.width * 0.3, size.height * 0.7);

    paint.color = const Color(0xFFFF6B6B);
    canvas.drawPath(redPath, paint);

    // 绘制正值区域（绿色）
    final greenPath = Path();
    greenPath.moveTo(size.width * 0.3, size.height * 0.7);
    greenPath.lineTo(size.width * 0.5, size.height * 0.4);
    greenPath.lineTo(size.width * 0.7, size.height * 0.3);
    greenPath.lineTo(size.width, size.height * 0.2);

    paint.color = const Color(0xFF00C087);
    canvas.drawPath(greenPath, paint);

    // 绘制中线
    paint.color = Colors.grey.shade300;
    paint.strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// K线图绘制器
class CandlestickChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final candleWidth = size.width / 50;
    final random = [0.3, 0.5, 0.4, 0.6, 0.5, 0.7, 0.6, 0.8, 0.7, 0.6, 0.5, 0.6, 0.7, 0.8, 0.75];

    for (int i = 0; i < 50; i++) {
      final x = i * candleWidth + candleWidth / 2;
      final candleHeight = size.height * (random[i % random.length]);
      final isGreen = i % 3 != 0;

      final paint = Paint()
        ..color = isGreen ? const Color(0xFF00C087) : const Color(0xFFFF6B6B)
        ..style = PaintingStyle.fill;

      // 绘制蜡烛
      canvas.drawRect(
        Rect.fromLTWH(
          x - candleWidth * 0.4,
          size.height - candleHeight,
          candleWidth * 0.8,
          candleHeight,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
