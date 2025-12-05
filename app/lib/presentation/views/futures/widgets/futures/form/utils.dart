import 'package:flutter/material.dart';

// 公共辅助函数
Widget buildDragHandle() {
  return Container(
    margin: const EdgeInsets.only(top: 12, bottom: 8),
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(2),
    ),
  );
}

/// 统一的底部弹窗按钮样式
ButtonStyle get bottomSheetButtonStyle => ElevatedButton.styleFrom(
      backgroundColor: Colors.amber,
      foregroundColor: Colors.black87,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 0,
    );

/// 构建统一的底部弹窗按钮
Widget buildBottomSheetButton({
  required VoidCallback onPressed,
  required String text,
  Color? backgroundColor,
}) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onPressed,
      style: backgroundColor != null
          ? bottomSheetButtonStyle.copyWith(
              backgroundColor: WidgetStateProperty.all(backgroundColor),
            )
          : bottomSheetButtonStyle,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

// 虚线绘制器
class DottedLinePainter extends CustomPainter {
  const DottedLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 3.0;
    const dashSpace = 2.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
