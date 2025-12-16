import 'package:flutter/material.dart';

/// 通用空状态组件
///
/// 用于显示空数据、无内容、无搜索结果等场景
class CommonEmptyState extends StatelessWidget {
  /// 图标
  final IconData? icon;

  /// 图标大小
  final double iconSize;

  /// 图标颜色
  final Color? iconColor;

  /// 主标题
  final String title;

  /// 主标题样式
  final TextStyle? titleStyle;

  /// 描述文字
  final String? description;

  /// 描述文字样式
  final TextStyle? descriptionStyle;

  /// 操作按钮文本
  final String? actionText;

  /// 操作按钮回调
  final VoidCallback? onAction;

  /// 操作按钮样式
  final ButtonStyle? actionButtonStyle;

  /// 自定义内容（如果提供，将显示在描述下方）
  final Widget? customContent;

  /// 内边距
  final EdgeInsetsGeometry padding;

  const CommonEmptyState({
    super.key,
    this.icon,
    this.iconSize = 64,
    this.iconColor,
    required this.title,
    this.titleStyle,
    this.description,
    this.descriptionStyle,
    this.actionText,
    this.onAction,
    this.actionButtonStyle,
    this.customContent,
    this.padding = const EdgeInsets.all(24.0),
  });

  /// 预设：无数据状态
  factory CommonEmptyState.noData({
    String title = '暂无数据',
    String? description,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return CommonEmptyState(
      icon: Icons.inbox_outlined,
      title: title,
      description: description,
      actionText: actionText,
      onAction: onAction,
    );
  }

  /// 预设：无搜索结果
  factory CommonEmptyState.noSearchResults({
    String title = '未找到相关内容',
    String? description,
    VoidCallback? onAction,
  }) {
    return CommonEmptyState(
      icon: Icons.search_off,
      title: title,
      description: description ?? '试试其他搜索词',
      actionText: onAction != null ? '清除搜索' : null,
      onAction: onAction,
    );
  }

  /// 预设：网络错误
  factory CommonEmptyState.networkError({
    String title = '网络连接失败',
    String? description,
    VoidCallback? onAction,
  }) {
    return CommonEmptyState(
      icon: Icons.wifi_off,
      title: title,
      description: description ?? '请检查您的网络连接',
      actionText: '重试',
      onAction: onAction,
    );
  }

  /// 预设：无内容（信息流等）
  factory CommonEmptyState.noContent({
    String title = '暂无内容',
    String? description,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return CommonEmptyState(
      icon: Icons.article_outlined,
      title: title,
      description: description,
      actionText: actionText,
      onAction: onAction,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标
            if (icon != null)
              Icon(
                icon,
                size: iconSize,
                color: iconColor ?? Colors.grey.shade400,
              ),

            if (icon != null) const SizedBox(height: 16),

            // 主标题
            Text(
              title,
              style: titleStyle ?? TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),

            // 描述
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: descriptionStyle ?? TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // 自定义内容
            if (customContent != null) ...[
              const SizedBox(height: 16),
              customContent!,
            ],

            // 操作按钮
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: actionButtonStyle ?? ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  actionText!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
