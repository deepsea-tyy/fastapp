import 'package:flutter/material.dart';

/// 未登录时的 Hero 区域组件
///
/// 显示欢迎文本、注册/登录按钮和装饰图标
class ToLoginSection extends StatelessWidget {
  const ToLoginSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 左侧：文本和按钮
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 欢迎文本
                Text(
                  '欢迎探索数字资产的世界！',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                // 注册/登录按钮
                ElevatedButton(
                  onPressed: () {
                    // TODO: 导航到登录/注册页面
                    Navigator.of(context).pushNamed('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '注册/登录',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // 右侧：装饰图标
          _buildGoldenIcon(context),
        ],
      ),
    );
  }

  /// 构建金色装饰图标
  Widget _buildGoldenIcon(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: CustomPaint(
        painter: GoldenIconPainter(),
      ),
    );
  }
}

/// 金色图标绘制器
class GoldenIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.amber;

    // 绘制中心金色圆形
    final centerRadius = size.width * 0.2;
    canvas.drawCircle(center, centerRadius, paint);

    // 绘制中心白色菱形
    final diamondSize = centerRadius * 0.6;
    final diamondPath = Path()
      ..moveTo(center.dx, center.dy - diamondSize)
      ..lineTo(center.dx + diamondSize, center.dy)
      ..lineTo(center.dx, center.dy + diamondSize)
      ..lineTo(center.dx - diamondSize, center.dy)
      ..close();
    
    final whitePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    canvas.drawPath(diamondPath, whitePaint);

    // 绘制两条曲线轨道
    final orbitRadius = size.width * 0.35;
    final curvePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.amber
      ..strokeWidth = 2.0;

    // 上曲线
    final topCurvePath = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: orbitRadius),
        -0.5,
        1.0,
      );
    canvas.drawPath(topCurvePath, curvePaint);

    // 下曲线
    final bottomCurvePath = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: orbitRadius),
        2.6,
        1.0,
      );
    canvas.drawPath(bottomCurvePath, curvePaint);

    // 绘制三个金色小点
    final dotRadius = 4.0;
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.amber;

    // 顶部点
    final topDot = Offset(
      center.dx,
      center.dy - orbitRadius,
    );
    canvas.drawCircle(topDot, dotRadius, dotPaint);

    // 左下点
    final bottomLeftDot = Offset(
      center.dx - orbitRadius * 0.7,
      center.dy + orbitRadius * 0.7,
    );
    canvas.drawCircle(bottomLeftDot, dotRadius, dotPaint);

    // 右下点
    final bottomRightDot = Offset(
      center.dx + orbitRadius * 0.7,
      center.dy + orbitRadius * 0.7,
    );
    canvas.drawCircle(bottomRightDot, dotRadius, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

