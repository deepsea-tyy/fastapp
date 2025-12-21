import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'service_item_model.dart';
import 'quick_entrance_state.dart';
import 'package:fastapp/utils/routes/routes.dart';

/// 快捷入口组件
///
/// 显示用户自定义的快捷功能入口
/// 配置数据由 QuickEntranceState 管理
class QuickEntranceWidget extends StatelessWidget {
  const QuickEntranceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuickEntranceState>(
      builder: (context, manager, child) {
        final entrances = manager.getQuickEntrances();

        if (entrances.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          color: Colors.white,
          child: Column(
            children: [
              // 标题栏
              _buildHeader(context),
              // 快捷入口列表 - 2行，每行5个
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // 计算每个项目的宽度：总宽度 / 5，确保两行对齐
                    final itemWidth = constraints.maxWidth / 5;
                    return Column(
                      children: [
                        // 第一行
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(5, (index) {
                            if (index < entrances.length) {
                              return SizedBox(
                                width: itemWidth,
                                child: _buildEntranceItem(context, item: entrances[index]),
                              );
                            }
                            return SizedBox(width: itemWidth);
                          }),
                        ),
                        // 第二行（如果有超过5个）
                        if (entrances.length > 5)
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(5, (index) {
                                final actualIndex = index + 5;
                                if (actualIndex < entrances.length) {
                                  return SizedBox(
                                    width: itemWidth,
                                    child: _buildEntranceItem(context, item: entrances[actualIndex]),
                                  );
                                }
                                return SizedBox(width: itemWidth);
                              }),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建标题栏
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左侧标题
          const Text(
            '快捷入口',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          // 右侧"更多"按钮
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(Routes.service),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  '更多',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntranceItem(
    BuildContext context, {
    required AppServiceItem item,
  }) {
    return GestureDetector(
      onTap: () => item.onTap?.call(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                  item.icon,
                  size: 28,
                  color: Colors.black87,
                ),
              ),
              if (item.decorationColor != null && item.decorationPosition != null)
                Positioned.fill(
                  child: Align(
                    alignment: item.decorationPosition!,
                    child: Transform.translate(
                      offset: Offset(
                        item.decorationPosition!.x * 4,
                        item.decorationPosition!.y * 4,
                      ),
                      child: _buildDecoration(
                        item.decorationType ?? 'dot',
                        item.decorationColor!,
                        item.decorationSize ?? 8,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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

