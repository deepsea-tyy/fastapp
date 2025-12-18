import 'package:flutter/material.dart';

/// 通用底部弹框包装组件
///
/// 统一所有底部弹框的外观和样式
class BottomSheetWrapper extends StatelessWidget {
  /// 标题
  final String? title;

  /// 标题样式
  final TextStyle? titleStyle;

  /// 标题对齐方式
  final TextAlign titleAlign;

  /// 副标题/描述
  final String? subtitle;

  /// 内容区域
  final Widget child;

  /// 是否显示拖拽把手
  final bool showDragHandle;

  /// 是否显示返回按钮
  final bool showBackButton;

  /// 返回按钮点击回调
  final VoidCallback? onBack;

  /// 自定义高度（0-1 之间的比例，或具体数值）
  final double? height;

  /// 内边距
  final EdgeInsets? padding;

  /// 头部右侧操作按钮
  final Widget? trailing;

  const BottomSheetWrapper({
    super.key,
    this.title,
    this.titleStyle,
    this.titleAlign = TextAlign.left,
    this.subtitle,
    required this.child,
    this.showDragHandle = true,
    this.showBackButton = false,
    this.onBack,
    this.height,
    this.padding,
    this.trailing,
  });

  /// 显示底部弹框
  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    TextStyle? titleStyle,
    TextAlign titleAlign = TextAlign.left,
    String? subtitle,
    required Widget child,
    bool showDragHandle = true,
    bool showBackButton = false,
    VoidCallback? onBack,
    double? height,
    EdgeInsets? padding,
    Widget? trailing,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (context) => BottomSheetWrapper(
        title: title,
        titleStyle: titleStyle,
        titleAlign: titleAlign,
        subtitle: subtitle,
        showDragHandle: showDragHandle,
        showBackButton: showBackButton,
        onBack: onBack,
        height: height,
        padding: padding,
        trailing: trailing,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final actualHeight = height != null
        ? (height! <= 1 ? screenHeight * height! : height)
        : null;

    return Container(
      height: actualHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: actualHeight == null ? MainAxisSize.min : MainAxisSize.max,
          children: [
            if (showDragHandle) _buildDragHandle(),
            if (title != null || showBackButton || trailing != null)
              _buildHeader(context),
            if (subtitle != null) _buildSubtitle(),
            Expanded(
              child: Padding(
                padding: padding ?? EdgeInsets.zero,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    if (showBackButton) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack ?? () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            if (title != null)
              Expanded(
                child: Text(
                  title!,
                  style: titleStyle ??
                      const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                  textAlign: titleAlign,
                ),
              ),
            if (trailing != null)
              trailing!
            else
              const SizedBox(width: 48),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title ?? '',
              style: titleStyle ??
                  const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
              textAlign: titleAlign,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Text(
        subtitle!,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
        textAlign: titleAlign,
      ),
    );
  }
}
