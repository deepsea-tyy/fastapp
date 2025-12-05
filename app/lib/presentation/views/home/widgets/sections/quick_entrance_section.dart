import 'package:flutter/material.dart';
import 'package:fastapp/utils/routes/routes.dart';

/// 快捷入口组件
///
/// 显示登录后的快捷功能入口，包括：
/// - C2C买币
/// - 理财
/// - 热门活动
/// - 邀请奖励
/// - 更多
class QuickEntranceSection extends StatelessWidget {
  const QuickEntranceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildEntranceItem(
            context,
            icon: Icons.swap_horiz,
            label: 'C2C买币',
            decorationColor: Colors.orange.shade300,
            decorationPosition: const Alignment(-0.6, -0.6),
            onTap: () {
              // TODO: 导航到C2C买币页面
            },
          ),
          _buildEntranceItem(
            context,
            icon: Icons.account_balance_wallet,
            label: '理财',
            decorationColor: Colors.orange.shade300,
            decorationPosition: const Alignment(0, -0.8),
            decorationSize: 12,
            onTap: () {
              // TODO: 导航到理财页面
            },
          ),
          _buildEntranceItem(
            context,
            icon: Icons.local_fire_department,
            label: '热门活动',
            decorationColor: Colors.orange.shade300,
            decorationPosition: const Alignment(0, -0.8),
            decorationType: 'rays',
            onTap: () {
              // TODO: 导航到热门活动页面
            },
          ),
          _buildEntranceItem(
            context,
            icon: Icons.person_add,
            label: '邀请奖励',
            decorationColor: Colors.orange.shade300,
            decorationPosition: const Alignment(0.6, -0.6),
            decorationType: 'plus',
            onTap: () {
              // TODO: 导航到邀请奖励页面
            },
          ),
          _buildEntranceItem(
            context,
            icon: Icons.grid_view,
            label: '更多',
            decorationColor: Colors.orange.shade300,
            decorationPosition: const Alignment(0.3, -0.3),
            decorationType: 'grid',
            onTap: () {
              Navigator.of(context).pushNamed(Routes.service);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEntranceItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? decorationColor,
    Alignment? decorationPosition,
    double? decorationSize,
    String? decorationType,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: Colors.black87,
                  ),
                ),
                if (decorationColor != null && decorationPosition != null)
                  Positioned.fill(
                    child: Align(
                      alignment: decorationPosition,
                      child: Transform.translate(
                        offset: Offset(
                          decorationPosition.x * 4,
                          decorationPosition.y * 4,
                        ),
                        child: _buildDecoration(
                          decorationType ?? 'dot',
                          decorationColor,
                          decorationSize ?? 8,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecoration(String type, Color color, double size) {
    switch (type) {
      case 'rays':
        return CustomPaint(
          size: Size(size * 3, size * 3),
          painter: RaysPainter(color: color),
        );
      case 'plus':
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add,
            size: 8,
            color: Colors.white,
          ),
        );
      case 'grid':
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      default:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        );
    }
  }
}

class RaysPainter extends CustomPainter {
  final Color color;

  RaysPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < 4; i++) {
      final angle = (i * 90) * 3.14159 / 180;
      final x = center.dx + radius * 0.6 * (angle == 0 ? 0 : (angle > 1.57 ? -1 : 1));
      final y = center.dy + radius * 0.6 * (angle == 0 ? 1 : (angle > 1.57 ? 0 : -1));
      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
