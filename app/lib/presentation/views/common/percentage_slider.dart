import 'package:flutter/material.dart';

/// 百分比滑块组件
/// 支持100个滑点（每1%一个），拖动时在滑点上方显示百分比
class PercentageSlider extends StatefulWidget {
  /// 当前百分比值（0.0 - 1.0）
  final double value;
  
  /// 值改变时的回调
  final ValueChanged<double> onChanged;
  
  /// 活动颜色（滑块和轨道的颜色）
  final Color activeColor;
  
  /// 滑块高度
  final double height;

  const PercentageSlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.activeColor,
    this.height = 40,
  }) : assert(value >= 0.0 && value <= 1.0, 'value must be between 0.0 and 1.0');

  @override
  State<PercentageSlider> createState() => _PercentageSliderState();
}

class _PercentageSliderState extends State<PercentageSlider> with SingleTickerProviderStateMixin {
  bool _isDragging = false;
  AnimationController? _animationController;
  Animation<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _handleDragStart(double value) {
    setState(() => _isDragging = true);
    _animationController?.forward();
  }

  void _handleDragEnd(double value) {
    setState(() => _isDragging = false);
    _animationController?.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // 如果动画尚未初始化，返回基础版本
    if (_scaleAnimation == null) {
      return SizedBox(
        width: double.infinity,
        height: widget.height,
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4.0,
            thumbShape: _CustomThumbShape(
              showLabel: _isDragging,
              percentage: widget.value,
              scale: 1.0,
            ),
            activeTrackColor: widget.activeColor,
            inactiveTrackColor: Colors.grey.shade300,
            thumbColor: widget.activeColor,
            overlayColor: widget.activeColor.withOpacity(0.1),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
          ),
          child: Slider(
            value: widget.value,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            onChanged: widget.onChanged,
            onChangeStart: _handleDragStart,
            onChangeEnd: _handleDragEnd,
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _scaleAnimation!,
        builder: (context, child) {
          return SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4.0,
              thumbShape: _CustomThumbShape(
                showLabel: _isDragging,
                percentage: widget.value,
                scale: _scaleAnimation!.value,
              ),
              activeTrackColor: widget.activeColor,
              inactiveTrackColor: Colors.grey.shade300,
              thumbColor: widget.activeColor,
              overlayColor: widget.activeColor.withOpacity(0.1),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
            ),
            child: Slider(
              value: widget.value,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              onChanged: widget.onChanged,
              onChangeStart: _handleDragStart,
              onChangeEnd: _handleDragEnd,
            ),
          );
        },
      ),
    );
  }
}

/// 自定义滑点形状，支持显示百分比标签
class _CustomThumbShape extends SliderComponentShape {
  static const double _thumbRadius = 11.0;
  static const double _borderWidth = 3.0;
  static const double _labelOffset = 28.0;
  static const double _labelPaddingH = 8.0;
  static const double _labelPaddingV = 4.0;
  static const double _triangleSize = 6.0;
  
  final bool showLabel;
  final double percentage;
  final double scale;

  const _CustomThumbShape({
    required this.showLabel,
    required this.percentage,
    this.scale = 1.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(_thumbRadius * scale);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final thumbColor = sliderTheme.thumbColor ?? Colors.blue;
    final scaledRadius = _thumbRadius * scale;

    // 绘制外圈光晕效果（拖动时）
    if (showLabel) {
      canvas.drawCircle(
        center,
        scaledRadius + 4,
        Paint()
          ..color = thumbColor.withOpacity(0.15)
          ..style = PaintingStyle.fill,
      );
    }

    // 绘制滑点主体
    canvas.drawCircle(
      center,
      scaledRadius,
      Paint()
        ..color = thumbColor
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          colors: [
            thumbColor,
            thumbColor.withOpacity(0.9),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: scaledRadius)),
    );

    // 绘制白色边框
    canvas.drawCircle(
      center,
      scaledRadius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = _borderWidth,
    );

    // 绘制内部高光
    canvas.drawCircle(
      Offset(center.dx - 2, center.dy - 2),
      scaledRadius * 0.3,
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.fill,
    );

    // 绘制百分比标签
    if (showLabel) {
      final label = '${(percentage * 100).toStringAsFixed(0)}%';
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        textDirection: textDirection,
      );
      textPainter.layout();

      final labelY = center.dy - scaledRadius - _labelOffset;
      final labelWidth = textPainter.width + _labelPaddingH * 2;
      final labelHeight = textPainter.height + _labelPaddingV * 2;
      
      final labelRect = Rect.fromLTWH(
        center.dx - labelWidth / 2,
        labelY - labelHeight / 2,
        labelWidth,
        labelHeight,
      );

      // 绘制标签背景（带阴影）
      canvas.drawRRect(
        RRect.fromRectAndRadius(labelRect, const Radius.circular(6)),
        Paint()
          ..color = Colors.black.withOpacity(0.1)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(labelRect, const Radius.circular(6)),
        Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.fill,
      );

      // 绘制小三角形指示器
      final trianglePath = Path();
      final triangleTop = labelRect.bottom;
      final triangleCenter = center.dx;
      
      trianglePath.moveTo(triangleCenter, triangleTop + _triangleSize);
      trianglePath.lineTo(triangleCenter - _triangleSize, triangleTop);
      trianglePath.lineTo(triangleCenter + _triangleSize, triangleTop);
      trianglePath.close();
      
      canvas.drawPath(
        trianglePath,
        Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.fill,
      );

      // 绘制标签文字
      textPainter.paint(
        canvas,
        Offset(
          center.dx - textPainter.width / 2,
          labelY - textPainter.height / 2,
        ),
      );
    }
  }
}
