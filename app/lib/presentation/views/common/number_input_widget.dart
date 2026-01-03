import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 数字输入框组件（带+-按钮）
class NumberInputWidget extends StatelessWidget {
  /// 文本控制器
  final TextEditingController controller;
  
  /// 减少回调
  final VoidCallback onDecrease;
  
  /// 增加回调
  final VoidCallback onIncrease;
  
  /// 提示文本
  final String? hintText;
  
  /// 标签文本
  final String? label;
  
  /// 是否加粗
  final bool isBold;
  
  /// 字体大小
  final double fontSize;
  
  /// 背景色
  final Color? backgroundColor;
  
  /// 是否显示标签
  final bool showLabel;
  
  /// 标签样式
  final TextStyle? labelStyle;
  
  /// 输入框内边距
  final EdgeInsets? padding;
  
  /// 是否显示减少按钮
  final bool showDecreaseButton;
  
  /// 是否显示增加按钮
  final bool showIncreaseButton;
  
  /// 右侧自定义内容
  final Widget? trailing;

  const NumberInputWidget({
    super.key,
    required this.controller,
    required this.onDecrease,
    required this.onIncrease,
    this.hintText,
    this.label,
    this.isBold = false,
    this.fontSize = 16,
    this.backgroundColor,
    this.showLabel = true,
    this.labelStyle,
    this.padding,
    this.showDecreaseButton = true,
    this.showIncreaseButton = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final defaultLabelStyle = TextStyle(fontSize: 12, color: Colors.grey.shade400);
    final defaultBackgroundColor = backgroundColor ?? Colors.grey.shade100;
    final defaultPadding = padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6);

    return Container(
      padding: defaultPadding,
      decoration: BoxDecoration(
        color: defaultBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showDecreaseButton)
            InkWell(
              onTap: onDecrease,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Icon(Icons.remove, size: 20, color: Colors.grey.shade400),
              ),
            ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 标签显示在输入框上方
                if (label != null && label!.isNotEmpty && showLabel) ...[
                  Text(
                    label!,
                    style: labelStyle ?? defaultLabelStyle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                ],
                // 输入框
                TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    hintText: hintText,
                    hintStyle: TextStyle(fontSize: fontSize * 0.8, color: Colors.grey.shade400),
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    filled: false,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
          if (showIncreaseButton)
            InkWell(
              onTap: onIncrease,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Icon(Icons.add, size: 20, color: Colors.grey.shade400),
              ),
            ),
        ],
      ),
    );
  }
}
