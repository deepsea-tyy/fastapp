import 'package:flutter/material.dart';

/// 通用操作列表底部弹框
///
/// 适用于需要显示一系列操作选项的场景，如菜单、举报等
class ActionBottomSheet extends StatelessWidget {
  /// 标题
  final String? title;

  /// 副标题/描述
  final String? subtitle;

  /// 选项列表
  final List<ActionSheetItem> items;

  /// 分组选项列表（如果需要分组显示）
  final List<ActionSheetSection>? sections;

  /// 是否显示拖拽把手
  final bool showDragHandle;

  const ActionBottomSheet({
    super.key,
    this.title,
    this.subtitle,
    this.items = const [],
    this.sections,
    this.showDragHandle = true,
  });

  /// 显示底部弹框
  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    String? subtitle,
    List<ActionSheetItem>? items,
    List<ActionSheetSection>? sections,
    bool showDragHandle = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ActionBottomSheet(
        title: title,
        subtitle: subtitle,
        items: items ?? [],
        sections: sections,
        showDragHandle: showDragHandle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDragHandle) ...[
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
            if (title != null || subtitle != null) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (sections != null && sections!.isNotEmpty)
              ...sections!.map((section) => _buildSection(context, section))
            else
              ...items.map((item) => _buildMenuItem(context, item)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, ActionSheetSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section.title != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              section.title!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        ...section.items.map((item) => _buildMenuItem(context, item)),
        if (section.showDivider)
          Divider(height: 1, color: Colors.grey.shade200),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, ActionSheetItem item) {
    return InkWell(
      onTap: () {
        if (item.closeOnTap) {
          Navigator.pop(context, item.value);
        }
        item.onTap?.call();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (item.icon != null) ...[
              Icon(
                item.icon,
                size: 24,
                color: item.iconColor ?? Colors.grey.shade700,
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Text(
                item.text,
                style: TextStyle(
                  fontSize: 16,
                  color: item.textColor ?? Colors.black87,
                  fontWeight: item.fontWeight,
                ),
              ),
            ),
            if (item.trailing != null) item.trailing!,
          ],
        ),
      ),
    );
  }
}

/// 操作项数据模型
class ActionSheetItem {
  /// 显示文本
  final String text;

  /// 图标
  final IconData? icon;

  /// 点击回调
  final VoidCallback? onTap;

  /// 点击后是否关闭弹框
  final bool closeOnTap;

  /// 文本颜色
  final Color? textColor;

  /// 图标颜色
  final Color? iconColor;

  /// 字体粗细
  final FontWeight? fontWeight;

  /// 尾部 widget
  final Widget? trailing;

  /// 返回值（当 closeOnTap 为 true 时返回）
  final dynamic value;

  const ActionSheetItem({
    required this.text,
    this.icon,
    this.onTap,
    this.closeOnTap = true,
    this.textColor,
    this.iconColor,
    this.fontWeight,
    this.trailing,
    this.value,
  });

  /// 创建危险样式的操作项（红色）
  factory ActionSheetItem.danger({
    required String text,
    IconData? icon,
    VoidCallback? onTap,
    bool closeOnTap = true,
    dynamic value,
  }) {
    return ActionSheetItem(
      text: text,
      icon: icon,
      onTap: onTap,
      closeOnTap: closeOnTap,
      textColor: Colors.red,
      iconColor: Colors.red,
      value: value,
    );
  }
}

/// 分组数据模型
class ActionSheetSection {
  /// 分组标题
  final String? title;

  /// 分组选项
  final List<ActionSheetItem> items;

  /// 是否显示分隔线
  final bool showDivider;

  const ActionSheetSection({
    this.title,
    required this.items,
    this.showDivider = true,
  });
}
