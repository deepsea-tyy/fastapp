import 'package:fastapp/presentation/views/spot/widgets/common/assets/asset_item.dart';
import 'package:flutter/material.dart';

/// 当前交易对资产组件
class CurrentTradingPairAssets extends StatelessWidget {
  const CurrentTradingPairAssets({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '当前交易对资产',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              IconButton(
                icon: _FilterIcon(color: Colors.grey.shade600),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AssetItem(
            symbol: 'BTC',
            name: 'Bitcoin',
            iconColor: Colors.orange,
            iconText: 'B',
            balance: '0.00',
          ),
          const Divider(height: 32),
          AssetItem(
            symbol: 'USDT',
            name: 'TetherUS',
            iconColor: Colors.teal,
            iconText: 'T',
            balance: '0.00',
          ),
        ],
      ),
    );
  }
}

/// 自定义筛选图标（两个水平短横线，每条线上有两个小圆圈）
class _FilterIcon extends StatelessWidget {
  final Color color;

  const _FilterIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 16),
      painter: _FilterIconPainter(color: color),
    );
  }
}

class _FilterIconPainter extends CustomPainter {
  final Color color;

  _FilterIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 绘制两条水平线
    final line1Y = size.height * 0.3;
    final line2Y = size.height * 0.7;
    final lineWidth = size.width * 0.6;
    final lineStartX = size.width * 0.2;

    // 第一条线
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(lineStartX, line1Y - 1, lineWidth, 2),
        const Radius.circular(1),
      ),
      paint,
    );

    // 第二条线
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(lineStartX, line2Y - 1, lineWidth, 2),
        const Radius.circular(1),
      ),
      paint,
    );

    // 绘制第一条线上的两个圆圈
    final circleRadius = 2.0;
    final circle1X = lineStartX + lineWidth * 0.25;
    final circle2X = lineStartX + lineWidth * 0.75;
    canvas.drawCircle(Offset(circle1X, line1Y), circleRadius, circlePaint);
    canvas.drawCircle(Offset(circle2X, line1Y), circleRadius, circlePaint);

    // 绘制第二条线上的两个圆圈
    canvas.drawCircle(Offset(circle1X, line2Y), circleRadius, circlePaint);
    canvas.drawCircle(Offset(circle2X, line2Y), circleRadius, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
